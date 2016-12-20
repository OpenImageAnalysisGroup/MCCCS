package support;

import java.io.File;
import java.io.IOException;
import java.util.BitSet;
import java.util.Collection;
import java.util.LinkedHashMap;

import org.GapList;

import de.ipk.ag_ba.image.structures.Image;
import de.ipk.ag_ba.image.structures.ImageStack;

/**
 * @author klukas
 */
public class ImageStackAsARFF {
	
	private LinkedHashMap<String, ImageArff> fileName2image = new LinkedHashMap<>();
	
	public ImageStackAsARFF() {
		// empty
	}
	
	public ImageStackAsARFF(ImageStack convertThisStack, String datasetName, File templocation) throws IOException {
		for (int idx = 0; idx < convertThisStack.size(); idx++) {
			Image img = convertThisStack.getImage(idx);
			String lbl = convertThisStack.getLabels()[idx];
			ImageArff ia = new ImageArff(img, datasetName, lbl, templocation);
			fileName2image.put(ia.content_tempFile.getAbsolutePath(), ia);
		}
	}
	
	public void show(String title) throws IOException {
		show(title, true);
	}
	
	public void show(String title, boolean doIt) throws IOException {
		if (!doIt)
			return;
		ImageStack is = new ImageStack();
		for (String fn : fileName2image.keySet()) {
			is.addImage(fn, fileName2image.get(fn).getImage());
		}
		if (is.size() > 0)
			is.show(title);
	}
	
	public void addImage(String fileName, ImageArff imageArff) {
		fileName2image.put(fileName, imageArff);
	}
	
	public String[] getLabels() {
		return fileName2image.keySet().toArray(new String[] {});
	}
	
	public int size() {
		return fileName2image.size();
	}
	
	public ImageArff getProcessor(int i) {
		return fileName2image.get(getLabels()[i]);
	}
	
	public Collection<ImageArff> values() {
		return fileName2image.values();
	}
	
	public void deleteSlice(int i) {
		String lbl = getLabels()[i - 1];
		fileName2image.get(lbl).content_tempFile.delete();
		fileName2image.remove(lbl);
	}
	
	public String getImageLabel(int i) {
		return getLabels()[i - 1];
	}
	
	public int getWidth() {
		return fileName2image.values().iterator().next().w;
	}
	
	public int getHeight() {
		return fileName2image.values().iterator().next().h;
	}
	
	public int getBands() {
		return fileName2image.size();
	}
	
	public void lookForValidSamples(GapList<Integer> sampleList, float backgroundValue) throws IOException {
		int width = getWidth();
		int height = getHeight();
		
		BitSet isBackgroundLine = getIsBackgroundStatusForLines(backgroundValue);
		
		for (int line = 0; line < width * height; line++) {
			boolean isb = isBackgroundLine.get(line);
			if (!isb) {
				sampleList.add(line);
			}
		}
	}
	
	private BitSet getIsBackgroundStatusForLines(float backgroundValue) throws IOException {
		BitSet result = new BitSet(getWidth() * getHeight());
		String[] fna = fileName2image.keySet().toArray(new String[] {});

		int bands = getBands();
		for (int band = 0; band < bands; band++) {
			fileName2image.get(fna[band]).prepareGetIntensityReading();
			fileName2image.get(fna[band]).setExpectedBackgroundValue(backgroundValue);
		}
		for (int line = 0; line < getWidth() * getHeight(); line++) {
			int numDetectedBgInChannelImagesLine = 0;
			for (int band = 0; band < bands; band++) {				
				if (fileName2image.get(fna[band]).isNextLineBackground())
					numDetectedBgInChannelImagesLine++;
			}
			result.set(line, numDetectedBgInChannelImagesLine == bands);
		}
		for (int band = 0; band < bands; band++) {
			fileName2image.get(fna[band]).finalizeGetIntensityReading();
		}
		return result;
	}
	
	public void deleteArffFilesOnceJvmQuits() {
		for (String fileName : fileName2image.keySet())
			new File(fileName).deleteOnExit();
	}
	
	public void deleteLastSlice() {
		fileName2image.remove(fileName2image.keySet().toArray(new String[] {})[fileName2image.size() - 1]);
	}
	
	public String getFileName(int idx) {
		return fileName2image.keySet().toArray(new String[] {})[idx];
	}
	
	public void prepareGetIntensityReading() throws IOException {
		for (ImageArff ia : fileName2image.values())
			ia.prepareGetIntensityReading();
	}
	
	public void finalizeGetIntensityReading() throws IOException {
		for (ImageArff ia : fileName2image.values())
			ia.finalizeGetIntensityReading();
	}
	
	public String getIntensityValue(int lineIndex) throws IOException {
		StringBuilder sb = new StringBuilder();
		String[] fna = fileName2image.keySet().toArray(new String[] {});
		for (int b = 0; b < fileName2image.size(); b++) {
			String fn = fna[b];
			ImageArff img = fileName2image.get(fn);
			if (sb.length() > 0)
				sb.append(",");
			String temp = "null";

			while ("null".contentEquals(temp)) {
				temp = img.getIntensityValue(lineIndex);
				if (temp == null)
					temp = "null";
			}

			String intensity = temp;
			sb.append(intensity);
//			sb.append(img.getIntensityValue(lineIndex));
		}
		return sb.toString();
	}
}
