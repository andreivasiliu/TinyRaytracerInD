module sceneparser.SceneLoader;

import sceneparser.expressions.BooleanExpression;
import sceneparser.expressions.ColorExpression;
import sceneparser.expressions.ComparisonExpression;
import sceneparser.expressions.GenericExpression;
import sceneparser.expressions.IdentifierExpression;
import sceneparser.expressions.MathBinaryExpression;
import sceneparser.expressions.MathExpressionId;
import sceneparser.expressions.MathNegativeExpression;
import sceneparser.expressions.NumberExpression;
import sceneparser.expressions.ObjectExpression;
import sceneparser.expressions.StringExpression;
import sceneparser.expressions.TextureFileExpression;
import sceneparser.expressions.VectorExpression;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.IdentifierList;
import sceneparser.general.ParameterList;
import sceneparser.general.SceneLoaderException;
import sceneparser.general.Statement;
import sceneparser.general.StatementList;
import sceneparser.general.Value;
import sceneparser.statements.AppendLightStatement;
import sceneparser.statements.AssignmentStatement;
import sceneparser.statements.BoundingObjectStatement;
import sceneparser.statements.CallStatement;
import sceneparser.statements.DimensionStatement;
import sceneparser.statements.DisplayStatement;
import sceneparser.statements.DrawStatement;
import sceneparser.statements.FunctionStatement;
import sceneparser.statements.IfThenElseStatement;
import sceneparser.statements.IfThenStatement;
import sceneparser.statements.SetCameraStatement;
import sceneparser.statements.TransformationStatement;
import sceneparser.statements.WhileStatement;
import goldengine.goldparser;
import goldengine.rule;
import raytracer.RayTracer;
import sceneparser.GrammarConstants;

import tango.io.device.Conduit;
import tango.io.device.Array;
import tango.io.Stdout;
import tango.util.log.Config;
import Utf = tango.text.convert.Utf;

const COMPILED_GRAMMAR_TABLE = import("GrammarFile.cgt");

class SceneLoader {
    private {
        Grammar mGrammar;
        GOLDParser mParser;
        Object mRoot;
    }
    
    public Context context;

    this() {
        loadGrammar();
        mParser = new GOLDParser(mGrammar);
        mParser.onReduce = &reduce;
        mParser.onAccept = &accept;
        mParser.onProgress = &progress;
        
        context = new Context(this, null);
    }
    
    public void setFrame(uint frame)
    {
        context.variables["frame"] = new NumberValue(frame);
    }
    
    //This will load the grammar file on instanciation
    private void loadGrammar() {
        //Load grammar from an external file
        //mGrammar = new Grammar("Tiny-CAD Grammar.cgt");
        
        auto mem = new Array(COMPILED_GRAMMAR_TABLE.length);
        mem.write(COMPILED_GRAMMAR_TABLE);
        mGrammar = new Grammar(mem);
    }

    //Parse a source string
    //The parse is successful if no exception is thrown
    public void execute(wchar[] source) {
        mRoot = null;
        mParser.loadSource(source);
        run();
    }
    
    //Parse a stream source
    //The parse is successful if no exception is thrown
    public void execute(Conduit source) {
        mRoot = null;
        mParser.loadSource(source);
        run();
    }
    
    //When the parse is successful, you can retrieve the
    //parse tree root you returned for the start symbol reduction
    public Object root() {
        return mRoot;
    }
    
    public void setRaytracer(RayTracer rt)
    {
        context.rt = rt;
    }
    
    private void run() {
        mParser.parse();
        
        Statement statement = cast(Statement) root();
        statement.Execute();
    }

    private void progress(int line, int pos, int size) {
        //Add code to display the progress to the user here
    }

