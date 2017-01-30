package workflow;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.Locale;
import java.util.TreeMap;

import org.StringManipulationTools;
import org.Vector2i;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;

import colors.ChannelProcessingExt;
import colors.ColorSpaceExt;
import colors.RgbColorSpaceExt;
import de.ipk.ag_ba.image.structures.Image;
import ij.ImagePlus;
import ij.process.ImageProcessor;
import tools.CountingOutputStream;
import tools.ImageFeatureExtraction;
import tools.ImageFeatureExtraction.FeatureMode;

/**
 * Shift input image in X/Y direction and sample data. Create summary ARFF output file with sampled input data around each pixel and a last output column from
 * the target image file.
 * 
 * @author Christian Klukas
 */
public class ArffFromImageFileGeneratorExt {
	public static void main(String[] args) throws IOException, Exception {
		new Settings(); // initialize some static variables
		CommandLineParser parser = new GnuParser();
		Options options = new Options();
		setupOptions(options);
		try {
			CommandLine line = parser.parse(options, args);
			TransferOptions to = new TransferOptions(line);
			
			if (!to.input.exists()) {
				System.err.println("Input image file '" + to.input.getName() + "' could not be found! Return Code 2");
				System.exit(2);
			}
			
			if (!to.target.exists()) {
				System.err.println("Input target file '" + to.target.getName() + "' could not be found! Return Code 3");
				System.exit(3);
			}
			
			Vector2i imgSize = new Vector2i(-1, -1);
			ArrayList<String> inputColumnNames = new ArrayList<>();
			ArrayList<float[][]> inputF = new ArrayList<>();
			ArrayList<float[][]> targetF = new ArrayList<>();
			
			processInputSourceImage(to, imgSize, inputColumnNames, inputF);
			processInputTargetImage(to, imgSize, targetF);
			
			int startX = -to.maskX / 2;
			int endX = to.maskX / 2;
			int startY = -to.maskY / 2;
			int endY = to.maskY / 2;
			
			PrintWriter out = null;
			try {
				int outputIndex = 0;
				CountingOutputStream cos = getCountingStream(to, outputIndex++);
				out = new PrintWriter(new OutputStreamWriter(cos, "UTF-8"));
				out.println("@relation " + to.arffOutput.getName());
				
				writeArffHeader(to, inputColumnNames, targetF, startX, endX, startY, endY, out);
				out.flush();
				cos.writingHeader = false;
				for (int x = 0; x < imgSize.x; x++) {
					for (int y = 0; y < imgSize.y; y++) {
						boolean content = false;
						for (int xs = x + startX; xs <= x + endX; xs++) {
							for (int ys = y + startY; ys <= y + endY; ys++) {
								for (int channel = 0; channel < inputF.size(); channel++) {
									if (content)
										out.print(",");
									if (xs >= 0 && ys >= 0 && xs < imgSize.x && ys < imgSize.y)
										out.print(getIntensity(inputF, xs, ys, channel, to.decimalPlaceFormat));
									else
										out.print("?");
									
									content = true;
								}
							}
						}
						for (int channel = 0; channel < targetF.size(); channel++) {
							out.print(",");
							out.print(getIntensity(targetF, x, y, channel, to.decimalPlaceFormat));
						}
						out.println();
						if (to.maxArffFileSizeInMB >= 0 && cos.getCount() / 1024 / 1024 >= to.maxArffFileSizeInMB) {
							out.flush();
							out.close();
							ArrayList<Byte> header = cos.getHeader();
							cos = getCountingStream(to, outputIndex++);
							out = new PrintWriter(new OutputStreamWriter(cos, "UTF-8"));
							for (Byte b : header)
								cos.write(b);
							cos.flush();
							cos.writingHeader = false;
						}
					}
				}
			} finally {
				if (out != null) {
					out.flush();
					out.close();
				}
			}
		} catch (Exception exp) {
			printErrorAndHelpAndExit(options, exp);
		}
	}
	
	private static void writeArffHeader(TransferOptions to, ArrayList<String> inputColumnNames, ArrayList<float[][]> targetF, int startX, int endX, int startY, int endY, PrintWriter out) {
		for (int xs = startX; xs <= endX; xs++) {
			for (int ys = startY; ys <= endY; ys++) {
				for (String channelName : inputColumnNames) {
					String xid = xs < 0 ? "M" + (-xs) : "P" + xs;
					String yid = ys < 0 ? "M" + (-ys) : "P" + ys;
					out.println("@attribute " + channelName + "_" + xid + "_" + yid + " numeric");
				}
			}
		}
		
		if (to.targetOutputColorSpace != null) {
			for (int channel = 0; channel < to.targetOutputColorSpace.getChannels().length; channel++)
				out.println("@attribute target_" + to.targetInputColorSpace.getChannels()[channel] + " numeric");
		} else {
			for (int channel = 0; channel < targetF.size(); channel++)
				out.println("@attribute target_" + channel + " numeric");
		}
		
		out.println("@data");
	}
	
