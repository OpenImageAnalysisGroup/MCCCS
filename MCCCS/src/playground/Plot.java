package playground;

import java.io.File;
import java.io.IOException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;

import de.ipk.ag_ba.image.structures.Image;
import workflow.Settings;

/**
 * @author klukas
 */
public class Plot {
	public static void main(String[] args) throws IOException, Exception {
		new Settings(); // initialize some static variables
		CommandLineParser parser = new GnuParser();
		Options options = new Options();
		setupOptions(options);
		try {
			CommandLine line = parser.parse(options, args);
			PlotOptions po = new PlotOptions(line);
			float[][] res = new float[po.w][po.h];
			double stepX = 1 / (double) po.w * (po.xe - po.xs);
			double stepY = 1 / (double) po.h * (po.ye - po.ys);
			for (int xp = 0; xp < po.w; xp++) {
				for (int yp = 0; yp < po.h; yp++) {
					double x = xp / (double) po.w * (po.xe - po.xs) + po.xs;
					double y = (po.h - yp) / (double) po.h * (po.ye - po.ys) + po.ys;
					
					res[xp][yp] = 1;
					// double intensity = Math.abs(x * x + y * y);
					int s = 50;
					for (int osx = 0; osx < s; osx++)
						for (int osy = 0; osy < s; osy++) {
							double xF = x + stepX * osx / s;
							double yF = y + stepY * osy / s;
							double intensity = Math.min(Math.abs(Math.sin(Math.tan(xF)) - yF) * 20, 1);
							res[xp][yp] = Math.min((float) intensity, res[xp][yp]);
						}
				}
			}
			new Image(res).saveToFile(po.target.getAbsolutePath());
		} catch (Exception exp) {
			printErrorAndHelpAndExit(options, exp);
		}
	}
	
	private static void setupOptions(Options options) {
		{
			Option opt = new Option("w", "width", true, "width of result file");
			opt.setArgName("width");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("h", "height", true, "height of result file");
			opt.setArgName("height");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("xs", "startx", true, "start x");
			opt.setArgName("x-axis");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("xe", "endx", true, "end x");
			opt.setArgName("x-axis");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("ys", "starty", true, "start y");
			opt.setArgName("y-axis");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("ye", "endy", true, "endy x");
			opt.setArgName("y-axis");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("o", "outputfile", true, "result image file");
			opt.setArgName("result file");
			opt.setRequired(true);
			options.addOption(opt);
		}
	}
	
	private static void printErrorAndHelpAndExit(Options options, Exception exp) {
		HelpFormatter formatter = new HelpFormatter();
		formatter.defaultWidth = 100;
		formatter.printHelp("java -cp mcccs.jar:... playground.Plot -i ... -t ... -o ...",
				"PLOT - XY-Plotter",
				options,
				"Call:\njava -cp mcccs.jar:iap.jar:bio.jar:weka.jar:jfeaturelib.jar playground.Plot\n"
						+ "Parameters: -w 320 -h 200 -o image.tif");
		System.out.println();
		exp.printStackTrace();
		System.exit(1);
	}
}

class PlotOptions {
	int w, h;
	double xs, xe, ys, ye;
	
	File target;
	
	public PlotOptions(CommandLine line) {
		this.w = Integer.parseInt(line.getOptionValue("w"));
		this.h = Integer.parseInt(line.getOptionValue("h"));
		this.xs = Double.parseDouble(line.getOptionValue("xs"));
		this.ys = Double.parseDouble(line.getOptionValue("ys"));
		this.xe = Double.parseDouble(line.getOptionValue("xe"));
		this.ye = Double.parseDouble(line.getOptionValue("ye"));
		this.target = new File(line.getOptionValue("o"));
	}
}
