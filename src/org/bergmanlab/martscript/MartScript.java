package org.bergmanlab.martscript;

import java.util.*;

import org.antlr.runtime.*;
import org.antlr.runtime.debug.DebugEventSocketProxy;

import org.biomart.common.resources.*;

import org.bergmanlab.martscript.*;

public class MartScript implements SystemExitConstants {
	
	private static final int MODE_VERIFY = 0;
	private static final int MODE_EXECUTE = 1;
	
	private static int mode = MODE_VERIFY;
	
	public MartScript() {

	}
	
	public void processScript(List script) {

		switch (mode) {
		case MODE_VERIFY:
			if (new MartScriptStaticChecker().isErroneous(script)) {
				
				System.exit(EXIT_ERROR);
				
			}
			break;
		case MODE_EXECUTE:
			new MartScriptInterpreter().runScript(script);
			break;
		default:
			System.out.println("Woops.. an interesting error has occurred. Please contact the MartScript developers.");
			break;
		}
		
	}

	public static void main(String args[]) throws Exception {

	    if(args.length != 1) {
	    	System.out.println("Usage: java -Xmx1024M org.bergmanlab.martscript.MartScript script.mscr");
	    	System.exit(EXIT_ERROR);
	    }
	    
	    Settings.setApplication(Settings.MARTBUILDER);
	    Resources.setResourceLocation("org/biomart/builder/resources");
	    
	    MartScriptLexer lex = new MartScriptLexer(new ANTLRFileStream(args[0]));
	    CommonTokenStream tokens = new CommonTokenStream(lex);
	    
	    System.out.println("Beginning syntactic and semantic verification...");
	    MartScriptParser g = new MartScriptParser(tokens);
	    try {
	    	g.script();
	    } catch (RecognitionException e) {
	    	e.printStackTrace();
	    }

	    mode = MODE_EXECUTE;
	    
	    lex = new MartScriptLexer(new ANTLRFileStream(args[0]));
	    tokens = new CommonTokenStream(lex);
	    
	    System.out.println("Beginning script execution...");
	    g = new MartScriptParser(tokens);
	    try {
	    	g.script();
	    } catch (RecognitionException e) {
	    	e.printStackTrace();
	    }

	}

}
