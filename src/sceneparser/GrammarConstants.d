module sceneparser.GrammarConstants;

// constant definitions
public const char[] BINARY_VERSION12_0_CGT = import("GrammarFile.cgt");

//Symbols
enum {
    Symbol_Eof             =  0, // (EOF)
    Symbol_Error           =  1, // (Error)
    Symbol_Whitespace      =  2, // (Whitespace)
    Symbol_Minus           =  3, // '-'
    Symbol_Exclameq        =  4, // '!='
    Symbol_Percent         =  5, // '%'
    Symbol_Lparan          =  6, // '('
    Symbol_Rparan          =  7, // ')'
    Symbol_Times           =  8, // '*'
    Symbol_Comma           =  9, // ','
    Symbol_Dot             = 10, // '.'
    Symbol_Div             = 11, // '/'
    Symbol_Lbrace          = 12, // '{'
    Symbol_Rbrace          = 13, // '}'
    Symbol_Plus            = 14, // '+'
    Symbol_Lt              = 15, // '<'
    Symbol_Lteq            = 16, // '<='
    Symbol_Eq              = 17, // '='
    Symbol_Eqeq            = 18, // '=='
    Symbol_Gt              = 19, // '>'
    Symbol_Gteq            = 20, // '>='
    Symbol_2d              = 21, // '2D'
    Symbol_3d              = 22, // '3D'
    Symbol_Add             = 23, // add
    Symbol_Appendlight     = 24, // 'append light'
    Symbol_Black           = 25, // black
    Symbol_Blue            = 26, // blue
    Symbol_Call            = 27, // call
    Symbol_Clear           = 28, // clear
    Symbol_Collection      = 29, // Collection
    Symbol_Color           = 30, // color
    Symbol_Csg             = 31, // csg
    Symbol_Cube            = 32, // cube
    Symbol_Display         = 33, // display
    Symbol_Do              = 34, // do
    Symbol_Draw            = 35, // draw
    Symbol_Else            = 36, // else
    Symbol_End             = 37, // end
    Symbol_Endif           = 38, // endif
    Symbol_Endwhile        = 39, // endwhile
    Symbol_Exit            = 40, // exit
    Symbol_False           = 41, // false
    Symbol_Function        = 42, // function
    Symbol_Green           = 43, // green
    Symbol_Id              = 44, // Id
    Symbol_If              = 45, // if
    Symbol_Numberliteral   = 46, // NumberLiteral
    Symbol_Orange          = 47, // orange
    Symbol_Pen             = 48, // pen
    Symbol_Plane           = 49, // plane
    Symbol_Procedure       = 50, // procedure
    Symbol_Purple          = 51, // purple
    Symbol_Red             = 52, // red
    Symbol_Remove          = 53, // remove
    Symbol_Rotate          = 54, // rotate
    Symbol_Scale           = 55, // scale
    Symbol_Setcamera       = 56, // 'set camera'
    Symbol_Sphere          = 57, // sphere
    Symbol_Stringliteral   = 58, // StringLiteral
    Symbol_Then            = 59, // then
    Symbol_Translate       = 60, // translate
    Symbol_True            = 61, // true
    Symbol_While           = 62, // while
    Symbol_White           = 63, // white
    Symbol_Yellow          = 64, // yellow
    Symbol_Bool_expression = 65, // <Bool_Expression>
    Symbol_Colors          = 66, // <Colors>
    Symbol_Command         = 67, // <Command>
    Symbol_Comparison      = 68, // <Comparison>
    Symbol_Math_expression = 69, // <Math_Expression>
    Symbol_Obj_name        = 70, // <Obj_Name>
    Symbol_Object          = 71, // <Object>
    Symbol_Operators       = 72, // <Operators>
    Symbol_Params          = 73, // <params>
    Symbol_Start           = 74, // <Start>
    Symbol_Statement       = 75, // <Statement>
    Symbol_Statements      = 76, // <Statements>
    Symbol_Transformation  = 77, // <Transformation>
}

