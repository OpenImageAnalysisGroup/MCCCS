package mnist_io;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.PrintWriter;

import javax.imageio.ImageIO;

import org.StringManipulationTools;

/**
 * @author klukas
 */
public class mnist2arff {
	public static void main(String args[]) throws Exception {
		FileInputStream inImage = new FileInputStream(args[0]);
		FileInputStream inLabel = new FileInputStream(args[1]);
		
		@SuppressWarnings("unused")
		int magicNumberImages = (inImage.read() << 24) | (inImage.read() << 16) | (inImage.read() << 8) | (inImage.read());
		int numberOfImages = (inImage.read() << 24) | (inImage.read() << 16) | (inImage.read() << 8) | (inImage.read());
		int numberOfRows = (inImage.read() << 24) | (inImage.read() << 16) | (inImage.read() << 8) | (inImage.read());
		int numberOfColumns = (inImage.read() << 24) | (inImage.read() << 16) | (inImage.read() << 8) | (inImage.read());
		
		@SuppressWarnings("unused")
		int magicNumberLabels = (inLabel.read() << 24) | (inLabel.read() << 16) | (inLabel.read() << 8) | (inLabel.read());
		int numberOfLabels = (inLabel.read() << 24) | (inLabel.read() << 16) | (inLabel.read() << 8) | (inLabel.read());
		
		BufferedImage image = new BufferedImage(numberOfColumns, numberOfRows, BufferedImage.TYPE_INT_ARGB);
		int numberOfPixels = numberOfRows * numberOfColumns;
		int[] imgPixels = new int[numberOfPixels];
		int[] label2cnt = new int[10];
		
		System.out.println("Number of images: " + numberOfImages);
		System.out.println("Image dimension : " + numberOfRows + "x" + numberOfColumns);
		System.out.println("Number of labels: " + numberOfLabels);
		
		PrintWriter pw = new PrintWriter(new FileWriter(args[3]));
		pw.write("@relation " + args[4] + System.lineSeparator());
		for (int y = 0; y < numberOfRows; y++)
			for (int x = 0; x < numberOfColumns; x++)
				pw.write("@ATTRIBUTE " + x + "_" + y + "  NUMERIC" + System.lineSeparator());
			
		pw.write("@ATTRIBUTE class {0,1,2,3,4,5,6,7,8,9}" + System.lineSeparator());
		pw.write("@DATA" + System.lineSeparator());
		
		for (int i = 0; i < numberOfImages; i++) {
			if (i % 1000 == 0)
				System.out.println("Number of images extracted: " + i);
			
			for (int p = 0; p < numberOfPixels; p++) {
				int gray = 255 - inImage.read();
				imgPixels[p] = 0xFF000000 | (gray << 16) | (gray << 8) | gray;
				
				pw.write(gray + "");
				pw.write(",");
			}
			
			image.setRGB(0, 0, numberOfColumns, numberOfRows, imgPixels, 0, numberOfColumns);
			int label = inLabel.read();
			
			pw.write(label + "");
			pw.write(System.lineSeparator());
			
			label2cnt[label]++;
			File outputfile = new File(args[2] + File.separator + label + "_" + StringManipulationTools.formatNumberAddZeroInFront(label2cnt[label], 5) + ".png");
			ImageIO.write(image, "png", outputfile);
		}
		
		pw.close();
		inImage.close();
		inLabel.close();
	}
}
