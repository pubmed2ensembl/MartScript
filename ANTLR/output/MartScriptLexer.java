// $ANTLR 3.1.2 /Users/joachim/workspace/MartScript/ANTLR/MartScript.g 2010-01-11 16:33:15

import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class MartScriptLexer extends Lexer {
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

    public MartScriptLexer() {;} 
    public MartScriptLexer(CharStream input) {
        this(input, new RecognizerSharedState());
    }
    public MartScriptLexer(CharStream input, RecognizerSharedState state) {
        super(input,state);

    }
    public String getGrammarFileName() { return "/Users/joachim/workspace/MartScript/ANTLR/MartScript.g"; }

    // $ANTLR start "T__10"
    public final void mT__10() throws RecognitionException {
        try {
            int _type = T__10;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:3:7: ( '#' )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:3:9: '#'
            {
            match('#'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "T__10"

    // $ANTLR start "LETTER"
    public final void mLETTER() throws RecognitionException {
        try {
            int _type = LETTER;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:47:2: ( 'a' .. 'z' | 'A' .. 'Z' )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:
            {
            if ( (input.LA(1)>='A' && input.LA(1)<='Z')||(input.LA(1)>='a' && input.LA(1)<='z') ) {
                input.consume();

            }
            else {
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "LETTER"

    // $ANTLR start "SEPERATOR"
    public final void mSEPERATOR() throws RecognitionException {
        try {
            int _type = SEPERATOR;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:51:2: ( '_' | '-' )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:
            {
            if ( input.LA(1)=='-'||input.LA(1)=='_' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SEPERATOR"

    // $ANTLR start "DIGIT"
    public final void mDIGIT() throws RecognitionException {
        try {
            int _type = DIGIT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:55:2: ( '0' .. '9' )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:55:4: '0' .. '9'
            {
            matchRange('0','9'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "DIGIT"

    // $ANTLR start "OTHERS"
    public final void mOTHERS() throws RecognitionException {
        try {
            int _type = OTHERS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:59:2: ( '/' | '.' | ':' | ',' | ';' | '~' | '?' | '\\\\' | '=' | '\\\"' | '#' | '|' | '%' | '£' | '$' | '&' | '*' | '(' | ')' | '[' | ']' | '@' )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:
            {
            if ( (input.LA(1)>='\"' && input.LA(1)<='&')||(input.LA(1)>='(' && input.LA(1)<='*')||input.LA(1)==','||(input.LA(1)>='.' && input.LA(1)<='/')||(input.LA(1)>=':' && input.LA(1)<=';')||input.LA(1)=='='||(input.LA(1)>='?' && input.LA(1)<='@')||(input.LA(1)>='[' && input.LA(1)<=']')||input.LA(1)=='|'||input.LA(1)=='~'||input.LA(1)=='\u00A3' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "OTHERS"

    // $ANTLR start "NEWLINE"
    public final void mNEWLINE() throws RecognitionException {
        try {
            int _type = NEWLINE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:64:2: ( ( '\\r' )? '\\n' )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:64:4: ( '\\r' )? '\\n'
            {
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:64:4: ( '\\r' )?
            int alt1=2;
            int LA1_0 = input.LA(1);

            if ( (LA1_0=='\r') ) {
                alt1=1;
            }
            switch (alt1) {
                case 1 :
                    // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:64:4: '\\r'
                    {
                    match('\r'); 

                    }
                    break;

            }

            match('\n'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "NEWLINE"

    // $ANTLR start "WHITESPACE"
    public final void mWHITESPACE() throws RecognitionException {
        try {
            int _type = WHITESPACE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:68:2: ( ' ' | '\\t' )
            // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:
            {
            if ( input.LA(1)=='\t'||input.LA(1)==' ' ) {
                input.consume();

            }
            else {
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "WHITESPACE"

    public void mTokens() throws RecognitionException {
        // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:1:8: ( T__10 | LETTER | SEPERATOR | DIGIT | OTHERS | NEWLINE | WHITESPACE )
        int alt2=7;
        switch ( input.LA(1) ) {
        case '#':
            {
            alt2=1;
            }
            break;
        case 'A':
        case 'B':
        case 'C':
        case 'D':
        case 'E':
        case 'F':
        case 'G':
        case 'H':
        case 'I':
        case 'J':
        case 'K':
        case 'L':
        case 'M':
        case 'N':
        case 'O':
        case 'P':
        case 'Q':
        case 'R':
        case 'S':
        case 'T':
        case 'U':
        case 'V':
        case 'W':
        case 'X':
        case 'Y':
        case 'Z':
        case 'a':
        case 'b':
        case 'c':
        case 'd':
        case 'e':
        case 'f':
        case 'g':
        case 'h':
        case 'i':
        case 'j':
        case 'k':
        case 'l':
        case 'm':
        case 'n':
        case 'o':
        case 'p':
        case 'q':
        case 'r':
        case 's':
        case 't':
        case 'u':
        case 'v':
        case 'w':
        case 'x':
        case 'y':
        case 'z':
            {
            alt2=2;
            }
            break;
        case '-':
        case '_':
            {
            alt2=3;
            }
            break;
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            {
            alt2=4;
            }
            break;
        case '\"':
        case '$':
        case '%':
        case '&':
        case '(':
        case ')':
        case '*':
        case ',':
        case '.':
        case '/':
        case ':':
        case ';':
        case '=':
        case '?':
        case '@':
        case '[':
        case '\\':
        case ']':
        case '|':
        case '~':
        case '\u00A3':
            {
            alt2=5;
            }
            break;
        case '\n':
        case '\r':
            {
            alt2=6;
            }
            break;
        case '\t':
        case ' ':
            {
            alt2=7;
            }
            break;
        default:
            NoViableAltException nvae =
                new NoViableAltException("", 2, 0, input);

            throw nvae;
        }

        switch (alt2) {
            case 1 :
                // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:1:10: T__10
                {
                mT__10(); 

                }
                break;
            case 2 :
                // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:1:16: LETTER
                {
                mLETTER(); 

                }
                break;
            case 3 :
                // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:1:23: SEPERATOR
                {
                mSEPERATOR(); 

                }
                break;
            case 4 :
                // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:1:33: DIGIT
                {
                mDIGIT(); 

                }
                break;
            case 5 :
                // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:1:39: OTHERS
                {
                mOTHERS(); 

                }
                break;
            case 6 :
                // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:1:46: NEWLINE
                {
                mNEWLINE(); 

                }
                break;
            case 7 :
                // /Users/joachim/workspace/MartScript/ANTLR/MartScript.g:1:54: WHITESPACE
                {
                mWHITESPACE(); 

                }
                break;

        }

    }


 

}