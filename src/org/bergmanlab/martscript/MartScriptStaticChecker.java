package org.bergmanlab.martscript;

import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;
import java.sql.*;
import java.text.*;
import org.antlr.runtime.*;
import org.antlr.runtime.debug.DebugEventSocketProxy;

import org.bergmanlab.martscript.MartScriptInterpreter.ExecutionException;
import org.biomart.builder.model.*;
import org.biomart.builder.controller.*;
import org.biomart.common.utils.*;

import org.biomart.builder.view.gui.*;
import org.biomart.builder.view.gui.MartTabSet.*;

import org.biomart.builder.view.gui.dialogs.*;
import org.biomart.builder.controller.MartConstructor.*;
import org.biomart.builder.exceptions.*;

// MartEditor imports:
import org.ensembl.mart.lib.*;
import org.ensembl.mart.lib.config.*;
import org.ensembl.mart.editor.*;

public class MartScriptStaticChecker implements SystemExitConstants {

	private int filterTitles;
	private int featureTitles;
	private int linkoutURLs;

	private boolean hostInitialized;
	private boolean portInitialized;
	private boolean usernameInitialized;
	private boolean passwordInitialized;
	private boolean schemaInitialized;
	private boolean sequenceMartScriptsPathInitialized;
	private boolean ensHomePathInitialized;
	private boolean perl5libPathsInitialized;
	private boolean taxonomyDumpInitialized;
	private boolean ensemblVersionInitialized;
	private boolean ensemblDatabaseInitialized;

	private String schema;
	private String ensemblVersion;
	private String ensemblDatabase;
	
	private boolean binDirectoryInitialized;
	private boolean bashPathInitialized;
	private boolean perlPathInitialized;
	private boolean martscriptDBInitialized;

	private boolean hasSeenCreateMasterSchemas;
	private boolean hasSeenCreateSequenceMart;
	private boolean hasSeenCreateTable;
	private boolean hasSeenOpenMartFile;
	private boolean hasSeenAddTable;
	private boolean hasSeenSynchronize;
	private boolean hasSeenAccept;
	private boolean hasSeenGenerateSQL;
	private boolean hasSeenExecuteSQL;
	private boolean hasSeenOpenMartDB;
	private boolean hasSeenSaveDB;
	private boolean hasSeenOpenDataset;
	private boolean hasSeenAddGroup;
	private boolean hasSeenSetGroup;
	private boolean hasSeenAddCollection;
	private boolean hasSeenAddAttributes;
	private boolean hasSeenSaveAttributes;
	private boolean hasSeenUploadDB;
	private boolean hasSeenImportDB;
	private boolean hasSeenExportDB;
	
	private Set tableNames = new TreeSet(); // Tables that are created.
	private Map tableColumnNames = new HashMap();
	
	private Set marts = new TreeSet();
	private Set datasets = new TreeSet();
	private Set tables = new TreeSet(); // Tables in non-create commands.
	private Set species = new TreeSet();
	private Set databases = new TreeSet();
	private Set versions = new TreeSet();
	
	class StaticCheckerException extends Exception {

		private String detailedExplanation;

		public StaticCheckerException(String explanation) {

			this(explanation, "");

		}

		public StaticCheckerException(String explanation, String detailedExplanation) {

			super(explanation);

			this.detailedExplanation = detailedExplanation;

		}

		public String getDetailedExplanation() {

			return detailedExplanation;

		}

	}

	public static String prettyPrint(String[] s) {

		String prettyString = "";

		for (int i = 0; i < s.length; i++)
			prettyString = prettyString + " " + s[i];

		return prettyString.trim();

	}

	public MartScriptStaticChecker() {

		// Nothing to do...

	}

	private void checkOptionalDatabase() throws StaticCheckerException {
		
		if (!ensemblDatabaseInitialized) {
			
			throw new StaticCheckerException("It is necessary to set a default database when omitting the database parameter.",
					"For example: set default ensembl database to core");
			
		}
		
	}
	
	private void checkOptionalVersion() throws StaticCheckerException {
		
		if (!ensemblVersionInitialized) {
			
			throw new StaticCheckerException("It is necessary to set a default version when omitting the version parameter.",
					"For example: set default ensembl version to 56");
			
		}
		
	}
	
