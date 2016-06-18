package workflow;

import java.io.File;
import java.io.IOException;

import org.graffiti.plugin.io.resources.FileSystemHandler;

import de.ipk.ag_ba.image.structures.Image;

/**
 * Create Bayer patterned image file (gray scale).
 * input: R/G/B image files
 * output: bayer_pattern image (tiff)
 * 
 * @author Christian Klukas
 */
public class RGB2Bayer {
	
	public static void main(String[] args) throws IOException, Exception {
		{
			new Settings();
		}
		if (args == null || args.length != 5) {
			System.err.println("Params: [r] [g] [b] [RGB-Pattern, e.g. RGGB] [target file] ! Return Code 1");
			System.exit(1);
		} else {
			File f_r = new File(args[0]);
			File f_g = new File(args[1]);
			File f_b = new File(args[2]);
			if (!f_r.exists()) {
				System.err.println("File RGB - R '" + f_r.getName() + "' could not be found! Return Code 2");
				System.exit(2);
			}
			if (!f_g.exists()) {
				System.err.println("File RGB - G '" + f_g.getName() + "' could not be found! Return Code 2");
				System.exit(2);
			}
			if (!f_b.exists()) {
				System.err.println("File RGB - B '" + f_b.getName() + "' could not be found! Return Code 2");
				System.exit(2);
			}
			Image r = new Image(FileSystemHandler.getURL(f_r));
			Image g = new Image(FileSystemHandler.getURL(f_g));
			Image b = new Image(FileSystemHandler.getURL(f_b));
			int width = r.getWidth();
			if (g.getWidth() != width || b.getWidth() != width) {
				System.err.println("R/G/B image widths differ! Return Code 3");
				System.exit(3);
			}
			float[] rf = r.getAs1float();
			float[] gf = g.getAs1float();
			float[] bf = b.getAs1float();
			float[][] rgb = new float[3][];
			rgb[0] = rf;
			rgb[1] = gf;
			rgb[2] = bf;
			int[] rgbIndex = new int[4];
			
			{
				if (args[3].length() != 4) {
					System.err.println("Invalid pattern (length) '" + args[3] + "'. Specify 'RGGB' or similar pattern! Return Code 5");
					System.exit(4);
				}
				int pidx = 0;
				for (char p : args[3].toUpperCase().toCharArray()) {
					if (p == 'R') {
						rgbIndex[pidx++] = 0;
						continue;
					}
					if (p == 'G') {
						rgbIndex[pidx++] = 1;
						continue;
					}
					if (p == 'B') {
						rgbIndex[pidx++] = 2;
						continue;
					}
					System.err.println("Invalid pattern character '" + p + "'! Return Code 4");
					System.exit(4);
				}
			}
			
			float[] res = new float[rf.length];
			int y = -1;
			for (int i = 0; i < rf.length; i++) {
				if (i % width == 0)
					y++;
				res[i] = rgb[rgbIndex[(i % 2) + y % 2 + y % 2]][i];
			}
			new Image(r.getWidth(), r.getHeight(), res).saveToFile(args[4]);
		}
	}
}
