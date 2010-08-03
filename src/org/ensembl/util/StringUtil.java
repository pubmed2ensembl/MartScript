package org.ensembl.util;

public class StringUtil {

	public static int compare(String a, String b) {

		return a.compareTo(b);

	}

	public static String toString(String[] stringArray) {
		
		if (stringArray == null)
			return "null";
		
		String accumulatedString = "";
		
		for (int i = 0; i < stringArray.length; i++)
			if (i == 0)
				accumulatedString += stringArray[i];
			else
				accumulatedString += "," + stringArray[i];
		
		return accumulatedString;
		
	}
	
}
