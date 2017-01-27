package workflow;

import ij.CompositeImage;
import ij.ImageStack;

import java.io.File;
import java.io.IOException;

import org.graffiti.plugin.io.resources.FileSystemHandler;

import de.ipk.ag_ba.image.operation.channels.Channel;
import de.ipk.ag_ba.image.structures.Image;
import de.ipk.ag_ba.image.structures.ImageType;

/**
 * Splits RGB image into separate channel images.
 * 
 * @return channel0.png, channel1.png, channel2.png or .tif files.
 * @param image
 * @author Christian Klukas
 */
public class SplitRGB {
	public static void main(String[] args) throws IOException, Exception {
		{
			new Settings();
		}
		if (args == null || args.length == 0) {
			System.err.println("No filenames provided as parameters! Return Code 1");
			System.exit(1);
		} else {
			for (String a : args) {
				File f = new File(a);
				if (!f.exists()) {
					System.err.println("File '" + a + "' could not be found! Return Code 2");
					System.exit(2);
				} else {
					// get file type
					// String name = f.getName();
					String f_ending = "tif"; // name.split("\\.")[1];
					Image i = new Image(FileSystemHandler.getURL(f));
					if (f_ending.toLowerCase().equals("tif") || f_ending.toLowerCase().equals("tiff")) {
						if ((i.getStoredImage() instanceof CompositeImage) && ((CompositeImage) i.getStoredImage()).getNChannels() == 3) {
							CompositeImage ci = (CompositeImage) i.getStoredImage();
							ImageStack is = ci.getImageStack();
							new Image(is.getProcessor(1)).saveToFile(
									f.getParent() + File.separator + "channel_rgb_r." + f_ending, ImageType.GRAY32);
							new Image(is.getProcessor(2)).saveToFile(
									f.getParent() + File.separator + "channel_rgb_g." + f_ending, ImageType.GRAY32);
							new Image(is.getProcessor(3)).saveToFile(
									f.getParent() + File.separator + "channel_rgb_b." + f_ending, ImageType.GRAY32);
						} else {
							i.io().channels().get(Channel.RGB_R).getImage().saveToFile(f.getParent() + File.separator + "channel_rgb_r." + f_ending, ImageType.GRAY32);
							i.io().channels().get(Channel.RGB_G).getImage().saveToFile(f.getParent() + File.separator + "channel_rgb_g." + f_ending, ImageType.GRAY32);
							i.io().channels().get(Channel.RGB_B).getImage().saveToFile(f.getParent() + File.separator + "channel_rgb_b." + f_ending, ImageType.GRAY32);
						}
					} else {
						i.io().channels().get(Channel.RGB_R).getImage().saveToFile(f.getParent() + File.separator + "channel_rgb_r." + f_ending);
						i.io().channels().get(Channel.RGB_G).getImage().saveToFile(f.getParent() + File.separator + "channel_rgb_g." + f_ending);
						i.io().channels().get(Channel.RGB_B).getImage().saveToFile(f.getParent() + File.separator + "channel_rgb_b." + f_ending);
					}
				}
			}
		}
	}
}
