package workflow;

import java.io.File;

import org.graffiti.plugin.io.resources.FileSystemHandler;
import org.graffiti.plugin.io.resources.IOurl;

import de.ipk.ag_ba.image.structures.Image;
import tools.ARFFProcessor;

/**
 * Converts classified ARFF result file (including pixel-probabilities for each class) to an grayscale-image.
 * 
 * @param input
 *           filename(s) of ARFF file(s)
 * @return gray-scale images and binary masks for provided classes (from arff file), file name postfix depends on class names in arff.
 * @author Christian Klukas
 */
public class ArffToProbabilityImageFileGenerator2 {
	public static void main(String[] args) throws Exception {
		{
			new Settings(true);
		}
		if (args == null || args.length != 2) {
			System.err.println("No [mask image name] and [arff file] provided as parameter(s)! Return Code 1");
			System.exit(1);
		} else {
			IOurl url = FileSystemHandler.getURL(new File(args[0]));
			Image mask = new Image(url);
			ARFFProcessor ac = new ARFFProcessor();
			ac.convertArffToImageMultiLabelFloatImage2(args[1], mask.getWidth(), mask.getHeight());
		}
	}
}