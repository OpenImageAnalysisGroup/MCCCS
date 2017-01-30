package tools;

import java.io.FilterOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;

public class CountingOutputStream extends FilterOutputStream {
	
	private long count;
	private ArrayList<Byte> header = new ArrayList<>();
	public boolean writingHeader = true;
	public boolean processing = false;
	
	public CountingOutputStream(OutputStream out) {
		super(out);
	}
	
	public long getCount() {
		return count;
	}
	
	@Override
	public void write(int b) throws IOException {
		super.write(b);
		if (!processing)
			count++;
		if (writingHeader)
			header.add((byte) b);
	}
	
	@Override
	public void write(byte b[]) throws IOException {
		super.write(b);
	}
	
	@Override
	public void write(byte b[], int off, int len) throws IOException {
		super.write(b, off, len);
	}
	
	public ArrayList<Byte> getHeader() {
		return header;
	}
}