	private static void processInputTargetImage(TransferOptions to, Vector2i imgSize, ArrayList<float[][]> targetF) {
		ImagePlus tp = new ImagePlus(to.target.getAbsolutePath());
		for (int c = 0; c < tp.getNChannels(); c++) {
			ImageProcessor imgP = tp.getImageStack().getProcessor(c + 1);
			targetF.add(new Image(imgP).getAs2Afloat());
		}
		
		if (to.targetOutputColorSpace != null && to.targetOutputColorSpace != ColorSpaceExt.RGB) {
			ChannelProcessingExt cp = new ChannelProcessingExt(imgSize.x, imgSize.y, targetF.get(0), targetF.get(1), targetF.get(2));
			targetF.clear();
			
			if (!Float.isNaN(to.divisorFor01RangeTargetFile))
				cp.divideInputValuesToReach01Range(to.divisorFor01RangeTargetFile);
			ImagePlus[] transformedTargetImg = cp.getImage(to.rgbColorSpace, to.targetOutputColorSpace);
			for (ImagePlus ip : transformedTargetImg) {
				ImageProcessor imgP = ip.getChannelProcessor();
				targetF.add(new Image(imgP).getAs2Afloat());
			}
		}
		
		if (to.selectedTargetColorSpaceForOutput >= 0) {
			float[][] remainTargetF = targetF.get(to.selectedTargetColorSpaceForOutput);
			targetF.clear();
			targetF.add(remainTargetF);
		}
	}
	
	private static void processInputSourceImage(TransferOptions to, Vector2i imgSize, ArrayList<String> inputColumnNames, ArrayList<float[][]> inputF) {
		ImagePlus ip = new ImagePlus(to.input.getAbsolutePath());
		imgSize.x = ip.getWidth();
		imgSize.y = ip.getHeight();
		
		for (int c = 0; c < ip.getNChannels(); c++) {
			ImageProcessor imgP = ip.getImageStack().getProcessor(c + 1);
			inputF.add(new Image(imgP).getAs2Afloat());
		}
		
		if (to.targetInputColorSpace != null && to.targetInputColorSpace != ColorSpaceExt.RGB) {
			ChannelProcessingExt cp = new ChannelProcessingExt(imgSize.x, imgSize.y, inputF.get(0), inputF.get(1), inputF.get(2));
			inputF.clear();
			if (!Float.isNaN(to.divisorFor01RangeInputFile))
				cp.divideInputValuesToReach01Range(to.divisorFor01RangeInputFile);
			ImagePlus[] transformedTargetImg = cp.getImage(to.rgbColorSpace, to.targetInputColorSpace);
			for (ImagePlus tip : transformedTargetImg) {
				ImageProcessor imgP = tip.getChannelProcessor();
				inputF.add(new Image(imgP).getAs2Afloat());
			}
		}
		
		if (to.targetInputColorSpace != null) {
			for (int channel = 0; channel < to.targetInputColorSpace.getChannels().length; channel++)
				inputColumnNames.add(to.targetInputColorSpace.getChannels()[channel].getID());
		} else {
			for (int channel = 0; channel < inputF.size(); channel++)
				inputColumnNames.add("I" + channel);
		}
		
		if (to.textureSourceFeatureMode != null) {
			for (float[][] iF : inputF) {
				TreeMap<String, Image> res = new ImageFeatureExtraction()
						.processImage(new Image(iF), to.textureMaskSize, to.textureSigma, to.textureSourceFeatureMode);
				for (String key : res.keySet()) {
					inputColumnNames.add(key);
					inputF.add(res.get(key).getAs2Afloat());
				}
			}
		}
	}
	
	private static String getIntensity(ArrayList<float[][]> inputF, int xs, int ys, int channel, DecimalFormat df) {
		if (df == null)
			return ((Float) inputF.get(channel)[xs][ys]).toString();
		else
			return df.format(inputF.get(channel)[xs][ys]);
	}
	
	private static CountingOutputStream getCountingStream(TransferOptions to, int outputIndex) throws FileNotFoundException {
		if (to.maxArffFileSizeInMB >= 0) {
			String fn = to.arffOutput.getAbsolutePath();
			String tf = StringManipulationTools.removeFileExtension(fn);
			String ext = fn.substring(fn.lastIndexOf(".") + ".".length());
			String cn = tf + "." + StringManipulationTools.formatNumberAddZeroInFront(outputIndex, 3) + "." + ext;
			return new CountingOutputStream(new BufferedOutputStream(new FileOutputStream(cn)));
		} else
			return new CountingOutputStream(new BufferedOutputStream(new FileOutputStream(to.arffOutput)));
	}
	
