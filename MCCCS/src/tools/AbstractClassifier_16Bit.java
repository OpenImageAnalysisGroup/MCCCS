package tools;

import ij.process.ByteProcessor;
import ij.process.ImageProcessor;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import support.ImageArff;
import support.ImageStackAsARFF;
import de.ipk.ag_ba.image.structures.Image;
import de.ipk.ag_ba.image.structures.ImageStack;

public abstract class AbstractClassifier_16Bit {
	protected final boolean debug = false;
	protected float background_16bit = 0f;
	
	protected int numberOfClasses = 0;
	
	// public abstract void createSampleData(ImageStack[] isl, File outputPathForArrfFile, int numberofsamples)
	// throws Exception;
	
	public abstract void createSampleDataFromArff(ImageStackAsARFF[] isl, File outputPathForArrfFile, int numberofsamples) throws InterruptedException,
			IOException;
	
	protected ImageStackAsARFF applyMasks(ImageStackAsARFF imgst, ImageStackAsARFF maskst, boolean removeFromStack, File templocation) throws IOException {
		ImageStackAsARFF out = new ImageStackAsARFF();
		int size = imgst.size();
		
		// use counter, otherwise same label and images will be overwritten
		int idx = 0;
		ArrayList<ByteProcessor> maskProcessors = new ArrayList<>();
		for (ImageArff m : maskst.values())
			maskProcessors.add(m.getImage().getAsImagePlus().getProcessor().convertToByteProcessor());
		
		for (int img_count = 0; img_count < size; img_count++) {
			ImageArff img = imgst.getProcessor(removeFromStack ? 0 : img_count);
			for (ByteProcessor mask : maskProcessors) {
				ImageProcessor applyed = img.getImage().getAsImagePlus().getProcessor();
				applyed.fill(mask);
				out.addImage(imgst.getImageLabel(removeFromStack ? 1 : img_count + 1) + "#" + idx, new ImageArff(new Image(applyed), "some_applied_image",
						"intensity", templocation));
				idx++;
			}
			
			if (removeFromStack)
				imgst.deleteSlice(1);
		}
		
		return out;
	}
	
	protected ImageStack applyMasks(ImageStack imgst, ImageStack maskst, boolean removeFromStack) {
		ImageStack out = new ImageStack();
		int size = imgst.size();
		int idx = 0;
		for (int img_count = 0; img_count < size; img_count++) {
			ImageProcessor img = imgst.getProcessor(removeFromStack ? 0 : img_count);
			
			for (ImageProcessor m : maskst) {
				ImageProcessor applyed = img.duplicate();
				applyed.fill(m.convertToByteProcessor());
				out.addImage(imgst.getImageLabel(removeFromStack ? 1 : img_count + 1) + "_" + idx++, applyed);
			}
			idx = 0;
			if (removeFromStack)
				imgst.getStack().deleteSlice(1);
		}
		return out;
	}
}
