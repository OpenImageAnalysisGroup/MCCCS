package tools;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;

/**
 * @author klukas
 */
public class ImageFloatOnDiskOrInMemory {
	public boolean useOnDiskMode;
	private float[][] as2Afloat;
	private RandomAccessFile file;
	private FileChannel channel;
	private String fileName;
	private int w;
	private int h;
	
	public ImageFloatOnDiskOrInMemory(float[][] as2Afloat, String fileName, boolean diskMode) throws IOException {
		this.useOnDiskMode = diskMode;
		if (useOnDiskMode)
			save(as2Afloat, fileName);
		else
			this.as2Afloat = as2Afloat;
	}
	
	private void save(float[][] as2Afloat, String fileName) throws IOException {
		this.fileName = fileName;
		this.file = new RandomAccessFile(fileName, "rw");
		this.channel = file.getChannel();
		this.w = as2Afloat.length;
		this.h = as2Afloat[0].length;
		ByteBuffer buf = ByteBuffer.allocate(4 * h);
		for (int x = 0; x < as2Afloat.length; x++) {
			buf.clear();
			buf.asFloatBuffer().put(as2Afloat[x]);
			channel.write(buf);
		}
	}
	
	ByteBuffer inbuffer = ByteBuffer.allocate(4);
	private float[] readback = new float[1];
	
	public float getIntensityValue(int xs, int ys) throws IOException {
		if (useOnDiskMode) {
			channel.position(4 * (ys * w + xs));
			inbuffer.clear();
			channel.read(inbuffer);
			inbuffer.asFloatBuffer().get(readback);
			return readback[0];
		} else
			return as2Afloat[xs][ys];
	}
	
	public void closeFiles() throws IOException {
		if (useOnDiskMode) {
			channel.close();
			file.close();
			new File(fileName).delete();
		}
	}
}