	private static void setupOptions(Options options) {
		{
			Option opt = new Option("i", "inputfile", true, "input image file (gray scale, RGB, or multi-channel tiff)");
			opt.setArgName("image file");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("t", "targetfile", true, "Target image file (gray scale, RGB, or multi-channel tiff).");
			opt.setArgName("image file");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("o", "outputfile", true, "Output ARFF file (result of operation).");
			opt.setArgName("arff file");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("c", "outputchannel", true, "If specified, only one of the output channels is added to the output arff file (e.g. 0 for the first channel).");
			opt.setArgName("channel-index");
			opt.setRequired(false);
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("ics", "inputcolorspace", true, "If specified, the input (RGB) file is transformed to the specified target color space.");
			opt.setArgName("colorspace");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("w", "maskwidth", true,
					"If specified, a mask size (width) greater one is used, to add intensity values around the currently processed pixel. It is recommended to directly specify odd numbers, as even numbers are not supported. The mask will always be symetric.");
			opt.setArgName("mask-width");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("h", "maskheight", true,
					"If specified, a mask size (height) greater one is used, to add intensity values around the currently processed pixel. It is recommended to directly specify odd numbers, as even numbers are not supported. The mask will always be symetric.");
			opt.setArgName("mask-height");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("tcs", "targetcolorspace", true, "If specified, the output (RGB) file is transformed to the specified target color space.");
			opt.setArgName("colorspace");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("si", "scaleinput", true,
					"If specified, the input image intensity values are scaled down (to 0..1) according to the maximum of the parameters bit range. "
							+ "E.g. '8' means 8 bit source range, the input intensities are divided by 2^8=256, '16' causes division by 65536. "
							+ "You may also specify a custom divisor, by entering negative values. E.g. '-100' would divide the input intensity "
							+ "values by 100. This parameter needs to be correctly specified, if a colorspace transformation is requested!");
			opt.setArgName("bit-count/-scale-factor");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("st", "scaletarget", true,
					"If specified, the target image intensity values are scaled down (to 0..1). See 'scanleinput' parameter for more details.");
			opt.setArgName("bit-count/-scale-factor");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("dp", "decimalplaces", true,
					"If specified, the intensity value decimal places are limited, to reduce the output size.");
			opt.setArgName("n");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("wp", "whitepoint", true,
					"If specified, the input and target RGB images (if a colorspace transformation is requested), are "
							+ "interpreted for colorspace transformation according to the specified RGBs white point ("
							+ "default 'sRGB_D65'). Options are "
							+ "'sRGB_D65', 'AdobeRGB_D65', 'ProPhotoRGB_D50', 'eciRGBv2_D50', and 'ProPhoto2_2_5500_D55'.");
			opt.setArgName("rgb colorspace");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("xsf", "texturesourcefeature", true,
					"If specified, the input images (eventually after color transformation) are subjected to texture analysis. "
							+ "For each input image a number of texture images are created and added to the input. The following "
							+ "operation modes are supported: 'SHARPEN', 'BLUR', 'MEDIAN', 'HARLICK', 'KIRSCH', and 'ALL'. "
							+ "Use params 'texturemasksize' and 'texturesigma' to specify mask size and (e.g. for blur sigma values). "
							+ "Add '-' before the mode name (e.g. '-BLUR', to only use the texture images, and to avoid adding the "
							+ "input image intensities to the output ARFF file.");
			opt.setArgName("mode");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("xm", "texturemasksize", true, "The mask size for the texture analysis (default '3').");
			opt.setArgName("mode");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("xs", "texturesigma", true, "The sigma value, required for some of the texture analysis modes (e.g. blur, default '2.0').");
			opt.setArgName("mode");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("d", "disk", false, "If specified, the intermediate input and target image "
					+ "intensities (e.g. texture images) are saved to disk. During ARFF file generation, they are "
					+ "read from disk and not loaded into memory. By using this "
					+ "parameter, less memory is required, but more intermediate disk space.");
			opt.setArgName("mode");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("z", "maxsize", true, "Maximum size of output ARFF files in MB, if the output exceeds the specified value, "
					+ "a new output file is created, to continue the file generation. If this parameter is specified, a numeric prefix will be added "
					+ "to all output files, e.g. if the specified ARFF file name is 'result.arff', the actual output will be saved in "
					+ "'result.000.arff', 'result.001.arff', and so on. If this parameter is not specified, the output file size is not "
					+ "restricted.");
			opt.setArgName("MB");
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
	}
	
	private static void printErrorAndHelpAndExit(Options options, Exception exp) {
		HelpFormatter formatter = new HelpFormatter();
		formatter.defaultWidth = 100;
		formatter.printHelp("java -cp mcccs.jar:... workflow.ArffFromImageFileGeneratorExt -i ... -t ... -o ...",
				"MCCCS - Image-based transfer-function ARFF data file creator command",
				options,
				"Call:\njava -cp mcccs.jar:iap.jar:bio.jar:weka.jar:jfeaturelib.jar workflow.ArffFromImageFileGeneratorExt\n"
						+ "Parameters:\n"
						+ "(1) -i input.tiff -t target.tiff -o result.arff\n"
						+ "(2) -i input16bitRGB.tif -t target16bitRGB.tif -o result.arff -ics HSV -tcs HSV -si 16 -st 16");
		System.out.println();
		exp.printStackTrace();
		System.exit(1);
	}
}

class TransferOptions {
	File input;
	int maskX;
	int maskY;
	File target;
	File arffOutput;
	ColorSpaceExt targetInputColorSpace;
	ColorSpaceExt targetOutputColorSpace;
	RgbColorSpaceExt rgbColorSpace;
	float divisorFor01RangeInputFile;
	float divisorFor01RangeTargetFile;
	int selectedTargetColorSpaceForOutput;
	FeatureMode textureSourceFeatureMode;
	int textureMaskSize;
	double textureSigma;
	boolean useTempFiles;
	long maxArffFileSizeInMB;
	DecimalFormat decimalPlaceFormat;
	
