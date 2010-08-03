package org.bergmanlab.martscript;

/*
 * TODO:
 * - Error handling. It is possible to 'add' a table to the species DBs of
 *   Ensembl, even though the table does not exist. Of course, nothing is
 *   added.
 * 
 */
import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;
import java.sql.*;
import java.text.*;
import org.antlr.runtime.*;
import org.antlr.runtime.debug.DebugEventSocketProxy;

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

public class MartScriptInterpreter implements SystemExitConstants {

	private String martURL;
	private Mart mart;

	private String martName;

	private String datasetName;
	private String datasetXMLURL;
	private String groupName;
	private String groupTitle;
	private String groupDescription;
	private LinkedList filterName;
	private LinkedList filterTitle;
	private LinkedList featureName;
	private LinkedList featureTitle;
	private LinkedList featureDefault; 	// Holds either "true"/"false", depending on whether the feature
										// at that index is by default on or off.
	private LinkedList columnName;
	private LinkedList linkoutURL;
	private String collectionName;
	private String collectionTitle;

	// 'diff -Naur' has by default 3 preceding lines and 3 following lines
	private int filter_limit_lines = 6;
	private int filter_list_lines = 6;
	private int attribute_feature_lines = 6;

	private Connection databaseConnection;
	private DetailedDataSource detailedDataSource;
	private DatabaseDatasetConfigUtils configUtils;
	private String host;
	private String port;
	private String username;
	private String password;
	private String schema;
	private String sequenceMartScriptsPath;
	private String ensHomePath;
	private String perl5libPaths;
	private String taxonomyDump;
	private String ensemblVersion;
	private String ensemblDatabase;
	private DatasetConfigTreeWidget templateConfigurations;

	private String binDirectory;
	static private String bashPath = "/bin/bash "; // trailing space is
	// important
	static private String perlPath = "/usr/bin/perl";
	static private String martscriptDB = "martscript";

	private Hashtable errorCodes = new Hashtable();
	static private Hashtable errorDescriptions = new Hashtable();

	static private DatasetConfigXMLUtils dscutils = new DatasetConfigXMLUtils(
			true);

	static {

		errorDescriptions
				.put(
						"DEFAULT",
						"An error has occurred, but there is no detailed description available for the error code returned by the Perl program/BASH script. Please contact the MartScript authors.");

		errorDescriptions
				.put(
						"ERR_FS_DIRECTORY",
						"The directory you specified does not exist or its permissions are set too rigorously.");
		errorDescriptions
				.put(
						"ERR_FS_FILE",
						"The file you specified does not exist or its permissions are set too rigorously.");

		errorDescriptions.put("ERR_SHELL_CD", "Could not change directory.");
		errorDescriptions
				.put(
						"ERR_SHELL_CMD",
						"A shell command failed to execute. This could be related to a failure of sed or awk.");
		errorDescriptions.put("ERR_SHELL_MKDIR",
				"Could not create a necessary directory.");
		errorDescriptions.put("ERR_SHELL_PERL",
				"The Perl interpreter failed to execute.");
		errorDescriptions.put("ERR_SHELL_RM",
				"Could not delete a file/directory.");
		errorDescriptions.put("ERR_SHELL_UNZIP",
				"The program 'unzip' failed to execute successfully.");
		errorDescriptions.put("ERR_SHELL_CP",
				"Could not copy a file/directory.");

		errorDescriptions.put("ERR_SQL_CREATE_DATABASE",
				"Could not create a required SQL database.");
		errorDescriptions.put("ERR_SQL_CREATE_TABLE",
				"Could not create a required SQL table.");
		errorDescriptions.put("ERR_SQL_CREATE_INDEX",
				"Failed to create a SQL table index.");
		errorDescriptions.put("ERR_SQL_DELETE",
				"Could not execute a required SQL DELETE statement.");
		errorDescriptions.put("ERR_SQL_SELECT",
				"Could not retrieve required information via SQL,");
		errorDescriptions
				.put("ERR_SQL_SHOW",
						"Could not retrieve required information from the SQL database via SHOW query.");
		errorDescriptions.put("ERR_SQL_IMPORT",
				"Could not import the given data into the SQL database.");
		errorDescriptions.put("ERR_SQL_SQL_FILE",
				"Could not process a file containing SQL commands.");
		errorDescriptions.put("ERR_SQL_ALTER",
				"Could not execute a required SQL ALTER statement.");
		errorDescriptions.put("ERR_SQL_CORRUPT_TABLE",
				"The database table in question is malformed.");
		errorDescriptions.put("ERR_SQL_INSERT",
				"Could not carry out a required SQL INSERT statement.");
		errorDescriptions.put("ERR_SQL_RENAME",
				"Could not carry out a required SQL RENAME statement.");
		
		errorDescriptions.put("ERR_PARAM_NOT_SUPPORTED",
				"One parameter is outside the its supported value range.");

	}

	class ExecutionException extends Exception {

		private String detailedExplanation;

		public ExecutionException(String explanation) {

			this(explanation, "");

		}