// Rules
enum {
    Rule_Start_2d                                           =  0, // <Start> ::= '2D' <Statements>
    Rule_Start_3d                                           =  1, // <Start> ::= '3D' <Statements>
    Rule_Statements                                         =  2, // <Statements> ::= <Statement> <Statements>
    Rule_Statements2                                        =  3, // <Statements> ::= <Statement>
    Rule_Statement_Lparan_Rparan                            =  4, // <Statement> ::= <Command> '(' <params> ')'
    Rule_Statement_Id_Eq                                    =  5, // <Statement> ::= Id '=' <Object>
    Rule_Statement_If_Then_Endif                            =  6, // <Statement> ::= if <Bool_Expression> then <Statements> endif
    Rule_Statement_If_Then_Else_Endif                       =  7, // <Statement> ::= if <Bool_Expression> then <Statements> else <Statements> endif
    Rule_Statement_While_Do_Endwhile                        =  8, // <Statement> ::= while <Bool_Expression> do <Statements> endwhile
    Rule_Statement_Color                                    =  9, // <Statement> ::= color <Colors>
    Rule_Statement_Pen_Numberliteral                        = 10, // <Statement> ::= pen NumberLiteral
    Rule_Statement_Pen_Id                                   = 11, // <Statement> ::= pen Id
    Rule_Statement_Procedure_Id_Lparan_Rparan_Lbrace_Rbrace = 12, // <Statement> ::= procedure Id '(' <params> ')' '{' <Statements> '}'
    Rule_Statement_Call_Id_Lparan_Rparan                    = 13, // <Statement> ::= call Id '(' <params> ')'
    Rule_Statement_Collection_Id                            = 14, // <Statement> ::= Collection Id
    Rule_Statement_Id_Dot_Add_Lparan_Rparan                 = 15, // <Statement> ::= Id '.' add '(' <Object> ')'
    Rule_Statement_Id_Dot_Remove_Lparan_Rparan              = 16, // <Statement> ::= Id '.' remove '(' <Object> ')'
    Rule_Statement_Clear_Id                                 = 17, // <Statement> ::= clear Id
    Rule_Statement_Function_Id_Lparan_Rparan_Exit_End       = 18, // <Statement> ::= function Id '(' <params> ')' <Statements> exit <Object> end
    Rule_Statement_Setcamera_Lparan_Rparan                  = 19, // <Statement> ::= 'set camera' '(' <params> ')'
    Rule_Statement_Appendlight_Lparan_Rparan                = 20, // <Statement> ::= 'append light' '(' <params> ')'
    Rule_Statement_Do_End                                   = 21, // <Statement> ::= do <Statements> end
    Rule_Statement_Lparan_Rparan2                           = 22, // <Statement> ::= <Transformation> '(' <params> ')' <Statement>
    Rule_Bool_expression_True                               = 23, // <Bool_Expression> ::= true
    Rule_Bool_expression_False                              = 24, // <Bool_Expression> ::= false
    Rule_Bool_expression                                    = 25, // <Bool_Expression> ::= <Object> <Comparison> <Object>
    Rule_Bool_expression_Lparan_Rparan                      = 26, // <Bool_Expression> ::= '(' <Bool_Expression> ')'
    Rule_Comparison_Lt                                      = 27, // <Comparison> ::= '<'
    Rule_Comparison_Lteq                                    = 28, // <Comparison> ::= '<='
    Rule_Comparison_Gt                                      = 29, // <Comparison> ::= '>'
    Rule_Comparison_Gteq                                    = 30, // <Comparison> ::= '>='
    Rule_Comparison_Eqeq                                    = 31, // <Comparison> ::= '=='
    Rule_Comparison_Exclameq                                = 32, // <Comparison> ::= '!='
    Rule_Object                                             = 33, // <Object> ::= <Math_Expression>
    Rule_Object_Stringliteral                               = 34, // <Object> ::= StringLiteral
    Rule_Object_Lparan_Rparan                               = 35, // <Object> ::= <Obj_Name> '(' <params> ')'
    Rule_Math_expression_Id                                 = 36, // <Math_Expression> ::= Id
    Rule_Math_expression_Numberliteral                      = 37, // <Math_Expression> ::= NumberLiteral
    Rule_Math_expression                                    = 38, // <Math_Expression> ::= <Math_Expression> <Operators> <Math_Expression>
    Rule_Math_expression_Lparan_Rparan                      = 39, // <Math_Expression> ::= '(' <Math_Expression> ')'
    Rule_Math_expression_Minus                              = 40, // <Math_Expression> ::= '-' <Math_Expression>
    Rule_Params                                             = 41, // <params> ::= 
    Rule_Params_Comma                                       = 42, // <params> ::= <Object> ',' <params>
    Rule_Params2                                            = 43, // <params> ::= <Object>
    Rule_Operators_Plus                                     = 44, // <Operators> ::= '+'
    Rule_Operators_Minus                                    = 45, // <Operators> ::= '-'
    Rule_Operators_Div                                      = 46, // <Operators> ::= '/'
    Rule_Operators_Times                                    = 47, // <Operators> ::= '*'
    Rule_Operators_Percent                                  = 48, // <Operators> ::= '%'
    Rule_Command_Draw                                       = 49, // <Command> ::= draw
    Rule_Command_Display                                    = 50, // <Command> ::= display
    Rule_Obj_name_Sphere                                    = 51, // <Obj_Name> ::= sphere
    Rule_Obj_name_Plane                                     = 52, // <Obj_Name> ::= plane
    Rule_Obj_name_Csg                                       = 53, // <Obj_Name> ::= csg
    Rule_Obj_name_Cube                                      = 54, // <Obj_Name> ::= cube
    Rule_Transformation_Translate                           = 55, // <Transformation> ::= translate
    Rule_Transformation_Rotate                              = 56, // <Transformation> ::= rotate
    Rule_Transformation_Scale                               = 57, // <Transformation> ::= scale
    Rule_Colors_Red                                         = 58, // <Colors> ::= red
    Rule_Colors_Orange                                      = 59, // <Colors> ::= orange
    Rule_Colors_Yellow                                      = 60, // <Colors> ::= yellow
    Rule_Colors_Green                                       = 61, // <Colors> ::= green
    Rule_Colors_Blue                                        = 62, // <Colors> ::= blue
    Rule_Colors_Purple                                      = 63, // <Colors> ::= purple
    Rule_Colors_Black                                       = 64, // <Colors> ::= black
    Rule_Colors_White                                       = 65, // <Colors> ::= white
}
