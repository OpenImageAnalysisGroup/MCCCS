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
	
	FileReader intensityReadingFr = null;
	BufferedReader intensityReadingBr = null;
	boolean intensityReadingDataAvailable = false;
	long intensityReadingLine = -1;
	
	public ImageArff(Image image, String datasetName, String intensityName, File templocation) throws IOException {
		w = image.getWidth();
		h = image.getHeight();
		
		String attributes = "@attribute " + intensityName + "\tNUMERIC" + System.lineSeparator();
		
		String header = "%" + System.lineSeparator() + "@relation '" + datasetName + "'" + System.lineSeparator() + attributes
				+ "@data" + System.lineSeparator();
		
		float[] intensity = image.getAs1float();
		
		int width = image.getWidth();
		int height = image.getHeight();
		
		String line = "";
		File tf = File.createTempFile("mcccs_", ".arff", templocation);
		tf.deleteOnExit();
		content_tempFile = new File("");
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
		return new Image(h, w, px);
	}
	
	public int getWidth() {
		return w;
	}
	
	public int getHeight() {
		return h;
	}
	
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
	
	/**
	 * Reads the input file. If the lineIndex is greater than the current position,
	 * a number of lines are read and skipped. If the expected line is smaller than the
	 * current position, the file is closed and read again from the beginning (navigation
	 * in text file is only possible line by line, forward, storing the line positions would
	 * create an memory overhead that is comparable to just reading the file content fully,
	 * which needs to be avoided in this context).
	 * 
	 * @param lineIndex
	 *           If negative, the next data line is read. Otherwise the specified data line.
	 * @return The desired line or the next one (depending on lineIndex).
	 * @throws IOException
	 */
	public String getIntensityValue(long lineIndex) throws IOException {
		String line = null;
		if (lineIndex >= 0 && lineIndex <= intensityReadingLine) {
			// start reading again from begin
			finalizeGetIntensityReading();
			prepareGetIntensityReading();
		}
		if ((line = intensityReadingBr.readLine()) != null) {
			if (intensityReadingDataAvailable && !line.startsWith("%")) {
				intensityReadingLine++;
				if (intensityReadingLine == lineIndex || lineIndex < 0)
					return line;
			}
		}
		return null;
	}
	
	private float backgroundAnalysisExpectedBackgroundValue = Float.NaN;
	// once a background value has been detected, do not parse the string any more, but
	// compare only the strings with the detectedBackgroundString.
	private String detectedBackgroundString = null;
	
	public void setExpectedBackgroundValue(float background) {
		backgroundAnalysisExpectedBackgroundValue = background;
	}
	
	public boolean isNextLineBackground() throws IOException {
		String currentLine = getIntensityValue(-1);
		//if (detectedBackgroundString == null) {
			float val = Float.parseFloat(currentLine);

//			if(val == 3.4028235E38f)
//				if (new Float(val).compareTo((float) (3.4028235E38f)) == 0)
//					System.out.println(val);
			
			//if (new Float(val).compareTo((float) (3.4028235E38f)) != 0)
			//	System.out.println("b");
			
			// TODO detect arbitrary background values
			if (val == backgroundAnalysisExpectedBackgroundValue || new Float(val).compareTo((float) (3.4028235E38f)) == 0 || new Float(val).compareTo((float) (0.0)) == 0) {
				detectedBackgroundString = currentLine;
				return true;
			}
			
		//} else {
			// If background has been detected once, Float.parse does not need
			// to be performed any more. The strings are compared directly (assumption
			// is, that the string representation for the same value is the same for
			// all according lines in the input file).
		//	if (detectedBackgroundString.equals(currentLine))
		//		return true;
		//}
		return false;
	}
}
