grammar MartScript;

@header {
import java.util.*;
import org.antlr.runtime.BitSet;

import org.bergmanlab.martscript.*;
}

@members {
LinkedList source = new LinkedList();
LinkedList parameters = new LinkedList();
}

script
	:	(action | comment | NEWLINE)*
			{ new MartScript().processScript(source); }
	;

comment
	:	'#' (LETTER | SEPERATOR | DIGIT | WHITESPACE | OTHERS)* NEWLINE
	;
	
action
	:	command NEWLINE
			{ source.add($command.value); }
	;

command returns [Action value]
	:	name parameters
			{ $value = new Action($name.value,$parameters.value); }
	;

name returns [String value]
	:	LETTER (LETTER | SEPERATOR | DIGIT)* { $value = $text; }
	;
	
parameters returns [List value]
	:	(WHITESPACE argument)* { $value = (List)parameters.clone(); parameters.clear(); }
	;
	
argument
	:	(LETTER | SEPERATOR | DIGIT | OTHERS)+ { parameters.add($text); }
	;
		
LETTER
	:	'a'..'z' | 'A'..'Z'
	;

SEPERATOR
	:	'_' | '-'
	;

DIGIT
	:	'0'..'9'
	;

OTHERS
	:	'/' | '.' | ':' | ',' | ';' | '~' | '?' | '\\' | '=' | '\"' | '#' |
		'|' | '%' | '£' | '$' | '&' | '*' | '(' | ')' | '[' | ']' | '@'
	;
	
NEWLINE
	:	'\r'? '\n'
	;

WHITESPACE
	:	' ' | '\t'
	;
	
