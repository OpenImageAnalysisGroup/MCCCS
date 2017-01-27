package workflow;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import org.graffiti.plugin.io.resources.FileSystemHandler;

import de.ipk.ag_ba.image.structures.Image;

/**
 * Shift input image in X/Y direction and sample data. Create summary ARFF output file with sampled input data around each pixel and a last output column from
 * the target image file (gray scale).
 * 
 * @param input
 *           input file (gray scale)
 * @param mask
 *           size X
 *           mask size in x direction
 * @param mask
 *           size Y
 *           mask size in y direction
 * @param target
 *           input file (gray scale)
 * @param output
 *           ARFF file
 *           the result file name
 * @return summary ARFF file
 * @author Christian Klukas
 */
public class CreateTransferDataset {
	
	public static void main(String[] args) throws IOException, Exception {
		{
			new Settings();
		}
		
		if (args == null || args.length != 5) {
			System.err.println("Params: [input grayscale image] [target grayscale image] [output ARFF file] ! Return Code 1");
			System.exit(1);
		} else {
			File input = new File(args[0]);
			int maskX = Integer.parseInt(args[1]);
			int maskY = Integer.parseInt(args[2]);
			File target = new File(args[3]);
			File arffOutput = new File(args[4]);
			if (!input.exists()) {
				System.err.println("Input image file '" + input.getName() + "' could not be found! Return Code 2");
				System.exit(2);
			} else {
				if (!target.exists()) {
					System.err.println("Input target file '" + target.getName() + "' could not be found! Return Code 3");
					System.exit(3);
				} else {
					Image inputImg = new Image(FileSystemHandler.getURL(input));
					Image targetImg = new Image(FileSystemHandler.getURL(target));
					
					float[][] inputF = inputImg.getAs2Afloat();
					float[][] targetF = targetImg.getAs2Afloat();
					
					inputImg = null;
					targetImg = null;
					
					int startX = -maskX / 2;
					int endX = maskX / 2;
					int startY = -maskY / 2;
					int endY = maskY / 2;
					
					PrintWriter out = null;
					try {
						out = new PrintWriter(new OutputStreamWriter(new BufferedOutputStream(new FileOutputStream(arffOutput)), "UTF-8"));
						out.println("@RELATION " + arffOutput.getName());
						for (int xs = startX; xs <= endX; xs++) {
							for (int ys = startY; ys <= endY; ys++) {
								String xid = xs < 0 ? "M" + (-xs) : "P" + xs;
								String yid = ys < 0 ? "M" + (-ys) : "P" + ys;
								out.println("@ATTRIBUTE " + xid + "_" + yid + " NUMERIC");
							}
						}
						out.println("@ATTRIBUTE target NUMERIC");
						out.println("@data");
						int w = inputF.length;
						int h = inputF[0].length;
						for (int x = 0; x < w; x++) {
							for (int y = 0; y < h; y++) {
								boolean content = false;
								for (int xs = x + startX; xs <= x + endX; xs++) {
									for (int ys = y + startY; ys <= y + endY; ys++) {
										if (content)
											out.print(",");
										if (xs >= 0 && ys >= 0 && xs < w && ys < h)
											out.print(inputF[xs][ys]);
										else
											out.print("?");
										
										content = true;
									}
								}
								float targetValue = targetF[x][y];
								out.print(",");
								out.println(targetValue);
							}
						}
					} finally {
						if (out != null) {
							out.flush();
							out.close();
						}
					}
				}
			}
		}
	}
}