    //Create an object for the current reduction from strings
    //and objects in tokens
    private Object reduce(Rule redRule, Token[] tokens) {
        //Refer to token strings with
        //    tokens[i].text
        //Refer to reduction objects with
        //    tokens[i].data

        version(none)
        {
            Stdout("Reducing rule: ");
            Stdout(redRule.toString());
            Stdout().newline();
        }
        
        Expression getExpressionFromSymbol(int tokenIndex, string tokenText)
        {
            switch (tokenIndex)
            {
                case Symbol_Id:
                    return new IdentifierExpression(context, tokenText);
                case Symbol_Stringliteral:
                    // Trim the quotes around string literals.
                    return new StringExpression(context, tokenText[1 .. $-1]);
                default:
                    return new GenericExpression(context, tokenText);
            }
        }
        
        Object getTokenData(int index)
        {
            Token t = tokens[index];
            
            if (t.data is null)
            {
                if (t.text.length == 0)
                    throw new Exception("Encountered a token with null data!");
                
                return getExpressionFromSymbol(t.parentSymbol.index,
                        Utf.toString(t.text));
            }
            else
                return t.data; 
        }
        
        Statement getStatement(int index)
        {
            return cast(Statement) getTokenData(index);
        }
        
        string getToken(int index)
        {
            GenericExpression expr = cast(GenericExpression) getTokenData(index);
            return expr.getValue.toString;
        }

        Expression getExpression(int index)
        {
            return cast(Expression) getTokenData(index);
        }
        
        switch (redRule.index) {
            // <Start> ::= <Statements>
            case Rule_Start:
                return new DimensionStatement(context, getStatement(0));
                
            // <Statements> ::= <Statement> <Statements>
            case Rule_Statements:
                return new StatementList(context, getStatement(0), getStatement(1));
                
            // <Statements> ::= <Statement>
            case Rule_Statements2:
                return getStatement(0);
                //TODO: check for correctness
                //return new StatementList(context, getStatement(0), null);
                
            // <Statement> ::= <Command> '(' <Param List> ')'
            case Rule_Statement_Lparan_Rparan:
                if (getToken(0) == "display")
                    return new DisplayStatement(context, getExpression(2));
                else if (getToken(0) == "draw")
                    return new DrawStatement(context, getExpression(2));
                else
                    throw new SceneLoaderException("Unknown command: " ~ getToken(0));
                
            // <Statement> ::= Id '=' <Object>
            case Rule_Statement_Id_Eq:
                return new AssignmentStatement(context, getExpression(0), getExpression(2), false);

            // <Statement> ::= local Id '=' <Object>
            case Rule_Statement_Local_Id_Eq:
                // FIXME: complete this
                return new AssignmentStatement(context, getExpression(1), getExpression(3), true);
                
            // <Statement> ::= if <Bool Expression> then <Statements> end
            case Rule_Statement_If_Then_End:
                return new IfThenStatement(context, getExpression(1), getStatement(3));

            // <Statement> ::= if <Bool Expression> then <Statements> else <Statements> end
            case Rule_Statement_If_Then_Else_End:
                return new IfThenElseStatement(context, getExpression(1), getStatement(3), getStatement(5));

            // <Statement> ::= while <Bool Expression> do <Statements> end
            case Rule_Statement_While_Do_End:
                return new WhileStatement(context, getExpression(1), getStatement(3));
                
            // <Statement> ::= call Id '(' <Param List> ')'
            case Rule_Statement_Call_Id_Lparan_Rparan:
                return new CallStatement(context, getExpression(1), getExpression(3));
                
            // <Statement> ::= function Id '(' <Id List> ')' <Statements> end
            case Rule_Statement_Function_Id_Lparan_Rparan_End:
                return new FunctionStatement(context, getExpression(1), 
                        getExpression(3), getStatement(5));
                
            // <Statement> ::= 'set camera' '(' <Param List> ')'
            case Rule_Statement_Setcamera_Lparan_Rparan:
                return new SetCameraStatement(context, getExpression(2));

            // <Statement> ::= 'append light' '(' <Param List> ')'
            case Rule_Statement_Appendlight_Lparan_Rparan:
                return new AppendLightStatement(context, getExpression(2));

            // <Statement> ::= do <Statements> end
            case Rule_Statement_Do_End:
                return getStatement(1);
            
            // <Statement> ::= <Transformation> '(' <Param List> ')' <Statement>
            case Rule_Statement_Lparan_Rparan2:
                return new TransformationStatement(context, getExpression(0), getExpression(2), getStatement(4));
                
            // <Statement> ::= bounding <Bounding Type> <Statement>
            case Rule_Statement_Bounding:
                return new BoundingObjectStatement(context, getToken(1), getStatement(2));
                
            // <Bool Expression> ::= true
            case Rule_Boolexpression_True:
                return new BooleanExpression(context, true);

            // <Bool Expression> ::= false
            case Rule_Boolexpression_False:
                return new BooleanExpression(context, false);

            // <Bool Expression> ::= <Object> <Comparison> <Object>
            case Rule_Boolexpression:
                return new ComparisonExpression(context, getExpression(0), getToken(1), getExpression(2));

            // <Bool Expression> ::= '(' <Bool Expression> ')'
            case Rule_Boolexpression_Lparan_Rparan:
                return getExpression(1);


            /+ ObjectRules +/
            
            // <Object> ::= <Math Expression>
            case Rule_Object:
                return getExpression(0);
            
            // <Object> ::= StringLiteral
            case Rule_Object_Stringliteral:
                return new StringExpression(context, getExpression(0).getValue.toString);

            // <Object> ::= <Obj Name> '(' <Param List> ')'
            case Rule_Object_Lparan_Rparan:
                return new ObjectExpression(context, getToken(0), getExpression(2));

            // <Object> ::= texture '(' <Object> ')'
            case Rule_Object_Texture_Lparan_Rparan:
                return new TextureFileExpression(context, getExpression(2));
                
            
            /+ Math Expressions +/
                
            // <Expression> ::= <Expression> '+' <Mult Exp>
            // <Expression> ::= <Expression> '-' <Mult Exp>
            case Rule_Expression_Plus:
            case Rule_Expression_Minus:
                return new MathBinaryExpression(context, getExpression(0), 
                        getToken(1), getExpression(2));
                
            // <Expression> ::= <Mult Exp>
            case Rule_Expression:
                return getExpression(0);
                
            // <Mult Exp> ::= <Mult Exp> '*' <Negate Exp>
            // <Mult Exp> ::= <Mult Exp> '/' <Negate Exp>
            // <Mult Exp> ::= <Mult Exp> '%' <Negate Exp>
            case Rule_Multexp_Times:
            case Rule_Multexp_Div:
            case Rule_Multexp_Percent:
                return new MathBinaryExpression(context, getExpression(0), 
                        getToken(1), getExpression(2));
                
            // <Mult Exp> ::= <Negate Exp>
            case Rule_Multexp:
                return getExpression(0);
                
            // <Negate Exp> ::= '-' <Value>
            case Rule_Negateexp_Minus:
                return new MathNegativeExpression(context, getExpression(1));
                
            // <Negate Exp> ::= <Value>
            case Rule_Negateexp:
                return getExpression(0);
                
            // <Value> ::= Id
            case Rule_Value_Id:
                return new ObjectMathExpressionID(context, getExpression(0));
                
            // <Value> ::= NumberLiteral
            case Rule_Value_Numberliteral:
                return new NumberExpression(context, getToken(0));
                
            // <Value> ::= <Color>
            // <Value> ::= <Vector>
            case Rule_Value:
            case Rule_Value2:
                return getExpression(0);
                
            // <Value> ::= '(' <Expression> ')'
            case Rule_Value_Lparan_Rparan:
                return getExpression(1);
                
            // <Color> ::= <Color Name>
            case Rule_Color:
                return new ColorExpression(context, getToken(0));
            
            // <Color> ::= rgb '(' <Expression> ',' <Expression> ',' <Expression> ')'
            case Rule_Color_Rgb_Lparan_Comma_Comma_Rparan:
                return new ColorExpression(context, getExpression(2),
                        getExpression(4), getExpression(6));
                
            // <Vector> ::= '<' <Expression> ',' <Expression> ',' <Expression> '>'
            case Rule_Vector_Lt_Comma_Comma_Gt:
                return new VectorExpression(context, getExpression(1),
                        getExpression(3), getExpression(5));
                
                
            /+ Params +/
                
            // <Param List> ::= 
            case Rule_Paramlist:
                return new ParameterList(context);

            // <Param List> ::= <Object> ',' <Param List>
            case Rule_Paramlist_Comma:
                (cast (ParameterList) getExpression(2)).appendToFront(getExpression(0));
                return getExpression(2);

            // <Param List> ::= <Object>
            case Rule_Paramlist2:
                return new ParameterList(context, getExpression(0));

            // <Id List> ::=
            case Rule_Idlist:
                return new IdentifierList(context);
                
            // <Id List> ::= Id ',' <Id List>
            case Rule_Idlist_Id_Comma:
                (cast (IdentifierList) getExpression(2)).appendToFront(getExpression(0));
                return getExpression(2);
                
            // <Id List> ::= Id
            case Rule_Idlist_Id:
                return new IdentifierList(context, getExpression(0));
            
            default:
                return new GenericExpression(context, getToken(0));
        }
    }
    
    private void accept(Object reduction) {
        mRoot = reduction;
    }
}
