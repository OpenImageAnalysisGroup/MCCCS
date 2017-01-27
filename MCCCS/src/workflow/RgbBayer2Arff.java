package workflow;

import ij.CompositeImage;
import ij.ImageStack;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.graffiti.plugin.io.resources.FileSystemHandler;

import de.ipk.ag_ba.image.operation.channels.Channel;
import de.ipk.ag_ba.image.structures.Image;

/**
 * Converts RGB image (Bayer pattern) to an ARFF file.
 * 
 * @param R/G/B
 *           image files
 * @param bayer
 *           pattern
 * @return one 'output.arff'
 * @author Christian Klukas
 */
public class RgbBayer2Arff {
	public static void main(String[] args) throws IOException, Exception {
		{
			new Settings();
		}
		if (args == null || args.length == 0) {
			System.err.println("No filenames provided as parameters! Return Code 1");
			System.exit(1);
		} else {
			int[] rgbIndex = new int[4];
			
			{
				if (args[0].length() != 4) {
					System.err.println("Invalid pattern (length) '" + args[3] + "'. Specify 'RGGB' or similar pattern! Return Code 2");
					System.exit(2);
				}
				int pidx = 0;
				for (char p : args[0].toUpperCase().toCharArray()) {
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
					System.err.println("Invalid pattern character '" + p + "'! Return Code 3");
					System.exit(3);
				}
			}
			
			String attributes = "";
			
			attributes += "@attribute P\t{P0,P1,P2}" + System.lineSeparator();
			attributes += "@attribute O\t{O0,O1,O2,O3}" + System.lineSeparator();
			
			for (String id : new String[] {
					"I1", "I2", "I3", "I4", "I5",
					"I6", "I7", "I8", "I9", "I10",
					"I11", "I12", "I13", "I14", "I15",
					"I16", "I17", "I18", "I19", "I20",
					"I21", "I22", "I23", "I24", "I25",
					"R", "G", "B" })
				attributes += "@attribute " + id + "\tNUMERIC" + System.lineSeparator();
			
			String header = "%" + System.lineSeparator() + "@relation 'BAYERTEST'" + System.lineSeparator() + attributes
					+ "@data" + System.lineSeparator();
			
			String fn = new File(args[1]).getParent() + "/output.arff";
			
			try (FileWriter fw = new FileWriter(new File(fn), false)) {
				fw.write(header);
				boolean first = true;
				for (String a : args) {
					if (first) {
						first = false;
						continue;
					}
					File f = new File(a);
					if (!f.exists()) {
						System.err.println("File '" + a + "' could not be found! Return Code 2");
						System.exit(2);
					} else {
						float[] rf, gf, bf;
						Image img = new Image(FileSystemHandler.getURL(f));
						String name = f.getName();
						String f_ending = name.split("\\.")[1];
						if (f_ending.toLowerCase().equals("tif") || f_ending.toLowerCase().equals("tiff")) {
							if ((img.getStoredImage() instanceof CompositeImage) && ((CompositeImage) img.getStoredImage()).getNChannels() == 3) {
								CompositeImage ci = (CompositeImage) img.getStoredImage();
								ImageStack is = ci.getImageStack();
								rf = new Image(is.getProcessor(1).convertToFloat()).getAs1float();
								gf = new Image(is.getProcessor(2).convertToFloat()).getAs1float();
								bf = new Image(is.getProcessor(3).convertToFloat()).getAs1float();
							} else {
								rf = img.io().channels().get(Channel.RGB_R).getImage().getAs1float();
								gf = img.io().channels().get(Channel.RGB_G).getImage().getAs1float();
								bf = img.io().channels().get(Channel.RGB_B).getImage().getAs1float();
							}
						} else {
							rf = img.io().channels().get(Channel.RGB_R).getImage().getAs1float();
							gf = img.io().channels().get(Channel.RGB_G).getImage().getAs1float();
							bf = img.io().channels().get(Channel.RGB_B).getImage().getAs1float();
						}
						int w = img.getWidth();
						int h = img.getHeight();
						float[][] inpRGB = new float[3][];
						inpRGB[0] = rf;
						inpRGB[1] = gf;
						inpRGB[2] = bf;
						for (int x = 0; x < w; x++) {
							for (int y = 0; y < h; y++) {
								int i = y * w + x;
								StringBuilder sb = new StringBuilder();
								int pii = i % 2 + y % 2 + y % 2;
								sb.append("P" + rgbIndex[pii] + "\tO" + (pii));
								for (int offx = -2; offx <= 2; offx++) {
									for (int offy = -2; offy <= 2; offy++) {
										int xx = x + offx;
										int yy = y + offy;
										int offii = yy * w + xx;
										if (xx < 0 || yy < 0 || xx >= w || yy >= h) {
											sb.append("\t?");
										} else {
											float fiii = inpRGB[rgbIndex[pii]][offii];
											sb.append("\t" + fiii);
										}
									}
								}
								int idx = y * w + x;
								sb.append("\t" + rf[idx] + "\t" + gf[idx] + "\t" + bf[idx]);
								if (Math.random() < 0.1)
									fw.write(sb.toString() + System.lineSeparator());
							}
						}
					}
					fw.write("%");
				}
			}
		}
	}
}
