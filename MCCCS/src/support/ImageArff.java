package support;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import de.ipk.ag_ba.image.structures.Image;

/**
 * @author klukas
 */
public class ImageArff {
	
	File content_tempFile = null;
	
	int w = -1;
	int h = -1;
	
	public ImageArff(Image image, String datasetName, String intensityName) throws IOException {
		w = image.getWidth();
		h = image.getHeight();
		
		String attributes = "@attribute " + intensityName + "\tNUMERIC" + System.lineSeparator();
		
		String header = "%" + System.lineSeparator() + "@relation '" + datasetName + "'" + System.lineSeparator() + attributes
				+ "@data" + System.lineSeparator();
		
		float[] intensity = image.getAs1float();
		
		int width = image.getWidth();
		int height = image.getHeight();
		
		String line = "";
		File tf = File.createTempFile("mcccs_", ".arff");
		content_tempFile.deleteOnExit();
		try (FileWriter fw = new FileWriter(tf, false)) {
			fw.write(header);
			for (int x = 0; x < width; x++) {
				for (int y = 0; y < height; y++) {
					line += intensity[x + y * width];
					
					if (line.length() > 0) {
						// appends the string to the file
						fw.write(line + System.lineSeparator());
						line = "";
					}
				}
			}
			fw.write("%");
		}
		content_tempFile = tf;
	}
	
	public Image getImage() throws IOException {
		float[] px = new float[w * h];
		try (
				FileReader fr = new FileReader(content_tempFile);
				BufferedReader br = new BufferedReader(fr)) {
			boolean dataAvailable = false;
			String line;
			int idx = 0;
			while ((line = br.readLine()) != null) {
				if (line.startsWith("@data"))
					dataAvailable = true;
				else {
					if (dataAvailable && !line.startsWith("%")) {
						px[idx++] = Float.parseFloat(line);
					}
				}
			}
		}
		return new Image(w, h, px);
	}
	
	public int getWidth() {
		return w;
	}
	
	public int getHeight() {
		return h;
	}
	
	FileReader intensityReadingFr = null;
	BufferedReader intensityReadingBr = null;
	boolean intensityReadingDataAvailable = false;
	long intensityReadingLine = -1;
	
	public void prepareGetIntensityReading() throws IOException {
		
		intensityReadingFr = new FileReader(content_tempFile);
		intensityReadingBr = new BufferedReader(intensityReadingFr);
		
		String line;
		while ((line = intensityReadingBr.readLine()) != null) {
			if (line.startsWith("@data")) {
				intensityReadingDataAvailable = true;
				break;
			}
		}
	}
	
	public void finalizeGetIntensityReading() throws IOException {
		intensityReadingBr.close();
		intensityReadingFr.close();
		intensityReadingDataAvailable = false;
		intensityReadingLine = -1;
	}
	
	public String getIntensityValue(long lineIndex) throws IOException {
		String line = null;
		if (lineIndex <= intensityReadingLine) {
			// start reading again from begin
			finalizeGetIntensityReading();
			prepareGetIntensityReading();
		}
		if ((line = intensityReadingBr.readLine()) != null) {
			if (intensityReadingDataAvailable && !line.startsWith("%")) {
				intensityReadingLine++;
				if (intensityReadingLine == lineIndex)
					return line;
			}
		}
		return null;
	}
}