	private void printSet(String preamble, int indent, Set set) {
	
		System.out.println(preamble);

		char emptySpace[] = new char[indent];
		Arrays.fill(emptySpace, ' ');
		String indentString = new String(emptySpace);
		
		for (Iterator i = set.iterator(); i.hasNext();) {
			System.out.print(indentString);
			System.out.println(i.next());
		}
		
	}
	
	private void printSummary() {
		
		System.out.println("SUMMARY:");
		System.out.println("--------");
		
		printSet("Marts:", 4, marts);
		printSet("Versions:", 4, versions);
		printSet("Databases:", 4, databases);
		printSet("Datasets:", 4, datasets);
		printSet("Creates tables:", 4, tableNames);
		printSet("Reads tables:", 4, tables);
		
	}
	
	public boolean isErroneous(List script) {

		boolean errorOccurred = false;
		Iterator actionIterator = script.iterator();

		System.out.println("ERRORS:");
		System.out.println("-------");
		
		while (actionIterator.hasNext()) {

			Action action = (Action) actionIterator.next();

			try {

				examine(action);

			} catch (StaticCheckerException e) {
				System.out.println(" - " + e.getMessage());

				if (e.getDetailedExplanation().length() >= 0) {

					System.out.println(" - " + e.getDetailedExplanation());

				}

				errorOccurred = true;
				
			} catch (Exception e) {
				System.out.println("Woops.. the following exception occurred during the script's static verification:");
				e.printStackTrace();
				System.out.println(" -- finished: prematurely/erroneously");
			}

		}
		
		if (!errorOccurred) {
			
			System.out.println("    No apparent errors.");
			
		} else {
			
			System.out.println("Execution aborted due to errors.");
			System.exit(EXIT_ERROR);
			
		}

		printSummary();
		
		return errorOccurred;

	}