		public ExecutionException(String explanation, String detailedExplanation) {

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

	public String returnCode2String(int returnCode) {

		if (errorCodes.containsKey(new Integer(returnCode).toString())) {

			return (String) errorDescriptions.get(errorCodes.get(new Integer(
					returnCode).toString()));

		} else {

			return (String) errorDescriptions.get("DEFAULT");

		}

	}

	private void executeInBash(String command) throws ExecutionException {
	
		String[] bashCommand = {
				bashPath.trim(),
				"-c",
				command };

		Process scriptProcess;
		
		try {
		
			scriptProcess = Runtime.getRuntime().exec(bashCommand,
				null, new File(binDirectory));

		}
		catch(IOException ioe) {
		
			throw new ExecutionException("Could not get a handle to the script directory; failed to execute: "
					+ prettyPrint(bashCommand));
			
		}
		
		int returnCode;
		
		try {
			
			returnCode= scriptProcess.waitFor();

		}
		catch(InterruptedException ie) {
		
			throw new ExecutionException("Interrupted execution: "
					+ prettyPrint(bashCommand));
			
		}
		
		if (returnCode != 0) {

			throw new ExecutionException("Failed to execute: "
					+ prettyPrint(bashCommand),
					returnCode2String(returnCode));

		}
		
	}
	
	public MartScriptInterpreter() {

		MartEditor.HAS_GUI = false;

	}

	public void runScript(List script) {

		String now;
		Iterator actionIterator = script.iterator();

		while (actionIterator.hasNext()) {

			Action action = (Action) actionIterator.next();

			now = new java.util.Date().toString();

			System.out.println(now + " -- executing: " + action);

			try {

				execute(action);

			} catch (ExecutionException e) {
				System.out.println(" - " + e.getMessage());

				if (e.getDetailedExplanation().length() >= 0) {

					System.out.println(" - " + e.getDetailedExplanation());

				}

				System.out.println(now + " -- finished: prematurely/erroneously");

				System.exit(EXIT_ERROR);
			} catch (Exception e) {
				System.out.println("Woops.. the following exception occurred during the script's exception:");
				e.printStackTrace();
				System.out.println(now + " -- finished: prematurely/erroneously");
				System.exit(EXIT_FATAL);
			}

		}

		now = new java.util.Date().toString();

		System.out.println(now + " -- finished: successfully");

	}

	protected void execute(Action action) throws Exception {

		for (int i = 0; i < action.parameters.size(); i++)
			if (action.parameters.get(i).equals("\"\""))
				action.parameters.set(i, "");

		if (action.name.equals("accept")) {

			if (action.parameters.get(0).equals("all")
					&& action.parameters.get(1).equals("changes")) {

				List schemas = new ArrayList(mart.getSchemas().values());
				Iterator schemasIterator = schemas.iterator();
				while (schemasIterator.hasNext()) {

					Transaction.start(true);
					Schema schema = (Schema) schemasIterator.next();
					System.out.println("schema: " + schema);
					Iterator dataSetIterator = schema.getMart().getDataSets()
							.values().iterator();
					while (dataSetIterator.hasNext()) {

						DataSet dataSet = (DataSet) dataSetIterator.next();
						System.out.println("dataset: " + dataSet);
						Iterator tableIterator = dataSet.getTables().values()
								.iterator();
						while (tableIterator.hasNext()) {
							DataSet.DataSetTable dataSetTable = (DataSet.DataSetTable) tableIterator
									.next();
							System.out
									.println("dataset table: " + dataSetTable);
							// null means 'accept all changes'
							dataSetTable.acceptChanges(null);
						}

					}
					Transaction.end();

				}

			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("add")) {

			if (action.parameters.get(0).equals("attribute")
					&& action.parameters.get(1).equals("collection")
					&& action.parameters.get(3).equals("with")
					&& action.parameters.get(4).equals("title")) {

				collectionTitle = "";

				for (int i = 5; i < action.parameters.size(); i++)
					collectionTitle += (String) action.parameters.get(i) + " ";

				collectionTitle = collectionTitle.trim();

				collectionName = (String) action.parameters.get(2);

				attribute_feature_lines += 2;

			} else if (action.parameters.get(0).equals("attribute")
					&& action.parameters.get(1).equals("group")
					&& action.parameters.get(3).equals("with")
					&& action.parameters.get(4).equals("title")) {

				groupName = (String) action.parameters.get(2);
				groupTitle = "";

				for (int i = 5; i < action.parameters.size(); i++)
					groupTitle += action.parameters.get(i) + " ";

				groupTitle = groupTitle.trim();

				attribute_feature_lines += 2;

			} else if (action.parameters.get(0).equals("feature")
					&& action.parameters.get(2).equals("with")
					&& action.parameters.get(3).equals("title") ||
					action.parameters.get(0).equals("default")
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(3).equals("with")
					&& action.parameters.get(4).equals("title")) {

				int defaultInFront = 0;
				
				if (action.parameters.get(0).equals("default")) {
				
					defaultInFront = 1;
					
					featureDefault.add("true");
					
				} else {
					
					featureDefault.add("false");
					
				}
				
				featureName.add(action.parameters.get(1 + defaultInFront));
				columnName.add("");

				String featureTitle = "";

				for (int i = 4 + defaultInFront; i < action.parameters.size(); i++)
					featureTitle += (String) action.parameters.get(i) + " ";

				this.featureTitle.add(featureTitle.trim());

				attribute_feature_lines++;

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

				int defaultInFront = 0;
				
				if (action.parameters.get(0).equals("default")) {
				
					defaultInFront = 1;
					
					featureDefault.add("true");
					
				} else {
					
					featureDefault.add("false");
					
				}
				
				featureName.add(action.parameters.get(1 + defaultInFront));
				columnName.add(action.parameters.get(5 + defaultInFront));

				String featureTitle = "";

				for (int i = 8 + defaultInFront; i < action.parameters.size(); i++)
					featureTitle += (String) action.parameters.get(i) + " ";

				this.featureTitle.add(featureTitle.trim());

				attribute_feature_lines++;

			} else if (action.parameters.get(0).equals("filter")
					&& action.parameters.get(2).equals("with")
					&& action.parameters.get(3).equals("title")) {

				filterName.add(action.parameters.get(1));

				String filterTitle = "";

				for (int i = 4; i < action.parameters.size(); i++)
					filterTitle += (String) action.parameters.get(i) + " ";

				this.filterTitle.add(filterTitle.trim());

				filter_limit_lines += 4;
				filter_list_lines++;

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
				String paramTable = (String)action.parameters.get(3);
				String paramFeature = (String)action.parameters.get(6);
				
				// 'all species' is not yet supported by this command.
				String paramSpecies = (String)action.parameters.get(
						action.parameters.indexOf("species") + 1);
				
				if (action.parameters.get(8).equals("database")) {
					
					paramDatabase = (String)action.parameters.get(9);
					
				}
				
				if (action.parameters.contains("version")
						&& action.parameters.indexOf("version") == action.parameters
								.size() - 2) {

					paramVersion = (String) action.parameters
							.get(action.parameters.size() - 1);

				}
				
				executeInBash("./link_feature_data.sh " + username
						+ " " + password + " " + host + " " + port + " "
						+ martscriptDB + " "
						+ paramTable + " "
						+ paramSpecies + " "
						+ paramDatabase + " "
						+ paramVersion + " "
						+ taxonomyDump + " "
						+ paramFeature);

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
				String paramSpecies = "ALL_SPECIES";
				String paramTable = (String) action.parameters.get(3);
				boolean speciesGeneric = false;

				if (action.parameters.contains("database")) {

					paramDatabase = (String) action.parameters
							.get(action.parameters.indexOf("database") + 1);

				}

				if (action.parameters.contains("version")
						&& action.parameters.indexOf("version") == action.parameters
								.size() - 2) {

					paramVersion = (String) action.parameters
							.get(action.parameters.size() - 1);

				}

				if (action.parameters.contains("all")
						&& ((String) action.parameters.get(action.parameters
								.indexOf("species") - 1)).equals("all")) {

					speciesGeneric = true;

				} else {

					paramSpecies = (String) action.parameters
							.get(action.parameters.indexOf("species") + 1);

				}

				String command;

				if (speciesGeneric) {

					command = bashPath + "./link_gene_data_all_species.sh "
							+ username + " " + password + " " + host + " "
							+ port + " " + martscriptDB + " " + paramTable
							+ " " + paramDatabase + " " + paramVersion + " "
							+ taxonomyDump;

				} else {

					command = bashPath + "./link_gene_data.sh " + username + " "
							+ password + " " + host + " " + port + " "
							+ martscriptDB + " " + paramTable + " "
							+ paramSpecies + " " + paramDatabase + " "
							+ paramVersion + " " + taxonomyDump;

				}

				executeInBash(command);

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

				}

				if (action.parameters.contains("version")
						&& action.parameters.indexOf("version") == action.parameters
								.size() - 2) {

					paramVersion = (String) action.parameters
							.get(action.parameters.size() - 1);

				}

				executeInBash("./link_transcript_data.sh "
						+ username + " " + password + " " + host + " " + port
						+ " " + martscriptDB + " " + paramTable + " "
						+ paramSpecies + " " + paramDatabase + " "
						+ paramVersion + " " + taxonomyDump);

			} else {

				throw new ExecutionException(
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

				String command = perlPath + " create_union_table.pl " + host
						+ " " + port + " " + username + " " + password + " "
						+ (String) action.parameters.get(3);

				for (int i = 10; i < action.parameters.size(); i++)
					command = command + " " + (String) action.parameters.get(i);

				executeInBash(command);

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

						throw new ExecutionException(
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

				} else if (!action.parameters.contains("database")
						&& !action.parameters.contains("version")) { // neither
					// database
					// nor
					// version
					// given

					// Use default values for the database and version, which
					// are set above.
					if (!speciesGeneric) {
						paramSpecies = (String) action.parameters.get(6);
					}
					paramColumn = (String) action.parameters.get(11);
					paramTableOffset = 14;

				} else {

					throw new ExecutionException(
							"The command is recognized, but the arguments are not understood by the interpreter.");

				}

				String command = perlPath + " create_combined_table.pl " + host
						+ " " + port + " " + username + " " + password + " "
						+ taxonomyDump + " " + paramSpecies + " "
						+ paramDatabase + " " + paramVersion + " "
						+ paramTable + " " + paramColumn;

				for (int i = paramTableOffset; i < action.parameters.size(); i++)
					command = command + " " + (String) action.parameters.get(i);

				executeInBash(command);

			} else if (action.parameters.size() == 6
					&& (action.parameters.get(0).equals("gene") || action.parameters
							.get(0).equals("transcript"))
					&& action.parameters.get(1).equals("feature")
					&& action.parameters.get(2).equals("table")
					&& action.parameters.get(4).equals("from")) {

				executeInBash("./add_arbitrary_data.sh " + username
						+ " " + password + " " + host + " " + port + " "
						+ martscriptDB + " "
						+ (String) action.parameters.get(3) + " "
						+ (String) action.parameters.get(5));

			} else if (action.parameters.get(0).equals("master")
					&& action.parameters.get(1).equals("schema")
					&& action.parameters.get(3).equals("templates")
					|| action.parameters.get(0).equals("master")
					&& action.parameters.get(1).equals("schema")
					&& action.parameters.get(2).equals("templates")) {

				String paramVersion = ensemblVersion;

				if (action.parameters.size() == 4) {

					paramVersion = (String) action.parameters.get(2);

				} 

				executeInBash("./create_master_schema.sh "
						+ username + " " + password + " " + host + " " + port
						+ " " + paramVersion);

			} else if (action.parameters.get(0).equals("sequence")
					&& action.parameters.get(1).equals("mart")) {

				executeInBash("./create_sequence_mart.sh "
						+ sequenceMartScriptsPath + " " + ensHomePath + " "
						+ perl5libPaths + " " + username + " " + password + " "
						+ host + " " + port + " " + "mysql "
						+ (String) action.parameters.get(2));

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

				executeInBash("./add_blast_cdna_data.sh "
						+ username + " " + password + " " + host + " " + port
						+ " " + martscriptDB + " "
						+ (String) action.parameters.get(3) + " " + perlPath
						+ " " + binDirectory + " "
						+ (String) action.parameters.get(11));

			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("export")) {

			if (action.parameters.get(0).equals("template")
					&& action.parameters.get(1).equals("configuration")
					&& action.parameters.get(2).equals("to")
					&& action.parameters.get(3).equals("database")) {

				configUtils.setReadonly(false);
				MartEditor.setUser(username);
				MartEditor.setDetailedDataSource(detailedDataSource);
				try {
					templateConfigurations.exportTemplate();
				} catch (ConfigurationException e) {

					throw new ExecutionException(
							"A MartEditor specific exception occurred. Sorry.");

				}

			} else {

				throw new ExecutionException(
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
				
				executeInBash("./copy_data.sh " + username + " "
						+ password + " " + host + " " + port + " "
						+ martscriptDB + " "
						+ paramTable + " "
						+ paramSpecies + " "
						+ paramDatabase + " "
						+ paramVersion + " "
						+ taxonomyDump);

			}

		} else if (action.name.equals("execute")) {

			if (action.parameters.get(0).equals("sql")
					&& action.parameters.get(1).equals("for")
					&& action.parameters.get(2).equals("mart")
					&& action.parameters.get(4).equals("from")) {

				executeInBash("./process_sql_zip.sh " + username
						+ " " + password + " " + host + " " + port + " "
						+ (String) action.parameters.get(3) + " "
						+ (String) action.parameters.get(5) + " " + perlPath);

			} else {

				throw new ExecutionException(
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
						&& action.parameters.get(9).equals("column")) {

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

					executeInBash("./generate_db_stats.sh " + host
							+ " " + port + " " + username + " " + password
							+ " " + paramTable + " " + paramColumn + " "
							+ paramVersion + " " + paramDatabase + " "
							+ martscriptDB + " " + paramDestTbl);

				} else if (action.parameters.get(4).equals("column")
						&& action.parameters.get(6).equals("from")) {

					String paramDestTbl = (String) action.parameters.get(2);
					String paramColumn = (String) action.parameters.get(5);
					String paramFile = (String) action.parameters.get(7);

					executeInBash("./generate_file_stats.sh "
							+ host + " " + port + " " + username + " "
							+ password + " " + martscriptDB + " "
							+ paramDestTbl + " " + paramFile + " "
							+ paramColumn);

				} else {

					throw new ExecutionException(
							"The command is recognized, but the arguments are not understood by the interpreter.");

				}

			} else if (action.parameters.get(0).equals("sql")
					&& action.parameters.get(1).equals("for")
					&& action.parameters.get(2).equals("mart")
					&& action.parameters.get(4).equals("as")) {

				Collection datasets = new ArrayList(mart.getDataSets().values());
				// Remove partition table datasets from the list.
				// Also remove masked datasets.
				for (final Iterator i = datasets.iterator(); i.hasNext();) {
					final DataSet ds = (DataSet) i.next();
					if (ds.isPartitionTable() || ds.isMasked())
						i.remove();
				}
				if (datasets.size() == 0) {

					throw new ExecutionException(
							"There are no datasets present in the mart.");

				} else {
					// from SaveDDLDialog createDDL()

					// What datasets are we making DDL for?
					final Collection selectedDataSets = new ArrayList(mart
							.getDataSets().values());
					final Set selectedPrefixes = new TreeSet();
					for (final Iterator i = mart.getSchemas().values()
							.iterator(); i.hasNext();)
						selectedPrefixes.addAll(((Schema) i.next())
								.getReferencedPartitions());

					final String ddlHost = host;
					final String ddlPort = port;
					String overrideHost = host;
					String overridePort = port;

					final StringBuffer sb = new StringBuffer();
					MartConstructor constructor;
					constructor = new SaveDDLMartConstructor(new File(
							(String) action.parameters.get(5)));
					try {
						final MartTabSet martTabSet = new MartTabSet(
								new MartBuilder());
						MartTab martTab = martTabSet.new MartTab(martTabSet,
								mart);
						martTabSet.add(martTab);
						martTabSet.setSelectedComponent(martTab);

						martTabSet.requestSetOutputHost(ddlHost);
						martTabSet.requestSetOutputPort(ddlPort);
						martTabSet.requestSetOverrideHost(overrideHost);
						martTabSet.requestSetOverridePort(overridePort);

						final String outputDatabase = (String) action.parameters
								.get(3);
						// MySQL dependent:
						final String outputSchema = outputDatabase;
						martTabSet.requestSetOutputDatabase(outputDatabase);
						martTabSet.requestSetOutputSchema(outputSchema);
						final ConstructorRunnable cr = constructor
								.getConstructorRunnable(outputDatabase,
										outputSchema, selectedDataSets,
										selectedPrefixes);

						final Semaphore constructionLock = new Semaphore(1);

						constructionLock.acquire();
						cr
								.addMartConstructorListener(new MartConstructorListener() {
									public void martConstructorEventOccurred(
											final int event, final Object data,
											final MartConstructorAction action)
											throws ListenerException {
										if (event == MartConstructorListener.CONSTRUCTION_ENDED
												&& cr.getFailureException() == null) {
											constructionLock.release();
										}
									}
								});

						martTabSet.requestMonitorConstructorRunnable(cr);

						constructionLock.acquire();
						constructionLock.release();
					} catch (final Exception e) {

						throw new ExecutionException(
								"A MartEditor specific exception occurred. Sorry.");

					}
				}

			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("import")) {

			if (action.parameters.get(0).equals("template")
					&& action.parameters.get(1).equals("configuration")
					&& action.parameters.get(2).equals("of")
					&& action.parameters.get(3).equals("dataset")
					&& action.parameters.get(5).equals("from")
					&& action.parameters.get(6).equals("database")) {

				if (!configUtils.baseDSConfigTableExists()) {

					throw new ExecutionException(
							"There are no datasets present in the mart.");

				}

				Collection importOptions = configUtils.getImportOptions();
				SortedSet names = new TreeSet(importOptions);
				String[] options = new String[names.size()];
				names.toArray(options);

				if (options.length == 0) {

					throw new ExecutionException(
							"There are no template configurations present in the mart.");

				}

				String option;
				if (names.contains(action.parameters.get(4))) {
					option = (String) action.parameters.get(4);
				} else {

					throw new ExecutionException((String) action.parameters
							.get(4)
							+ " is not a dataset.");

				}

				MartEditor editor = new MartEditor();
				templateConfigurations = new DatasetConfigTreeWidget(null,
						editor, null, detailedDataSource.getUser(), null, null,
						detailedDataSource.getSchema(), option, null);

			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("open")) {

			if (action.parameters.get(0).equals("dataset")) {

				if (action.parameters.get(2).equals("of")
						&& action.parameters.get(3).equals("mart")
						&& action.parameters.get(5).equals("in")
						&& action.parameters.get(6).equals("directory")) {

					datasetName = (String) action.parameters.get(1);
					martName = (String) action.parameters.get(4);
					datasetXMLURL = (String) action.parameters.get(7) + "/"
							+ (String) action.parameters.get(1)
							+ "_template.template.xml";

					filterName = new LinkedList();
					filterTitle = new LinkedList();
					featureName = new LinkedList();
					featureTitle = new LinkedList();
					featureDefault = new LinkedList();
					columnName = new LinkedList();
					linkoutURL = new LinkedList();

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
					detailedDataSource = new DetailedDataSource("mysql", // database type
							paramHost, // hostname
							paramPort, // port
							paramDatabase, // schema name (database)
							schema, // schema name
							paramUser, // username
							paramPassword, // password
							10, // ??
							paramDriver, // driver
							"Default Source Name");
					databaseConnection = detailedDataSource.getConnection();
					configUtils = new DatabaseDatasetConfigUtils(
							new DatasetConfigXMLUtils(true),
							detailedDataSource, false); // last Boolean const: read-only

					MartEditor.putDatabaseDatasetConfigUtilsBySchema(
							configUtils, schema);

					MartEditor.setUser(paramUser);
					MartEditor.setDetailedDataSource(detailedDataSource);
					MartEditor.setDatabaseDatasetConfigUtils(configUtils);

					DetailedDataSource.close(databaseConnection);
					System.out.println("done");

				} else if (action.parameters.get(1).equals("file")) {

					mart = MartBuilderXML.load(new File(
							(String) action.parameters.get(2)));

				}

			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("rename")) {

			if (action.parameters.get(0).equals("column")
					&& action.parameters.get(2).equals("of")
					&& action.parameters.get(3).equals("table")
					&& action.parameters.get(5).equals("as")) {

				executeInBash("./rename_column.sh " + username + " " + password + " "
								+ host + " " + port + " " + martscriptDB + " "
								+ (String) action.parameters.get(4) + " "
								+ (String) action.parameters.get(1) + " "
								+ (String) action.parameters.get(6));

			} else if (action.parameters.get(0).equals("table")
					&& action.parameters.get(2).equals("to")) {

				executeInBash("./rename_table.sh " + username + " " + password + " "
						+ host + " " + port + " " + martscriptDB + " "
						+ (String) action.parameters.get(1) + " "
						+ (String) action.parameters.get(3));
				
			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}
			
		} else if (action.name.equals("save")) {

			if (action.parameters.get(0).equals("all")
					&& action.parameters.get(1).equals("changes")
					&& action.parameters.get(2).equals("of")
					&& action.parameters.get(3).equals("mart")) {

				java.util.Date now = new java.util.Date();
				SimpleDateFormat dateFormat = new SimpleDateFormat(
						"yyyyMMddHHmmss");
				
				// Final file that is used as a patch to alter a saved XML meta-data file.
				String patchFile = "/tmp/xml.patch." + dateFormat.format(now);
				
				// Temporary files that are used in the process of creating the
				// final patch file.
				String aFile = "/tmp/patch.a." + dateFormat.format(now);
				String bFile = "/tmp/patch.b." + dateFormat.format(now);
				String cFile = "/tmp/patch.c." + dateFormat.format(now);

				String commandStage1 = "./patch_xml_template_stage1.sh " + "\""
						+ groupTitle + "\" " + "\"" + groupDescription + "\" "
						+ groupName + " " + "\"" + collectionTitle + "\" "
						+ collectionName + " "
						+ (String) action.parameters.get(4);

				executeInBash(commandStage1 + " > " + aFile);
				
				String commandStage2 = "";

				for (int i = 0; i < filterName.size(); i++) {
					if (!columnName.get(i).equals("")) {
						commandStage2 = "./patch_xml_template_complex_stage2.sh "
								+ host + " "
								+ port + " "
								+ username + " "
								+ password + " "
								+ martName + " "
								+ datasetName + " "
								+ (String) filterName.get(i) + " "
								+ (String) featureName.get(i) + " "
								+ "\"" + (String) filterTitle.get(i) + "\" "
								+ "\"" + (String) featureTitle.get(i) + "\" "
								+ "\"" + (String) linkoutURL.get(i) + "\" "
								+ (String) columnName.get(i) + " "
								+ (String) featureDefault.get(i);
					} else {
						commandStage2 = "./patch_xml_template_stage2.sh "
								+ host + " "
								+ port + " "
								+ username + " "
								+ password + " "
								+ martName + " "
								+ datasetName + " "
								+ (String) filterName.get(i) + " "
								+ (String) featureName.get(i) + " "
								+ "\"" + (String) filterTitle.get(i) + "\" "
								+ "\"" + (String) featureTitle.get(i) + "\" "
								+ "\"" + (String) linkoutURL.get(i) + "\" "
								+ (String) featureDefault.get(i);;
					}
					if (i % 2 == 0) {
						
						executeInBash(commandStage2 + " > " + bFile + " < " + aFile);
					
					} else {
						
						executeInBash(commandStage2 + " > " + aFile + " < " + bFile);
						
					}
				}

				String commandStage3 = "./patch_xml_template_stage3.sh";

				if (filterName.size() % 2 == 0) {
				
					executeInBash(commandStage3 + " > " + cFile + " < " + aFile);
					
				} else {
					
					executeInBash(commandStage3 + " > " + cFile + " < " + bFile);
					
				}
				
				String commandStage4 = "./patch_xml_template_stage4.sh "
						+ filter_limit_lines + " " + filter_list_lines + " "
						+ attribute_feature_lines;

				executeInBash(commandStage4 + " > " + patchFile + " < " + cFile);
				
				Process scriptProcess;
				int returnCode;

				executeInBash("xml_pp " + datasetXMLURL + " > " + datasetXMLURL + ".formatted");

				executeInBash("patch -l " + datasetXMLURL + ".formatted" + " " + patchFile);

				executeInBash("cp " + datasetXMLURL + ".formatted" + " "
								+ datasetXMLURL + " ; " + "rm " + datasetXMLURL
								+ ".formatted");

			} else if (action.parameters.get(0).equals("mart")
					&& action.parameters.get(1).equals("file")) {

				MartBuilderXML.save(mart, new File(martURL));

			} else if (action.parameters.get(0).equals("database")
					&& action.parameters.get(1).equals("datasets")
					&& action.parameters.get(2).equals("in")
					&& action.parameters.get(3).equals("directory")) {

				String oldUsername = username;
				username = MartEditor.getUser();
				// The second parameter is labelled 'martUser' and it has to
				// be set to "" for some unknown reason.
				String[] datasets = configUtils
						.getAllDatasetNames(username, "");

				for (int i = 0; i < datasets.length; i++) {
					String dataset = datasets[i];
					String[] internalNames = configUtils
							.getAllDatasetIDsForDataset(username, dataset);
					for (int j = 0; j < internalNames.length; j++) {
						String internalName = internalNames[j];

						DatasetConfig odsv = configUtils
								.getDatasetConfigByDatasetID(username, dataset,
										internalName, schema);
						DSConfigAdaptor adaptor = new DatabaseDSConfigAdaptor(
								detailedDataSource, username, "", true, false,
								true, true);
						DatasetConfigIterator configs = adaptor
								.getDatasetConfigs();
						while (configs.hasNext()) {
							DatasetConfig lconfig = (DatasetConfig) configs
									.next();
							if (lconfig.getDataset().equals(dataset)
									&& lconfig.getDatasetID().equals(
											internalName)) {
								odsv = lconfig;
								break;
							}
						}
						adaptor.lazyLoad(odsv);
						try {
							File newFile = new File((String) action.parameters
									.get(4), odsv.getDataset() + ".xml");
							URLDSConfigAdaptor
									.StoreDatasetConfig(odsv, newFile);
						} catch (Exception e) {

							// There are various reasons why MartEditor could have failed..
							throw new ExecutionException(
									"A MartEditor specific exception occurred. Sorry.");

						}

					}
				}

				String[] templates = configUtils.getAllTemplateNames();
				for (int i = 0; i < templates.length; i++) {
					String template = templates[i];
					DatasetConfig odsv = new DatasetConfig("template", "",
							template + "_template", "", "", "", "", "", "", "",
							"", "", "", "", template, "", "", "", "");
					dscutils.loadDatasetConfigWithDocument(odsv, configUtils
							.getTemplateDocument(template));
					try {
						File newFile = new File((String) action.parameters
								.get(4), odsv.getDataset() + ".template.xml");
						URLDSConfigAdaptor.StoreDatasetConfig(odsv, newFile);
					} catch (Exception e) {

						throw new ExecutionException(
								"A MartEditor specific exception occurred. Sorry.");

					}
				}

				username = oldUsername;

			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("set")) {

			if (action.parameters.get(0).equals("default")) {

				if (action.parameters.get(1).equals("ensembl")
						&& action.parameters.get(2).equals("database")
						&& action.parameters.get(3).equals("to")) {

					ensemblDatabase = (String) action.parameters.get(4);

				} else if (action.parameters.get(1).equals("ensembl")
						&& action.parameters.get(2).equals("home")
						&& action.parameters.get(3).equals("path")
						&& action.parameters.get(4).equals("to")) {

					ensHomePath = (String) action.parameters.get(5);

				} else if (action.parameters.get(1).equals("ensembl")
						&& action.parameters.get(2).equals("version")
						&& action.parameters.get(3).equals("to")) {

					ensemblVersion = (String) action.parameters.get(4);

				} else if (action.parameters.get(1).equals("perl")
						&& action.parameters.get(2).equals("interpreter")
						&& action.parameters.get(3).equals("path")
						&& action.parameters.get(4).equals("to")) {

					perlPath = (String) action.parameters.get(5);

				} else if (action.parameters.get(1).equals("perl")
						&& action.parameters.get(2).equals("library")
						&& action.parameters.get(3).equals("path")
						&& action.parameters.get(4).equals("to")) {

					perl5libPaths = (String) action.parameters.get(5);

				} else if (action.parameters.get(1).equals("sequence")
						&& action.parameters.get(2).equals("mart")
						&& action.parameters.get(3).equals("scripts")
						&& action.parameters.get(4).equals("path")
						&& action.parameters.get(5).equals("to")) {

					sequenceMartScriptsPath = (String) action.parameters.get(6);

				} else if (action.parameters.get(1).equals("shell")
						&& action.parameters.get(2).equals("script")
						&& action.parameters.get(3).equals("path")
						&& action.parameters.get(4).equals("to")) {

					binDirectory = (String) action.parameters.get(5);
					System.out.println("Set binDirectory to " + binDirectory);

					try {

						Properties reverseErrorCodes = new Properties();

						reverseErrorCodes.load(new FileInputStream(binDirectory
								+ "/error_codes"));

						Enumeration e = reverseErrorCodes.keys();

						while (e.hasMoreElements()) {

							Object key = e.nextElement();

							errorCodes.put(reverseErrorCodes.get(key), key);

						}

					} catch (IOException ioe) {

						throw new ExecutionException(
								"Could not open the error code configuration file: "
										+ binDirectory + "/error_codes");

					}

				} else if (action.parameters.get(1).equals("host")
						&& action.parameters.get(2).equals("to")) {

					host = (String) action.parameters.get(3);

				} else if (action.parameters.get(1).equals("password")
						&& action.parameters.get(2).equals("to")) {

					password = (String) action.parameters.get(3);

				} else if (action.parameters.get(1).equals("port")
						&& action.parameters.get(2).equals("to")) {

					port = (String) action.parameters.get(3);

				} else if (action.parameters.get(1).equals("taxonomy")
						&& action.parameters.get(2).equals("dump")
						&& action.parameters.get(3).equals("path")
						&& action.parameters.get(4).equals("to")) {

					taxonomyDump = (String) action.parameters.get(5);

				} else if (action.parameters.get(1).equals("username")
						&& action.parameters.get(2).equals("to")) {

					username = (String) action.parameters.get(3);

				}

			} else if (action.parameters.get(0).equals("description")
					&& action.parameters.get(1).equals("of")
					&& action.parameters.get(2).equals("attribute")
					&& action.parameters.get(3).equals("group")
					&& action.parameters.get(5).equals("as")) {

				if (!groupName.equals(action.parameters.get(4))) {

					// ..

				}

				groupDescription = "";

				for (int i = 6; i < action.parameters.size(); i++)
					groupDescription += action.parameters.get(i) + " ";

				groupDescription = groupDescription.trim();

			} else if (action.parameters.get(0).equals("linkout")
					&& action.parameters.get(1).equals("url")
					&& action.parameters.get(2).equals("to")) {

				linkoutURL.add(action.parameters.get(3));

			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("synchronize")) {

			if (action.parameters.get(0).equals("schemas")) {

				List schemas = new ArrayList(mart.getSchemas().values());
				Iterator schemasIterator = schemas.iterator();
				while (schemasIterator.hasNext()) {

					Transaction.start(true);
					Schema schema = (Schema) schemasIterator.next();
					schema.synchronise();
					Transaction.end();

				}

			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("update")) {

			if (action.parameters.get(0).equals("database")
					&& action.parameters.get(1).equals("datasets")
					&& action.parameters.get(2).equals("of")
					&& action.parameters.get(3).equals("mart")
					&& action.parameters.get(5).equals("database")) {

				try {
					if (!configUtils.baseDSConfigTableExists()) {

						throw new ExecutionException(
								"The mart contains no datasets.");

					}

					// The second parameter is called 'martUser' and has to be ""
					// for some unknown reason.
					String[] datasets = configUtils.getAllDatasetNames(
							username, "");
					
					for (int i = 0; i < datasets.length; i++) {
						String dataset = datasets[i];
						String[] internalNames = configUtils
								.getAllDatasetIDsForDataset(username, dataset);
						for (int j = 0; j < internalNames.length; j++) {
							String internalName = internalNames[j];

							DatasetConfig odsv = null;
							DSConfigAdaptor adaptor = new DatabaseDSConfigAdaptor(
									detailedDataSource, username, "", true,
									false, true, true);
							DatasetConfigIterator configs = adaptor
									.getDatasetConfigs();
							while (configs.hasNext()) {
								DatasetConfig lconfig = (DatasetConfig) configs
										.next();
								if (lconfig.getDataset().equals(dataset)
										&& lconfig.getDatasetID().equals(
												internalName)) {
									odsv = lconfig;
									break;
								}
							}
							odsv = configUtils.getXSLTransformedConfig(odsv);
							DatasetConfig dsv = configUtils
									.getValidatedDatasetConfig(odsv);
							String datasetVersion = dsv.getVersion();
							String newDatasetVersion = configUtils
									.getNewVersion(dsv.getDataset());
							if (datasetVersion != null
									&& datasetVersion != ""
									&& !datasetVersion
											.equals(newDatasetVersion)) {
								dsv.setVersion(newDatasetVersion);
								if (dsv.getDisplayName() != null
										&& dsv.getDisplayName().indexOf("(") > 0) {
									String newDisplayName = dsv
											.getDisplayName().split("\\(")[0]
											+ "(" + newDatasetVersion + ")";
									dsv.setDisplayName(newDisplayName);
								}
							}
							dsv.setOptionalParameter(odsv
									.getOptionalParameter());
							dsv.setEntryLabel(odsv.getEntryLabel());
							configUtils.updateLinkVersions(dsv);

							// MySQL specific:
							String schema = null;
							schema = this.schema;

							DatasetConfig templateConfig = configUtils
									.getNewFiltsAtts(schema, dsv, true);
							dsv = configUtils.getXSLTransformedConfig(dsv);

							configUtils.storeDatasetConfiguration(username, dsv
									.getInternalName(), dsv.getDisplayName(),
									dsv.getDataset(), dsv.getDescription(),
									MartEditor.getDatasetConfigXMLUtils()
											.getDocumentForDatasetConfig(dsv),
									true, dsv.getType(), dsv.getVisible(), dsv
											.getVersion(), dsv.getDatasetID(),
									dsv.getMartUsers(), dsv.getInterfaces(),
									dsv);

						}
					}
				} catch (Exception e) {

					throw new ExecutionException(
							"A MartEditor specific exception occurred. Sorry.");

				}

			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else if (action.name.equals("upload")) {

			if (action.parameters.get(0).equals("database")
					&& action.parameters.get(1).equals("datasets")
					&& action.parameters.get(2).equals("from")
					&& action.parameters.get(3).equals("directory")) {

				File[] files = new File((String) action.parameters.get(4))
						.listFiles();
				configUtils.dropMetaTables();

				// have to upload templates first
				for (int i = 0; i < files.length; i++) {
					File file = files[i];

					URL url = file.toURL();
					// System.out.println(file.getName());

					if (file.getName().endsWith(".template.xml")) {
						DSConfigAdaptor adaptor = new URLDSConfigAdaptor(url,
								true, true);
						DatasetConfig odsv = (DatasetConfig) adaptor
								.getDatasetConfigs().next();
						// DatasetConfig odsv = new
						// DatasetConfig("template","",template+"_template","","","","","","","","","","","",template,"","");
						// dscutils.loadDatasetConfigWithDocument(odsv,dbutils.getTemplateDocument(template));
						odsv.setSoftwareVersion(configUtils
								.getSoftwareVersion());
						configUtils.storeTemplateXML(odsv, odsv.getTemplate());

						// DatasetConfig odsv = (DatasetConfig)
						// adaptor.getDatasetConfigs().next();

					}
				}

				for (int i = 0; i < files.length; i++) {
					File file = files[i];

					URL url = file.toURL();

					if (file.getName().endsWith(".template.xml")) {
						continue;
					} else {
						// ignoreCache, includeHiddenMembers
						DSConfigAdaptor adaptor = new URLDSConfigAdaptor(url,
								true, true);
						DatasetConfig odsv = (DatasetConfig) adaptor
								.getDatasetConfigs().next();
						odsv.setDatasetID("");
						// export osdv

						// check this.. joachim
						String martUsers = "default";
						String interfaces = "default";

						// convert config to latest version using xslt
						MartEditor.setDatasetConfigXMLUtils(dscutils);
						odsv = configUtils.getXSLTransformedConfig(odsv);

						try {
							configUtils.storeDatasetConfiguration(username,
									odsv.getInternalName(), odsv
											.getDisplayName(), odsv
											.getDataset(), odsv
											.getDescription(), configUtils
											.getDatasetConfigXMLUtils()
											.getDocumentForDatasetConfig(odsv),
									true, odsv.getType(), odsv.getVisible(),
									odsv.getVersion(), odsv.getDatasetID(),
									martUsers, interfaces, odsv);
						} catch (Exception e) {

							throw new ExecutionException(
									"A MartEditor specific exception occurred. Sorry.");

						}
					}
				}
			} else {

				throw new ExecutionException(
						"The command is recognized, but the arguments are not understood by the interpreter.");

			}

		} else {

			throw new ExecutionException(
					"This command is not recognized by the interpreter.");

		}

	}

}