	public TransferOptions(CommandLine line) {
		this.input = new File(line.getOptionValue("i"));
		this.maskX = Integer.parseInt(line.getOptionValue("w", "1"));
		this.maskY = Integer.parseInt(line.getOptionValue("h", "1"));
		this.target = new File(line.getOptionValue("t"));
		this.arffOutput = new File(line.getOptionValue("o"));
		this.targetInputColorSpace = line.getOptionValue("ics", "").isEmpty() ? null : ColorSpaceExt.valueOf(line.getOptionValue("ics", ""));
		this.targetOutputColorSpace = line.getOptionValue("tcs", "").isEmpty() ? null : ColorSpaceExt.valueOf(line.getOptionValue("tcs", ""));
		this.rgbColorSpace = RgbColorSpaceExt.valueOf(line.getOptionValue("wp", "sRGB_D65"));
		
		this.divisorFor01RangeInputFile = Float.NaN;
		this.divisorFor01RangeTargetFile = Float.NaN;
		if (line.hasOption("si")) {
			if (Double.parseDouble(line.getOptionValue("si")) > 0)
				divisorFor01RangeInputFile = (float) Math.pow(2, Double.parseDouble(line.getOptionValue("si")));
			else
				divisorFor01RangeInputFile = (float) (1 / -Double.parseDouble(line.getOptionValue("si")));
		}
		if (line.hasOption("st")) {
			if (Double.parseDouble(line.getOptionValue("st")) > 0)
				divisorFor01RangeTargetFile = (float) Math.pow(2, Double.parseDouble(line.getOptionValue("st")));
			else
				divisorFor01RangeTargetFile = (float) (1 / -Double.parseDouble(line.getOptionValue("st")));
		}
		this.selectedTargetColorSpaceForOutput = Integer.parseInt(line.getOptionValue("c", "-1"));
		
		if (line.hasOption("xsf"))
			this.textureSourceFeatureMode = ImageFeatureExtraction.FeatureMode.valueOf(line.getOptionValue("xsf", ""));
		else
			this.textureSourceFeatureMode = null;
		
		if (line.hasOption("xm"))
			this.textureMaskSize = Integer.parseInt(line.getOptionValue("xm", "3"));
		else
			this.textureMaskSize = 3;
		
		if (line.hasOption("xs"))
			this.textureSigma = Double.parseDouble(line.getOptionValue("xm", "2"));
		else
			this.textureSigma = 2.0;
		
		this.useTempFiles = line.hasOption("d");
		
		this.maxArffFileSizeInMB = Long.parseLong(line.getOptionValue("z", "-1"));
		
		int decimalPlaces = Integer.parseInt(line.getOptionValue("dp", "-1"));
		if (decimalPlaces > 0) {
			String ss = "";
			for (int i = 0; i < decimalPlaces; i++)
				ss = ss + "#";
			DecimalFormatSymbols rls = new DecimalFormatSymbols(Locale.ROOT);
			this.decimalPlaceFormat = new DecimalFormat("#." + ss, rls);
		}
		if (decimalPlaces == 0) {
			DecimalFormatSymbols rls = new DecimalFormatSymbols(Locale.ROOT);
			this.decimalPlaceFormat = new DecimalFormat("#", rls);
		}
	}
}
