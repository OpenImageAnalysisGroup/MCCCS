package cmds;

import java.io.File;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.StringManipulationTools;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;

import de.ipk.ag_ba.image.structures.Image;
import ij.io.Opener;
import ij.process.ImageProcessor;
import loci.formats.ChannelSeparator;
import loci.plugins.util.ImageProcessorReader;
import loci.plugins.util.LociPrefs;

/**
 * @author Christian Klukas
 */
public class SplitTiff {
	
	public static void main(String[] args) {
		CommandLineParser parser = new GnuParser();
		Options options = new Options();
		
		setupOptions(options);
		try {
			CommandLine line = parser.parse(options, args);
			SplitOptions to = new SplitOptions(line);
			
			ImageProcessorReader r = new ImageProcessorReader(new ChannelSeparator(LociPrefs.makeImageReader()));
			
			try (DirectoryStream<Path> dirStream = Files.newDirectoryStream(
					Paths.get(System.getProperty("user.dir")), to.input)) {
				dirStream.forEach(inp -> {
					try {
						
						r.setId(inp.toAbsolutePath().toString());
						
						Opener oo = new Opener();
						oo.setSilentMode(true);
						
						int count = r.getImageCount();
						int nnn = 1;
						if (count > 9)
							nnn = 2;
						if (count > 99)
							nnn = 3;
						
						for (int idx = 0; idx < count; idx++) {
							if (to.selectedTargetColorSpaceForOutput >= 0 && to.selectedTargetColorSpaceForOutput != idx)
								continue;
							ImageProcessor ip = r.openProcessors(idx)[0];
							String name = to.output;
							name = StringManipulationTools.stringReplace(name, "$N", StringManipulationTools.removeFileExtension(inp.toFile().getName()));
							name = StringManipulationTools.stringReplace(name, "$C", StringManipulationTools.formatNumberAddZeroInFront(idx + 1, nnn));
							new Image(ip).saveToFile(new File(name).getAbsolutePath());
						}
						
					} catch (Exception err) {
						printErrorAndHelpAndExit(options, err);
					}
				});
			}
			
			r.close();
		} catch (Exception err) {
			printErrorAndHelpAndExit(options, err);
		}
	}
	
	private static void printErrorAndHelpAndExit(Options options, Exception exp) {
		HelpFormatter formatter = new HelpFormatter();
		formatter.defaultWidth = 100;
		formatter.printHelp("java -jar split.jar -i ... -o ...",
				"MCCCS - Split Tiff Command", options,
				"Call:\njava -jar split.jar\n"
						+ "Example:\n" + "(1) -i input.tiff -t $P/$N_$C.tiff -o result.tiff");
		System.out.println();
		exp.printStackTrace();
		System.exit(1);
	}
	
	private static void setupOptions(Options options) {
		{
			Option opt = new Option("i", "inputfile", true,
					"Input image file mask (multi-channel tiff).");
			opt.setArgName("image file search mask");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("o", "outputfile", true,
					"Output tiff file name mask. $P specifies path of input file. $N specifies input file name without extension. $C specifies input channel index (1...n).");
			opt.setArgName("output file");
			opt.setRequired(true);
			options.addOption(opt);
		}
		{
			Option opt = new Option("c", "outputchannel", true,
					"If specified, only one of the output channels is saved (e.g. 0 for the first channel).");
			opt.setArgName("channel-index");
			opt.setRequired(false);
			opt.setOptionalArg(true);
			options.addOption(opt);
		}
	}
}

class SplitOptions {
	String input;
	String output;
	int selectedTargetColorSpaceForOutput;
	
	public SplitOptions(CommandLine line) {
		this.input = line.getOptionValue("i");
		this.output = line.getOptionValue("o");
		this.selectedTargetColorSpaceForOutput = Integer.parseInt(line.getOptionValue("c", "-1"));
	}
}