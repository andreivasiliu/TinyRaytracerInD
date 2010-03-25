module sceneparser.SceneLoader;

import sceneparser.expressions.BooleanExpression;
import sceneparser.expressions.ComparisonExpression;
import sceneparser.expressions.GenericExpression;
import sceneparser.expressions.IdentifierExpression;
import sceneparser.expressions.MathBinaryExpression;
import sceneparser.expressions.MathExpressionId;
import sceneparser.expressions.MathNegativeExpression;
import sceneparser.expressions.NumberExpression;
import sceneparser.expressions.ObjectExpression;
import sceneparser.expressions.ObjectMathExpression;
import sceneparser.expressions.StringExpression;
import sceneparser.general.Context;
import sceneparser.general.Expression;
import sceneparser.general.ParameterList;
import sceneparser.general.Statement;
import sceneparser.general.StatementList;
import sceneparser.statements.AppendLightStatement;
import sceneparser.statements.AssignmentStatement;
import sceneparser.statements.DimensionStatement;
import sceneparser.statements.DisplayStatement;
import sceneparser.statements.DrawStatement;
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
import Utf = tango.text.convert.Utf;

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
    
    //This will load the grammar file on instanciation
    private void loadGrammar() {
        //Load grammar from an external file
        //mGrammar = new Grammar("Tiny-CAD Grammar.cgt");
        
        auto mem = new Array(BINARY_VERSION12_0_CGT.length);
        mem.write(BINARY_VERSION12_0_CGT);
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
                    return new StringExpression(context, tokenText);
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
            // <Start> ::= ['2D'|'3D'] <Statements>     
            case Rule_Start_2d:
            case Rule_Start_3d:
                return new DimensionStatement(context, getToken(0), getStatement(1));
                
            // <Statements> ::= <Statement> <Statements>     
            case Rule_Statements:
                return new StatementList(context, getStatement(0), getStatement(1));
                
            // <Statements> ::= <Statement>     
            case Rule_Statements2:
                return new StatementList(context, getStatement(0), null);
                
            // <Statement> ::= <Command> '(' <params> ')'     
            case Rule_Statement_Lparan_Rparan:
                if (getToken(0) == "display")
                    return new DisplayStatement(context, getExpression(2));
                else if (getToken(0) == "draw")
                    return new DrawStatement(context, getExpression(2));
                return null;
                
            // <Statement> ::= Id '=' <Object>     
            case Rule_Statement_Id_Eq: // to check for now
                return new AssignmentStatement(context, getExpression(0), getExpression(2));

            // <Statement> ::= if <Bool_Expression> then <Statements> endif     
            case Rule_Statement_If_Then_Endif:
                return new IfThenStatement(context, getExpression(1), getStatement(3));

            // <Statement> ::= if <Bool_Expression> then <Statements> else <Statements> endif     
            case Rule_Statement_If_Then_Else_Endif:
                return new IfThenElseStatement(context, getExpression(1), getStatement(3), getStatement(5));

            // <Statement> ::= while <Bool_Expression> do <Statements> endwhile     
            case Rule_Statement_While_Do_Endwhile:
                return new WhileStatement(context, getExpression(1), getStatement(3));

            // <Statement> ::= 'set camera' '(' <params> ')'     
            case Rule_Statement_Setcamera_Lparan_Rparan:
                return new SetCameraStatement(context, getExpression(2));

            // <Statement> ::= 'append light' '(' <params> ')'     
            case Rule_Statement_Appendlight_Lparan_Rparan:
                return new AppendLightStatement(context, getExpression(2));

            // <Statement> ::= do <Statements> end
            case Rule_Statement_Do_End:
                return getStatement(1);
            
            // <Statement> ::= <Transformation> '(' <params> ')' <Statement>
            case Rule_Statement_Lparan_Rparan2:
                return new TransformationStatement(context, getExpression(0), getExpression(2), getStatement(4));

            // <Bool_Expression> ::= true     
            case Rule_Bool_expression_True:
                return new BooleanExpression(context, true);

            // <Bool_Expression> ::= false     
            case Rule_Bool_expression_False:
                return new BooleanExpression(context, false);

            // <Bool_Expression> ::= <Object> <Comparison> <Object>     
            case Rule_Bool_expression:
                return new ComparisonExpression(context, getExpression(0), getToken(1), getExpression(2));

            // <Bool_Expression> ::= '(' <Bool_Expression> ')'     
            case Rule_Bool_expression_Lparan_Rparan:
                // FIXME
                return new ComparisonExpression(context, getExpression(1), getToken(2), getExpression(3));


            /+ ObjectRules +/
            
            // <Object> ::= <Math_Expression>     
            case Rule_Object:
                return new ObjectMathExpression(context, getExpression(0));
            
            // <Object> ::= StringLiteral     
            case Rule_Object_Stringliteral:
                return new StringExpression(context, getExpression(0).getValue.toString);

            // <Object> ::= <Obj_Name> '(' <params> ')'     
            case Rule_Object_Lparan_Rparan:
                return new ObjectExpression(context, getToken(0), getExpression(2));

            
            /+ MathExpressions +/
                
            // <Math_Expression> ::= Id     
            case Rule_Math_expression_Id:
                return new ObjectMathExpressionID(context, getExpression(0));

            // <Math_Expression> ::= NumberLiteral     
            case Rule_Math_expression_Numberliteral:
                return new NumberExpression(context, getToken(0));

            // <Math_Expression> ::= <Math_Expression> <Operators> <Math_Expression>     
            case Rule_Math_expression:
                return new MathBinaryExpression(context, getExpression(0), getToken(1), getExpression(2));

            // <Math_Expression> ::= '(' <Math_Expression> ')'     
            case Rule_Math_expression_Lparan_Rparan:
                return new ObjectMathExpression(context, getExpression(1));

            // <Math_Expression> ::= '-' <Math_Expression>     
            case Rule_Math_expression_Minus:
                return new MathNegativeExpression(context, getExpression(1));
            

            /+ Params +/
                
            // <params> ::=      
            case Rule_Params:
                return new ParameterList(context);

            // <params> ::= <Object> ',' <params>     
            case Rule_Params_Comma:
                (cast (ParameterList) getExpression(2)).appendToFront(getExpression(0));
                return getExpression(2);

            // <params> ::= <Object>     
            case Rule_Params2:
                return new ParameterList(context, getExpression(0));

            default:
                return new GenericExpression(context, getToken(0));
                //assert(false, "Rule "~redRule.ntSymbol.toString~" not implemented. The file needs to be updated");
        }
    }
    
    private void accept(Object reduction) {
        mRoot = reduction;
    }
}
