package workflow;

import java.io.File;
import java.util.HashSet;
import java.util.LinkedList;

import support.ARFFcontent;

/**
 * Merges two or more ARFF files (concatenates the column data)
 * 
 * @param target
 *           file
 * @param input
 *           filenames
 * @param -ColIndex
 *           for ARFF files to be merged specified
 * @param optionally
 *           specific columns may be removed from the output (1...x)
 * @param by
 *           adding +str an string can be added into the last column! Return Code 1"
 * @return merged ARFF file
 * @author Christian Klukas
 */
public class MergeArffFiles {
	
	public static void main(String[] args) throws Exception {
		if (args == null || args.length < 2) {
			System.err.println("No [targetfile] [filenames] [-ColIndex] for ARFF files to be merged specified, "
					+ "optionally specific columns may be removed from the output (1...x), by adding +str an stri"
					+ "ng can be added into the last column! Return Code 1");
			System.exit(1);
		} else {
			LinkedList<File> fl = new LinkedList<>();
			HashSet<Integer> removeColumns = new HashSet<>();
			String addLast = "";
			boolean first = true;
			for (String a : args) {
				if (a.startsWith("-")) {
					removeColumns.add(Integer.parseInt(a.substring("-".length())));
				} else {
					if (a.startsWith("+") && a.length() > 1) {
						addLast = a.substring(1);
					} else
						if (!first)
							fl.add(new File(a));
					first = false;
				}
			}
			ARFFcontent ac = new ARFFcontent();
			for (File f : fl)
				ac.appendColumnData(f);
			ac.writeTo(new File(args[0]), removeColumns, addLast);
		}
	}
}
