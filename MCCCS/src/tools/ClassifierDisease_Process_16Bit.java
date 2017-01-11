package tools;

import ij.process.ImageProcessor;

import java.io.File;
import java.io.IOException;

import support.ImageArff;
import support.ImageStackAsARFF;
import workflow.Settings;
import de.ipk.ag_ba.image.structures.Image;
import de.ipk.ag_ba.image.structures.ImageStack;

public class ClassifierDisease_Process_16Bit extends AbstractClassifier_16Bit {
	
	private final String arffFileName;
	
	public ClassifierDisease_Process_16Bit(String arffFileName) {
		this.arffFileName = arffFileName;
	}
	
	@Override
	public void createSampleDataFromArff(ImageStackAsARFF[] isl, File f, int numberofsamples) throws InterruptedException, IOException {
		ImageStackAsARFF is = isl[0];
		ImageStackAsARFF masks = isl[1];
		ImageStackAsARFF gt = isl[2];
		
		boolean showOutput = false;
		boolean removeFromStack = !showOutput;
		
		// apply masks ...
		ImageStackAsARFF applyedM = applyMasks(is, masks, removeFromStack, f);
		
		// get fg & bg
		ImageStackAsARFF[] fgbg = getFGBG2(applyedM);
		
		// apply gt
		ImageStackAsARFF[] gtApplied = applyGTImages(fgbg, gt, false, f);
		
		if (showOutput) {
			is.show("input images");
			masks.show("mask images");
			applyedM.show("masked");
			
			for (ImageStackAsARFF s : fgbg)
				s.show("fgbg");
			
			for (ImageStackAsARFF s : gtApplied)
				s.show("gtapplied");
		} else {
			while (masks.getBands() > 0)
				masks.deleteLastSlice();
			applyedM = null;
			while (gt.getBands() > 0)
				gt.deleteLastSlice();
		}
		
		ARFFProcessor.createTrainingDataSet(gtApplied, 0.0f, f, numberofsamples, arffFileName, true, "label"); // back => Float.MAX_VALUE
	}
	
	/**
	 * Returns applied disease stacks for all channels: {class1 <- r,g,b,...; class2 <- r,g,b,...; ...}
	 * 
	 * @param fgbg
	 * @param gt
	 * @return
	 * @throws IOException
	 */
	private ImageStackAsARFF[] applyGTImages(ImageStackAsARFF[] fgbg, ImageStackAsARFF gt, boolean removeFromStack, File templocation) throws IOException {
		ImageStackAsARFF fg = fgbg[0];
		
//		if (Settings.debug_IO) {
//			fg.show("fg");
//			gt.show("gt");
//		}
		
		ImageStackAsARFF[] stacks = new ImageStackAsARFF[gt.size()];
		
		for (int i = 0; i < stacks.length; i++) {
			stacks[i] = new ImageStackAsARFF();
		}
		
		String[] fglabels = fg.getLabels();
		String[] gtlabels = gt.getLabels();
		
		int count = fg.size();
		for (int i = 0; i < count; i++) {
			for (int j = 0; j < gt.size(); j++) {
				ImageProcessor d = fg.getProcessor(removeFromStack ? 0 : i).getImage().getAsImagePlus().getProcessor();
				d.fill(gt.getProcessor(j).getImage().getAsImagePlus().getProcessor().rotateRight().convertToByteProcessor());
				ImageArff ia = new ImageArff(new Image(d), fglabels[i], fglabels[i], templocation);
				stacks[j].addImage(fglabels[i] + "_" + gtlabels[j], ia);
			}
			if (removeFromStack)
				fg.deleteSlice(1);
		}
		
		return stacks;
	}
	
	private ImageStack[] getFGBG(ImageStack applyedM) {
		ImageStack fgStack = new ImageStack();
		ImageStack bgStack = new ImageStack();
		
		String[] labels = applyedM.getLabels();
		
		for (int i = 0; i < applyedM.size(); i += 2) {
			ImageProcessor bg = applyedM.getProcessor(i).duplicate();
			bg.fill(applyedM.getProcessor(i + 1).convertToByteProcessor());
			fgStack.addImage(labels[i], bg);
			bgStack.addImage(labels[i + 1], applyedM.getProcessor(i + 1));
		}
		return new ImageStack[] { fgStack, bgStack };
	}
	
	private ImageStackAsARFF[] getFGBG2(ImageStackAsARFF applyedM) {
		ImageStackAsARFF fgStack = new ImageStackAsARFF();
		ImageStackAsARFF bgStack = new ImageStackAsARFF();
		
		String[] labels = applyedM.getLabels();
		
		for (int i = 0; i < applyedM.size(); i += 2) {
			fgStack.addImage(labels[i], applyedM.getProcessor(i));
			bgStack.addImage(labels[i + 1], applyedM.getProcessor(i + 1));
		}
		return new ImageStackAsARFF[] { fgStack, bgStack };
	}
}
