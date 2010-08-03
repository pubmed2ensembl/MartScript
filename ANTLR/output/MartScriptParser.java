// $ANTLR 3.1.2 /Users/joachim/workspace/MartScript/ANTLR/MartScript.g 2010-01-11 16:33:15

import java.util.*;
import org.antlr.runtime.BitSet;

import org.bergmanlab.martscript.*;


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class MartScriptParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "NEWLINE", "LETTER", "SEPERATOR", "DIGIT", "WHITESPACE", "OTHERS", "'#'"
    };
    public static final int OTHERS=9;
    public static final int LETTER=5;
    public static final int EOF=-1;
    public static final int T__10=10;
    public static final int DIGIT=7;
    public static final int SEPERATOR=6;
    public static final int WHITESPACE=8;
    public static final int NEWLINE=4;

    // delegates
    // delegators


        public MartScriptParser(TokenStream input) {
            this(input, new RecognizerSharedState());
        }
        public MartScriptParser(TokenStream input, RecognizerSharedState state) {
            super(input, state);
             
        }
        

    public String[] getTokenNames() { return MartScriptParser.tokenNames; }
    public String getGrammarFileName() { return "/Users/joachim/workspace/MartScript/ANTLR/MartScript.g"; }


    LinkedList source = new LinkedList();
    LinkedList parameters = new LinkedList();



    // $ANTLR start "script"
    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:15:1: script : ( action | comment | NEWLINE )* ;
    public final void script() throws RecognitionException {
        try {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:16:2: ( ( action | comment | NEWLINE )* )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:16:4: ( action | comment | NEWLINE )*
            {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:16:4: ( action | comment | NEWLINE )*
            loop1:
            do {
                int alt1=4;
                switch ( input.LA(1) ) {
                case LETTER:
                    {
                    alt1=1;
                    }
                    break;
                case 10:
                    {
                    alt1=2;
                    }
                    break;
                case NEWLINE:
                    {
                    alt1=3;
                    }
                    break;

                }

                switch (alt1) {
            	case 1 :
            	    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:16:5: action
            	    {
            	    pushFollow(FOLLOW_action_in_script24);
            	    action();

            	    state._fsp--;


            	    }
            	    break;
            	case 2 :
            	    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:16:14: comment
            	    {
            	    pushFollow(FOLLOW_comment_in_script28);
            	    comment();

            	    state._fsp--;


            	    }
            	    break;
            	case 3 :
            	    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:16:24: NEWLINE
            	    {
            	    match(input,NEWLINE,FOLLOW_NEWLINE_in_script32); 

            	    }
            	    break;

            	default :
            	    break loop1;
                }
            } while (true);

             new MartScript().processScript(source); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "script"


    // $ANTLR start "comment"
    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:20:1: comment : '#' ( LETTER | SEPERATOR | DIGIT | WHITESPACE | OTHERS )* NEWLINE ;
    public final void comment() throws RecognitionException {
        try {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:21:2: ( '#' ( LETTER | SEPERATOR | DIGIT | WHITESPACE | OTHERS )* NEWLINE )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:21:4: '#' ( LETTER | SEPERATOR | DIGIT | WHITESPACE | OTHERS )* NEWLINE
            {
            match(input,10,FOLLOW_10_in_comment50); 
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:21:8: ( LETTER | SEPERATOR | DIGIT | WHITESPACE | OTHERS )*
            loop2:
            do {
                int alt2=2;
                int LA2_0 = input.LA(1);

                if ( ((LA2_0>=LETTER && LA2_0<=OTHERS)) ) {
                    alt2=1;
                }


                switch (alt2) {
            	case 1 :
            	    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:
            	    {
            	    if ( (input.LA(1)>=LETTER && input.LA(1)<=OTHERS) ) {
            	        input.consume();
            	        state.errorRecovery=false;
            	    }
            	    else {
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        throw mse;
            	    }


            	    }
            	    break;

            	default :
            	    break loop2;
                }
            } while (true);

            match(input,NEWLINE,FOLLOW_NEWLINE_in_comment73); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "comment"


    // $ANTLR start "action"
    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:24:1: action : command NEWLINE ;
    public final void action() throws RecognitionException {
        Action command1 = null;


        try {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:25:2: ( command NEWLINE )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:25:4: command NEWLINE
            {
            pushFollow(FOLLOW_command_in_action85);
            command1=command();

            state._fsp--;

            match(input,NEWLINE,FOLLOW_NEWLINE_in_action87); 
             source.add(command1); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "action"


    // $ANTLR start "command"
    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:29:1: command returns [Action value] : name parameters ;
    public final Action command() throws RecognitionException {
        Action value = null;

        MartScriptParser.name_return name2 = null;

        List parameters3 = null;


        try {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:30:2: ( name parameters )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:30:4: name parameters
            {
            pushFollow(FOLLOW_name_in_command107);
            name2=name();

            state._fsp--;

            pushFollow(FOLLOW_parameters_in_command109);
            parameters3=parameters();

            state._fsp--;

             value = new Action((name2!=null?name2.value:null),parameters3); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return value;
    }
    // $ANTLR end "command"

    public static class name_return extends ParserRuleReturnScope {
        public String value;
    };

    // $ANTLR start "name"
    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:34:1: name returns [String value] : LETTER ( LETTER | SEPERATOR | DIGIT )* ;
    public final MartScriptParser.name_return name() throws RecognitionException {
        MartScriptParser.name_return retval = new MartScriptParser.name_return();
        retval.start = input.LT(1);

        try {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:35:2: ( LETTER ( LETTER | SEPERATOR | DIGIT )* )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:35:4: LETTER ( LETTER | SEPERATOR | DIGIT )*
            {
            match(input,LETTER,FOLLOW_LETTER_in_name129); 
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:35:11: ( LETTER | SEPERATOR | DIGIT )*
            loop3:
            do {
                int alt3=2;
                int LA3_0 = input.LA(1);

                if ( ((LA3_0>=LETTER && LA3_0<=DIGIT)) ) {
                    alt3=1;
                }


                switch (alt3) {
            	case 1 :
            	    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:
            	    {
            	    if ( (input.LA(1)>=LETTER && input.LA(1)<=DIGIT) ) {
            	        input.consume();
            	        state.errorRecovery=false;
            	    }
            	    else {
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        throw mse;
            	    }


            	    }
            	    break;

            	default :
            	    break loop3;
                }
            } while (true);

             retval.value = input.toString(retval.start,input.LT(-1)); 

            }

            retval.stop = input.LT(-1);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "name"


    // $ANTLR start "parameters"
    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:38:1: parameters returns [List value] : ( WHITESPACE argument )* ;
    public final List parameters() throws RecognitionException {
        List value = null;

        try {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:39:2: ( ( WHITESPACE argument )* )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:39:4: ( WHITESPACE argument )*
            {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:39:4: ( WHITESPACE argument )*
            loop4:
            do {
                int alt4=2;
                int LA4_0 = input.LA(1);

                if ( (LA4_0==WHITESPACE) ) {
                    alt4=1;
                }


                switch (alt4) {
            	case 1 :
            	    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:39:5: WHITESPACE argument
            	    {
            	    match(input,WHITESPACE,FOLLOW_WHITESPACE_in_parameters161); 
            	    pushFollow(FOLLOW_argument_in_parameters163);
            	    argument();

            	    state._fsp--;


            	    }
            	    break;

            	default :
            	    break loop4;
                }
            } while (true);

             value = (List)parameters.clone(); parameters.clear(); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return value;
    }
    // $ANTLR end "parameters"

    public static class argument_return extends ParserRuleReturnScope {
    };

    // $ANTLR start "argument"
    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:42:1: argument : ( LETTER | SEPERATOR | DIGIT | OTHERS )+ ;
    public final MartScriptParser.argument_return argument() throws RecognitionException {
        MartScriptParser.argument_return retval = new MartScriptParser.argument_return();
        retval.start = input.LT(1);

        try {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:43:2: ( ( LETTER | SEPERATOR | DIGIT | OTHERS )+ )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:43:4: ( LETTER | SEPERATOR | DIGIT | OTHERS )+
            {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:43:4: ( LETTER | SEPERATOR | DIGIT | OTHERS )+
            int cnt5=0;
            loop5:
            do {
                int alt5=2;
                int LA5_0 = input.LA(1);

                if ( ((LA5_0>=LETTER && LA5_0<=DIGIT)||LA5_0==OTHERS) ) {
                    alt5=1;
                }


                switch (alt5) {
            	case 1 :
            	    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:
            	    {
            	    if ( (input.LA(1)>=LETTER && input.LA(1)<=DIGIT)||input.LA(1)==OTHERS ) {
            	        input.consume();
            	        state.errorRecovery=false;
            	    }
            	    else {
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        throw mse;
            	    }


            	    }
            	    break;

            	default :
            	    if ( cnt5 >= 1 ) break loop5;
                        EarlyExitException eee =
                            new EarlyExitException(5, input);
                        throw eee;
                }
                cnt5++;
            } while (true);

             parameters.add(input.toString(retval.start,input.LT(-1))); 

            }

            retval.stop = input.LT(-1);

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "argument"

    // Delegated rules


 

    public static final BitSet FOLLOW_action_in_script24 = new BitSet(new long[]{0x0000000000000432L});
    public static final BitSet FOLLOW_comment_in_script28 = new BitSet(new long[]{0x0000000000000432L});
    public static final BitSet FOLLOW_NEWLINE_in_script32 = new BitSet(new long[]{0x0000000000000432L});
    public static final BitSet FOLLOW_10_in_comment50 = new BitSet(new long[]{0x00000000000003F0L});
    public static final BitSet FOLLOW_set_in_comment52 = new BitSet(new long[]{0x00000000000003F0L});
    public static final BitSet FOLLOW_NEWLINE_in_comment73 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_command_in_action85 = new BitSet(new long[]{0x0000000000000010L});
    public static final BitSet FOLLOW_NEWLINE_in_action87 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_name_in_command107 = new BitSet(new long[]{0x0000000000000100L});
    public static final BitSet FOLLOW_parameters_in_command109 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LETTER_in_name129 = new BitSet(new long[]{0x00000000000000E2L});
    public static final BitSet FOLLOW_set_in_name131 = new BitSet(new long[]{0x00000000000000E2L});
    public static final BitSet FOLLOW_WHITESPACE_in_parameters161 = new BitSet(new long[]{0x00000000000002E0L});
    public static final BitSet FOLLOW_argument_in_parameters163 = new BitSet(new long[]{0x0000000000000102L});
    public static final BitSet FOLLOW_set_in_argument179 = new BitSet(new long[]{0x00000000000002E2L});

}