	protected void examine(Action action) throws Exception {

		if (action.name.equals("accept")) {

			if (action.parameters.get(0).equals("all")
					&& action.parameters.get(1).equals("changes")) {

				if (!hasSeenSynchronize) {
					
					throw new StaticCheckerException("Command missing: synchronize");
					
				}
				
			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}
			
			hasSeenAccept = true;

		} else if (action.name.equals("add")) {

			if (action.parameters.get(0).equals("attribute")
					&& action.parameters.get(1).equals("collection")
					&& action.parameters.get(3).equals("with")
					&& action.parameters.get(4).equals("title")) {

				hasSeenAddGroup = true;

			} else if (action.parameters.get(0).equals("attribute")
					&& action.parameters.get(1).equals("group")
					&& action.parameters.get(3).equals("with")
					&& action.parameters.get(4).equals("title")) {

				hasSeenAddCollection = true;

			} else if (action.parameters.get(0).equals("feature")
					&& action.parameters.get(2).equals("with")
					&& action.parameters.get(3).equals("title") ||
					action.parameters.get(0).equals("default")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(3).equals("with")
					&& action.parameters.get(4).equals("title")) {

				hasSeenAddAttributes = true;
				featureTitles = featureTitles + 1;

			} else if (action.parameters.get(0).equals("feature")
					&& action.parameters.get(2).equals("for")
					&& action.parameters.get(3).equals("table")
					&& action.parameters.get(4).equals("column")
					&& action.parameters.get(6).equals("with")
					&& action.parameters.get(7).equals("title") ||
					action.parameters.get(0).equals("default")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(3).equals("for")
					&& action.parameters.get(4).equals("table")
					&& action.parameters.get(5).equals("column")
					&& action.parameters.get(7).equals("with")
					&& action.parameters.get(8).equals("title")) {

				hasSeenAddAttributes = true;
				featureTitles = featureTitles + 1;

			} else if (action.parameters.get(0).equals("filter")
					&& action.parameters.get(2).equals("with")
					&& action.parameters.get(3).equals("title")) {

				hasSeenAddAttributes = true;
				filterTitles = filterTitles + 1;

			} else if (action.parameters.get(0).equals("accession")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("for")
					&& action.parameters.get(5).equals("feature")
					&& action.parameters.get(7).equals("to")
					&& action.parameters.get(8).equals("database")
					&& action.parameters.get(10).equals("of")
					&& action.parameters.get(11).equals("species") ||
					action.parameters.get(0).equals("accession")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("for")
					&& action.parameters.get(5).equals("feature")
					&& action.parameters.get(7).equals("of")
					&& action.parameters.get(8).equals("species")) {

				String paramDatabase = ensemblDatabase;
				String paramVersion = ensemblVersion;
				
				if (action.parameters.get(8).equals("database")) {
					
					paramDatabase = (String)action.parameters.get(9);
					
				} else {
					
					checkOptionalDatabase();
					
				}
				
				if (action.parameters.contains("version")
						&& action.parameters.indexOf("version") == action.parameters
								.size() - 2) {

					paramVersion = (String) action.parameters
							.get(action.parameters.size() - 1);

				} else {
					
					checkOptionalVersion();
					
				}
				
				databases.add(paramDatabase);
				versions.add(paramVersion);
				
				hasSeenAddTable = true;

			} else if (action.parameters.get(0).equals("gene") // everything/no
					// version, no
					// database/no
					// version
					// syntax check should be made tighter to validate the use
					// of 'of' and 'to' properly
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("to")
					&& action.parameters.get(5).equals("database")
					&& (action.parameters.get(7).equals("of") || action.parameters
							.get(7).equals("to"))
					&& (action.parameters.get(8).equals("species") || action.parameters
							.get(8).equals("all")
							&& action.parameters.get(9).equals("species"))
					|| action.parameters.get(0).equals("gene")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& (action.parameters.get(4).equals("of") || action.parameters
							.get(4).equals("to"))
					&& (action.parameters.get(5).equals("species") || action.parameters
							.get(5).equals("all")
							&& action.parameters.get(6).equals("species"))) {

				String paramDatabase = ensemblDatabase;
				String paramVersion = ensemblVersion;
				String paramSpecies = "ALL_SPECIES"; // default value not used,
				// but set due to
				// Eclipse complaining
				// otherwise
				String paramTable = (String) action.parameters.get(3);
				boolean speciesGeneric = false;

				if (action.parameters.contains("database")) {

					paramDatabase = (String) action.parameters
							.get(action.parameters.indexOf("database") + 1);

				} else {
					
					checkOptionalDatabase();
					
				}

				if (action.parameters.contains("version")
						&& action.parameters.indexOf("version") == action.parameters
								.size() - 2) {

					paramVersion = (String) action.parameters
							.get(action.parameters.size() - 1);

				} else {
					
					checkOptionalVersion();
					
				}

				if (action.parameters.contains("all")
						&& ((String) action.parameters.get(action.parameters
								.indexOf("species") - 1)).equals("all")) {

					speciesGeneric = true;

				} else {

					paramSpecies = (String) action.parameters
							.get(action.parameters.indexOf("species") + 1);

				}

				databases.add(paramDatabase);
				versions.add(paramVersion);
				species.add(paramSpecies);
				tables.add(paramTable);
				
				hasSeenAddTable = true;

			} else if (action.parameters.get(0).equals("transcript") // everything/no
					// version,
					// no
					// database/no
					// version
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("to")
					&& action.parameters.get(5).equals("database")
					&& action.parameters.get(7).equals("of")
					&& action.parameters.get(8).equals("species")
					|| action.parameters.get(0).equals("transcript")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("of")
					&& action.parameters.get(5).equals("species")) {

				String paramDatabase = ensemblDatabase;
				String paramVersion = ensemblVersion;
				String paramSpecies = (String) action.parameters
						.get(action.parameters.indexOf("species") + 1);
				String paramTable = (String) action.parameters.get(3);

				if (action.parameters.contains("database")) {

					paramDatabase = (String) action.parameters
							.get(action.parameters.indexOf("database") + 1);

				} else {
					
					checkOptionalDatabase();
					
				}

				if (action.parameters.contains("version")
						&& action.parameters.indexOf("version") == action.parameters
								.size() - 2) {

					paramVersion = (String) action.parameters
							.get(action.parameters.size() - 1);

				} else {
					
					checkOptionalVersion();
					
				}

				tables.add(paramTable);
				databases.add(paramDatabase);
				versions.add(paramVersion);
				species.add(paramSpecies);
				
				hasSeenAddTable = true;

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("create")) {

			if (action.parameters.get(0).equals("gene")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("as")
					&& action.parameters.get(5).equals("union")
					&& action.parameters.get(6).equals("of")
					&& action.parameters.get(7).equals("gene")
					&& action.parameters.get(8).equals("feature")
					&& action.parameters.get(9).equals("tables")) {

				tableNames.add(action.parameters.get(3));
				
				for (int i = 10; i < action.parameters.size(); i++)
					tables.add(action.parameters.get(i));
				
				hasSeenCreateTable = true;

			} else if (action.parameters.get(0).equals("gene") // everything,
					// version only,
					// database
					// only, none
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("for")
					&& action.parameters.get(5).equals("database")
					&& action.parameters.get(7).equals("of")
					&& (action.parameters.get(8).equals("species") || (action.parameters
							.get(8).equals("all") && action.parameters.get(9)
							.equals("species")))
					&& action.parameters.get(10).equals("version")
					&& action.parameters.get(12).equals("as")
					&& action.parameters.get(13).equals("fusion")
					&& action.parameters.get(14).equals("of")
					&& action.parameters.get(15).equals("column")
					&& action.parameters.get(17).equals("of")
					&& action.parameters.get(18).equals("tables")
					|| action.parameters.get(0).equals("gene")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("of")
					&& (action.parameters.get(5).equals("species") || (action.parameters
							.get(5).equals("all") && action.parameters.get(6)
							.equals("species")))
					&& action.parameters.get(7).equals("version")
					&& action.parameters.get(9).equals("as")
					&& action.parameters.get(10).equals("fusion")
					&& action.parameters.get(11).equals("of")
					&& action.parameters.get(12).equals("column")
					&& action.parameters.get(14).equals("of")
					&& action.parameters.get(15).equals("tables")
					|| action.parameters.get(0).equals("gene")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("for")
					&& action.parameters.get(5).equals("database")
					&& action.parameters.get(7).equals("of")
					&& (action.parameters.get(8).equals("species") || (action.parameters
							.get(8).equals("all") && action.parameters.get(9)
							.equals("species")))
					&& action.parameters.get(10).equals("as")
					&& action.parameters.get(11).equals("fusion")
					&& action.parameters.get(12).equals("of")
					&& action.parameters.get(13).equals("column")
					&& action.parameters.get(15).equals("of")
					&& action.parameters.get(16).equals("tables")
					|| action.parameters.get(0).equals("gene")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("of")
					&& (action.parameters.get(5).equals("species") || (action.parameters
							.get(5).equals("all") && action.parameters.get(6)
							.equals("species")))
					&& action.parameters.get(7).equals("as")
					&& action.parameters.get(8).equals("fusion")
					&& action.parameters.get(9).equals("of")
					&& action.parameters.get(10).equals("column")
					&& action.parameters.get(12).equals("of")
					&& action.parameters.get(13).equals("tables")) {

				String paramTable = (String)action.parameters.get(3);
				String paramDatabase = ensemblDatabase;
				String paramVersion = ensemblVersion;
				String paramSpecies = "ALL_SPECIES";
				String paramColumn;
				boolean speciesGeneric = false;

				int paramTableOffset;

				if (action.parameters.contains("all")
						&& action.parameters.get(
								action.parameters.indexOf("all") + 1).equals(
								"species")) {

					speciesGeneric = true;

				} else {

					if (action.parameters.contains("all")) {

						throw new StaticCheckerException(
								"The command is malformed, because 'all' should preceed 'species'.");

					}

				}

				if (action.parameters.contains("database")
						&& action.parameters.contains("version")) { // both
					// database
					// and
					// version
					// given

					paramDatabase = (String) action.parameters.get(6);
					paramVersion = (String) action.parameters.get(11);
					if (!speciesGeneric) {
						paramSpecies = (String) action.parameters.get(9);
					}
					paramColumn = (String) action.parameters.get(16);
					paramTableOffset = 19;

				} else if (!action.parameters.contains("database")
						&& action.parameters.contains("version")) { // only
					// version
					// given,
					// database
					// omitted

					paramVersion = (String) action.parameters.get(8);
					if (!speciesGeneric) {
						paramSpecies = (String) action.parameters.get(6);
					}
					paramColumn = (String) action.parameters.get(13);
					paramTableOffset = 16;

					checkOptionalDatabase();
					
				} else if (action.parameters.contains("database")
						&& !action.parameters.contains("version")) { // only
					// database
					// given,
					// version
					// omitted

					paramDatabase = (String) action.parameters.get(6);
					if (!speciesGeneric) {
						paramSpecies = (String) action.parameters.get(9);
					}
					paramColumn = (String) action.parameters.get(14);
					paramTableOffset = 17;

					checkOptionalVersion();
					
				} else if (!action.parameters.contains("database")
						&& !action.parameters.contains("version")) { // neither
					// database
					// nor
					// version
					// given

					// use default values for the database and version, which
					// are set above
					if (!speciesGeneric) {
						paramSpecies = (String) action.parameters.get(6);
					}
					paramColumn = (String) action.parameters.get(11);
					paramTableOffset = 14;

					checkOptionalDatabase();
					checkOptionalVersion();
					
				} else {

					throw new StaticCheckerException(
							"The command is recognized, but the arguments are not understood by the interpreter.");

				}

				tableNames.add(paramTable);
				
				for (int i = paramTableOffset; i < action.parameters.size(); i++)
					tables.add(action.parameters.get(i));
				
				databases.add(paramDatabase);
				versions.add(paramVersion);
				species.add(paramSpecies);
				
				hasSeenCreateTable = true;

			} else if (action.parameters.size() == 6
					&& (action.parameters.get(0).equals("gene") || action.parameters
							.get(0).equals("transcript"))
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("from")) {

				tableNames.add(action.parameters.get(3));
				
				hasSeenCreateTable = true;

			} else if (action.parameters.get(0).equals("master")
					&& action.parameters.get(1).equals("schema")
					&& action.parameters.get(3).equals("templates")
					|| action.parameters.get(0).equals("master")
					&& action.parameters.get(1).equals("schema")
					&& action.parameters.get(2).equals("templates")) {

				String paramVersion = ensemblVersion;

				if (action.parameters.size() == 4) {

					paramVersion = (String) action.parameters.get(2);

				} else {

					checkOptionalVersion();

				}

				versions.add(paramVersion);
				
				// Not much that can be done about this command, but there can be some
				// mentioning in the summary.
				hasSeenCreateMasterSchemas = true;

			} else if (action.parameters.get(0).equals("sequence")
					&& action.parameters.get(1).equals("mart")) {

				if (!sequenceMartScriptsPathInitialized) {
					
					throw new StaticCheckerException("The directory of the sequence mart generation scripts has not been set.");
					
				}
				
				if (!ensHomePathInitialized) {
					
					throw new StaticCheckerException("The directory of the 'ensembl' scripts has not been set.");
					
				}
				
				// Nothing of further consequence here.
				hasSeenCreateSequenceMart = true;

			} else if ((action.parameters.get(0).equals("gene") || action.parameters.get(0).equals("transcript"))
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("from")
					&& action.parameters.get(5).equals("blast")
					&& action.parameters.get(6).equals("on")
					&& action.parameters.get(7).equals("cdna")
					&& action.parameters.get(8).equals("data")
					&& action.parameters.get(9).equals("in")
					&& action.parameters.get(10).equals("directory")) {

				tableNames.add(action.parameters.get(3));
				
				hasSeenCreateTable = true;

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("export")) {

			if (action.parameters.get(0).equals("template")
					&& action.parameters.get(1).equals("configuration")
					&& action.parameters.get(2).equals("to")
					&& action.parameters.get(3).equals("database")) {

				if (!hasSeenOpenMartDB) {
				
					throw new StaticCheckerException("A mart database has to be opened first in order to execute an export.");
					
				}
				
				hasSeenExportDB = true;

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("copy")) {

			if (action.parameters.get(0).equals("table")
					&& action.parameters.get(2).equals("to")
					&& action.parameters.get(3).equals("database")
					&& action.parameters.get(5).equals("of")
					&& action.parameters.get(6).equals("species") ||
					action.parameters.get(0).equals("table")
					&& action.parameters.get(2).equals("of")
					&& action.parameters.get(3).equals("species")) {

				String paramTable = (String)action.parameters.get(1);
				String paramDatabase = ensemblDatabase;
				String paramSpecies = (String)action.parameters.get(action.parameters.indexOf("species") + 1);
				String paramVersion = ensemblVersion;
		
				if (action.parameters.get(3).equals("database")) {

					paramDatabase = (String) action.parameters.get(4);

				}
				
				if (action.parameters.contains("version")
						&& action.parameters.indexOf("version") == action.parameters
								.size() - 2) {

					paramVersion = (String) action.parameters
							.get(action.parameters.size() - 1);

				}
				
				tables.add(paramTable);
				databases.add(paramDatabase);
				versions.add(paramVersion);
				species.add(paramSpecies);
				
				// No consequences, since it is a fairly advanced command.

			}

		} else if (action.name.equals("execute")) {

			if (action.parameters.get(0).equals("sql")
					&& action.parameters.get(1).equals("for")
					&& action.parameters.get(2).equals("mart")
					&& action.parameters.get(4).equals("from")) {

				marts.add(action.parameters.get(3));
				
				// No dependencies.

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("generate")) {

			if (action.parameters.get(0).equals("statistics")
					&& action.parameters.get(1).equals("table")
					&& action.parameters.get(3).equals("for")) {

				if (action.parameters.get(4).equals("all")
						&& action.parameters.get(5).equals("species")
						&& action.parameters.get(6).equals("tables")
						&& action.parameters.get(8).equals("with")
						&& action.parameters.get(9).equals("column")
						&& action.parameters.get(11).equals("of")
						&& action.parameters.get(12).equals("database")) {

					String paramDestTbl = (String) action.parameters.get(2);
					String paramVersion = ensemblVersion;
					String paramTable = (String) action.parameters.get(7);
					String paramColumn = (String) action.parameters.get(10);
					String paramDatabase = ensemblDatabase;

					if (action.parameters.contains("database")) {
						
						paramDatabase = (String)action.parameters.get(action.parameters.indexOf("database") + 1);
						
					}
					
					if (action.parameters.contains("version")
							&& action.parameters.indexOf("version") == action.parameters
									.size() - 2) {

						paramVersion = (String) action.parameters
								.get(action.parameters.size() - 1);

					}
					
					tableNames.add(paramDestTbl);
					tables.add(paramTable);
					databases.add(paramDatabase);
					versions.add(paramVersion);

					// No dependencies.

				} else if (action.parameters.get(4).equals("column")
						&& action.parameters.get(6).equals("from")) {

					String paramDestTbl = (String) action.parameters.get(2);
					String paramColumn = (String) action.parameters.get(5);
					String paramFile = (String) action.parameters.get(7);

					tableNames.add(paramDestTbl);
					
					// No dependencies

				} else {

					throw new StaticCheckerException(
							"The command is recognized, but the arguments are not understood by the interpreter.");

				}

			} else if (action.parameters.get(0).equals("sql")
					&& action.parameters.get(1).equals("for")
					&& action.parameters.get(2).equals("mart")
					&& action.parameters.get(4).equals("as")) {

				if (!hasSeenOpenMartFile) {
					
					throw new StaticCheckerException("A mart XML-file needs to be opened before the SQL can be generated.");
					
				}
				
				if (hasSeenAddTable) {
					
					if (!hasSeenSynchronize) {
						
						throw new StaticCheckerException("Tables have been added to the mart, but the changes have not been synchronized.");
						
					}
					
					if (!hasSeenAccept) {
						
						throw new StaticCheckerException("After synchronization, the changes need to be accepted.");
						
					}
					
				}
				
				marts.add(action.parameters.get(3));
				
				hasSeenGenerateSQL = true;

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("import")) {

			if (action.parameters.get(0).equals("template")
					&& action.parameters.get(1).equals("configuration")
					&& action.parameters.get(2).equals("of")
					&& action.parameters.get(3).equals("dataset")
					&& action.parameters.get(5).equals("from")
					&& action.parameters.get(6).equals("database")) {

				if (!hasSeenOpenMartDB) {
					
					throw new StaticCheckerException("A mart database has to be opened before an import can be done.");
					
				}
				
				datasets.add(action.parameters.get(4));
				
				hasSeenImportDB = true;

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("open")) {

			if (action.parameters.get(0).equals("dataset")) {

				if (action.parameters.get(2).equals("of")
						&& action.parameters.get(3).equals("mart")
						&& action.parameters.get(5).equals("in")
						&& action.parameters.get(6).equals("directory")) {

					filterTitles = 0;
					featureTitles = 0;
					linkoutURLs = 0;

					datasets.add(action.parameters.get(1));
					marts.add(action.parameters.get(4));
					
					hasSeenOpenDataset = true;
					
				}

			} else if (action.parameters.get(0).equals("mart")) {

				if (action.parameters.get(1).equals("database")
						&& action.parameters.get(3).equals("on")
						&& action.parameters.get(6).equals("in")
						&& action.parameters.get(8).equals("as")
						&& action.parameters.get(11).equals("with")
						&& action.parameters.size() == 13
					|| action.parameters.get(1).equals("database")
					&& action.parameters.get(3).equals("on")
					&& action.parameters.get(6).equals("as")
					&& action.parameters.get(9).equals("with")
					&& action.parameters.size() == 11) {

					schema = (String) action.parameters.get(2);
					String paramDatabase = schema;
					String paramHost = (String) action.parameters.get(4);
					String paramPort = (String) action.parameters.get(5);
					String paramUser = (String) action.parameters.get(action.parameters.indexOf("as") + 1);
					String paramPassword = (String) action.parameters.get(action.parameters.indexOf("as") + 2);
					String paramDriver = (String) action.parameters.get(action.parameters.size() - 1);
					
					// Postgres would allow us the specification of a namespace..
					if (action.parameters.contains("in")
							&& action.parameters.indexOf("in") + 2 == action.parameters.indexOf("as")) {
						
						paramDatabase = (String) action.parameters.get(action.parameters.indexOf("in") + 1);
						
					}
					
					marts.add(paramDatabase);
					
					hasSeenOpenMartDB = true;

				} else if (action.parameters.get(1).equals("file")) {

					hasSeenOpenMartFile = true;

				}

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("rename")) {

			if (action.parameters.get(0).equals("column")
					&& action.parameters.get(2).equals("of")
					&& action.parameters.get(3).equals("table")
					&& action.parameters.get(5).equals("as")) {

				tables.add(action.parameters.get(4));
				
				// No further dependencies.

			} else if (action.parameters.get(0).equals("table")
					&& action.parameters.get(2).equals("to")) {

				tables.add(action.parameters.get(1));
				tables.add(action.parameters.get(3));
				
				// No further dependencies.
				
			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("save")) {

			if (action.parameters.get(0).equals("all")
					&& action.parameters.get(1).equals("changes")
					&& action.parameters.get(2).equals("of")
					&& action.parameters.get(3).equals("mart")) {

				if (hasSeenAddGroup) {
					
					if (!hasSeenSetGroup) {
					
						throw new StaticCheckerException("A description needs to be set for the added attribute group.");
					
					}			
					
					if (!hasSeenAddAttributes) {
						
						throw new StaticCheckerException("Attributes need to be added, i.e. features, filters and linkout URLs.");
						
					}
					
					if (filterTitles != featureTitles || featureTitles != linkoutURLs) {
						
						throw new StaticCheckerException("The number of attribute features, filters and linkout URLs does not match.");
						
					}
					
				}
				
				marts.add(action.parameters.get(4));

				hasSeenSaveAttributes = true;
				
			} else if (action.parameters.get(0).equals("mart")
					&& action.parameters.get(1).equals("file")) {

				// Not really used in a Mart's construction. It can go without any requirements.

			} else if (action.parameters.get(0).equals("database")
					&& action.parameters.get(1).equals("datasets")
					&& action.parameters.get(2).equals("in")
					&& action.parameters.get(3).equals("directory")) {

				if (!hasSeenOpenMartDB) {
					
					throw new StaticCheckerException("A mart database needs to be opened first.");
					
				}

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("set")) {

			if (action.parameters.get(0).equals("default")) {

				if (action.parameters.get(1).equals("ensembl")
						&& action.parameters.get(2).equals("database")
						&& action.parameters.get(3).equals("to")) {

					ensemblDatabase = (String) action.parameters.get(4);
					ensemblDatabaseInitialized = true;
					
				} else if (action.parameters.get(1).equals("ensembl")
						&& action.parameters.get(2).equals("home")
						&& action.parameters.get(3).equals("path")
						&& action.parameters.get(4).equals("to")) {

					ensHomePathInitialized = true;

				} else if (action.parameters.get(1).equals("ensembl")
						&& action.parameters.get(2).equals("version")
						&& action.parameters.get(3).equals("to")) {

					ensemblVersion = (String) action.parameters.get(4);
					ensemblVersionInitialized = true;
					
				} else if (action.parameters.get(1).equals("perl")
						&& action.parameters.get(2).equals("interpreter")
						&& action.parameters.get(3).equals("path")
						&& action.parameters.get(4).equals("to")) {

					// Optional, so its absence might be alright.

				} else if (action.parameters.get(1).equals("perl")
						&& action.parameters.get(2).equals("library")
						&& action.parameters.get(3).equals("path")
						&& action.parameters.get(4).equals("to")) {

					perl5libPathsInitialized = true;

				} else if (action.parameters.get(1).equals("sequence")
						&& action.parameters.get(2).equals("mart")
						&& action.parameters.get(3).equals("scripts")
						&& action.parameters.get(4).equals("path")
						&& action.parameters.get(5).equals("to")) {

					sequenceMartScriptsPathInitialized = true;

				} else if (action.parameters.get(1).equals("shell")
						&& action.parameters.get(2).equals("script")
						&& action.parameters.get(3).equals("path")
						&& action.parameters.get(4).equals("to")) {
					
					binDirectoryInitialized = true;

				} else if (action.parameters.get(1).equals("host")
						&& action.parameters.get(2).equals("to")) {

					hostInitialized = true;
					
				} else if (action.parameters.get(1).equals("password")
						&& action.parameters.get(2).equals("to")) {

					passwordInitialized = true;

				} else if (action.parameters.get(1).equals("port")
						&& action.parameters.get(2).equals("to")) {

					portInitialized = true;

				} else if (action.parameters.get(1).equals("taxonomy")
						&& action.parameters.get(2).equals("dump")
						&& action.parameters.get(3).equals("path")
						&& action.parameters.get(4).equals("to")) {

					taxonomyDumpInitialized = true;

				} else if (action.parameters.get(1).equals("username")
						&& action.parameters.get(2).equals("to")) {

					usernameInitialized = true;

				}

			} else if (action.parameters.get(0).equals("description")
					&& action.parameters.get(1).equals("of")
					&& action.parameters.get(2).equals("attribute")
					&& action.parameters.get(3).equals("group")
					&& action.parameters.get(5).equals("as")) {

				hasSeenSetGroup = true;

			} else if (action.parameters.get(0).equals("linkout")
					&& action.parameters.get(1).equals("url")
					&& action.parameters.get(2).equals("to")) {

				linkoutURLs = linkoutURLs + 1;

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("synchronize")) {

			if (action.parameters.get(0).equals("schemas")) {

				if (!hasSeenOpenMartFile) {
					
					throw new StaticCheckerException("A mart XML-file needs to be opened beforehand.");
					
				}
				
				hasSeenSynchronize = true;

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("update")) {

			if (action.parameters.get(0).equals("database")
					&& action.parameters.get(1).equals("datasets")
					&& action.parameters.get(2).equals("of")
					&& action.parameters.get(3).equals("mart")
					&& action.parameters.get(5).equals("database")) {

				if (!hasSeenOpenMartDB) {
					
					throw new StaticCheckerException("A mart database needs to be opened first.");
					
				}
				
				marts.add(action.parameters.get(4));
				
				// This should be alright on its own.

			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("upload")) {

			if (action.parameters.get(0).equals("database")
					&& action.parameters.get(1).equals("datasets")
					&& action.parameters.get(2).equals("from")
					&& action.parameters.get(3).equals("directory")) {

				if (!hasSeenOpenMartDB) {
					
					throw new StaticCheckerException("A mart database needs to be opened first.");
					
				}
				
				hasSeenUploadDB = true;
			
			} else {

				throw new StaticCheckerException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else {

			throw new StaticCheckerException(
					"This command is not recognized by the interpreter.");

		}

	}
	
}
