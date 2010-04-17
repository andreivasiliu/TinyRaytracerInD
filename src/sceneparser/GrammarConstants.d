module sceneparser.GrammarConstants; 

// constant definitions

// Symbols
enum {
    Symbol_Eof            =  0, // (EOF)
    Symbol_Error          =  1, // (Error)
    Symbol_Whitespace     =  2, // (Whitespace)
    Symbol_Commentend     =  3, // (Comment End)
    Symbol_Commentline    =  4, // (Comment Line)
    Symbol_Commentstart   =  5, // (Comment Start)
    Symbol_Minus          =  6, // '-'
    Symbol_Exclameq       =  7, // '!='
    Symbol_Percent        =  8, // '%'
    Symbol_Lparan         =  9, // '('
    Symbol_Rparan         = 10, // ')'
    Symbol_Times          = 11, // '*'
    Symbol_Comma          = 12, // ','
    Symbol_Div            = 13, // '/'
    Symbol_Plus           = 14, // '+'
    Symbol_Lt             = 15, // '<'
    Symbol_Lteq           = 16, // '<='
    Symbol_Eq             = 17, // '='
    Symbol_Eqeq           = 18, // '=='
    Symbol_Gt             = 19, // '>'
    Symbol_Gteq           = 20, // '>='
    Symbol_Appendlight    = 21, // 'append light'
    Symbol_Black          = 22, // black
    Symbol_Blue           = 23, // blue
    Symbol_Call           = 24, // call
    Symbol_Csg            = 25, // csg
    Symbol_Cube           = 26, // cube
    Symbol_Display        = 27, // display
    Symbol_Do             = 28, // do
    Symbol_Draw           = 29, // draw
    Symbol_Else           = 30, // else
    Symbol_End            = 31, // end
    Symbol_False          = 32, // false
    Symbol_Function       = 33, // function
    Symbol_Green          = 34, // green
    Symbol_Id             = 35, // Id
    Symbol_If             = 36, // if
    Symbol_Local          = 37, // local
    Symbol_Numberliteral  = 38, // NumberLiteral
    Symbol_Orange         = 39, // orange
    Symbol_Plane          = 40, // plane
    Symbol_Purple         = 41, // purple
    Symbol_Red            = 42, // red
    Symbol_Rgb            = 43, // rgb
    Symbol_Rotate         = 44, // rotate
    Symbol_Scale          = 45, // scale
    Symbol_Setcamera      = 46, // 'set camera'
    Symbol_Sphere         = 47, // sphere
    Symbol_Stringliteral  = 48, // StringLiteral
    Symbol_Then           = 49, // then
    Symbol_Translate      = 50, // translate
    Symbol_True           = 51, // true
    Symbol_While          = 52, // while
    Symbol_White          = 53, // white
    Symbol_Yellow         = 54, // yellow
    Symbol_Boolexpression = 55, // <Bool Expression>
    Symbol_Color          = 56, // <Color>
    Symbol_Colorname      = 57, // <Color Name>
    Symbol_Command        = 58, // <Command>
    Symbol_Comparison     = 59, // <Comparison>
    Symbol_Expression     = 60, // <Expression>
    Symbol_Idlist         = 61, // <Id List>
    Symbol_Multexp        = 62, // <Mult Exp>
    Symbol_Negateexp      = 63, // <Negate Exp>
    Symbol_Objname        = 64, // <Obj Name>
    Symbol_Object         = 65, // <Object>
    Symbol_Paramlist      = 66, // <Param List>
    Symbol_Start          = 67, // <Start>
    Symbol_Statement      = 68, // <Statement>
    Symbol_Statements     = 69, // <Statements>
    Symbol_Transformation = 70, // <Transformation>
    Symbol_Value          = 71, // <Value>
    Symbol_Vector         = 72, // <Vector>
}

// Rules
enum {
    Rule_Start                                   =  0, // <Start> ::= <Statements>
    Rule_Statements                              =  1, // <Statements> ::= <Statement> <Statements>
    Rule_Statements2                             =  2, // <Statements> ::= <Statement>
    Rule_Statement_Lparan_Rparan                 =  3, // <Statement> ::= <Command> '(' <Param List> ')'
    Rule_Statement_Id_Eq                         =  4, // <Statement> ::= Id '=' <Object>
    Rule_Statement_Local_Id_Eq                   =  5, // <Statement> ::= local Id '=' <Object>
    Rule_Statement_If_Then_End                   =  6, // <Statement> ::= if <Bool Expression> then <Statements> end
    Rule_Statement_If_Then_Else_End              =  7, // <Statement> ::= if <Bool Expression> then <Statements> else <Statements> end
    Rule_Statement_While_Do_End                  =  8, // <Statement> ::= while <Bool Expression> do <Statements> end
    Rule_Statement_Call_Id_Lparan_Rparan         =  9, // <Statement> ::= call Id '(' <Param List> ')'
    Rule_Statement_Function_Id_Lparan_Rparan_End = 10, // <Statement> ::= function Id '(' <Id List> ')' <Statements> end
    Rule_Statement_Setcamera_Lparan_Rparan       = 11, // <Statement> ::= 'set camera' '(' <Param List> ')'
    Rule_Statement_Appendlight_Lparan_Rparan     = 12, // <Statement> ::= 'append light' '(' <Param List> ')'
    Rule_Statement_Do_End                        = 13, // <Statement> ::= do <Statements> end
    Rule_Statement_Lparan_Rparan2                = 14, // <Statement> ::= <Transformation> '(' <Param List> ')' <Statement>
    Rule_Paramlist                               = 15, // <Param List> ::= 
    Rule_Paramlist_Comma                         = 16, // <Param List> ::= <Object> ',' <Param List>
    Rule_Paramlist2                              = 17, // <Param List> ::= <Object>
    Rule_Idlist                                  = 18, // <Id List> ::= 
    Rule_Idlist_Id_Comma                         = 19, // <Id List> ::= Id ',' <Id List>
    Rule_Idlist_Id                               = 20, // <Id List> ::= Id
    Rule_Boolexpression_True                     = 21, // <Bool Expression> ::= true
    Rule_Boolexpression_False                    = 22, // <Bool Expression> ::= false
    Rule_Boolexpression                          = 23, // <Bool Expression> ::= <Object> <Comparison> <Object>
    Rule_Boolexpression_Lparan_Rparan            = 24, // <Bool Expression> ::= '(' <Bool Expression> ')'
    Rule_Object                                  = 25, // <Object> ::= <Expression>
    Rule_Object_Stringliteral                    = 26, // <Object> ::= StringLiteral
    Rule_Object_Lparan_Rparan                    = 27, // <Object> ::= <Obj Name> '(' <Param List> ')'
    Rule_Expression_Plus                         = 28, // <Expression> ::= <Expression> '+' <Mult Exp>
    Rule_Expression_Minus                        = 29, // <Expression> ::= <Expression> '-' <Mult Exp>
    Rule_Expression                              = 30, // <Expression> ::= <Mult Exp>
    Rule_Multexp_Times                           = 31, // <Mult Exp> ::= <Mult Exp> '*' <Negate Exp>
    Rule_Multexp_Div                             = 32, // <Mult Exp> ::= <Mult Exp> '/' <Negate Exp>
    Rule_Multexp_Percent                         = 33, // <Mult Exp> ::= <Mult Exp> '%' <Negate Exp>
    Rule_Multexp                                 = 34, // <Mult Exp> ::= <Negate Exp>
    Rule_Negateexp_Minus                         = 35, // <Negate Exp> ::= '-' <Value>
    Rule_Negateexp                               = 36, // <Negate Exp> ::= <Value>
    Rule_Value_Id                                = 37, // <Value> ::= Id
    Rule_Value_Numberliteral                     = 38, // <Value> ::= NumberLiteral
    Rule_Value                                   = 39, // <Value> ::= <Color>
    Rule_Value2                                  = 40, // <Value> ::= <Vector>
    Rule_Value_Lparan_Rparan                     = 41, // <Value> ::= '(' <Expression> ')'
    Rule_Color                                   = 42, // <Color> ::= <Color Name>
    Rule_Color_Rgb_Lparan_Comma_Comma_Rparan     = 43, // <Color> ::= rgb '(' <Expression> ',' <Expression> ',' <Expression> ')'
    Rule_Vector_Lt_Comma_Comma_Gt                = 44, // <Vector> ::= '<' <Expression> ',' <Expression> ',' <Expression> '>'
    Rule_Comparison_Lt                           = 45, // <Comparison> ::= '<'
    Rule_Comparison_Lteq                         = 46, // <Comparison> ::= '<='
    Rule_Comparison_Gt                           = 47, // <Comparison> ::= '>'
    Rule_Comparison_Gteq                         = 48, // <Comparison> ::= '>='
    Rule_Comparison_Eqeq                         = 49, // <Comparison> ::= '=='
    Rule_Comparison_Exclameq                     = 50, // <Comparison> ::= '!='
    Rule_Command_Draw                            = 51, // <Command> ::= draw
    Rule_Command_Display                         = 52, // <Command> ::= display
    Rule_Objname_Sphere                          = 53, // <Obj Name> ::= sphere
    Rule_Objname_Plane                           = 54, // <Obj Name> ::= plane
    Rule_Objname_Csg                             = 55, // <Obj Name> ::= csg
    Rule_Objname_Cube                            = 56, // <Obj Name> ::= cube
    Rule_Transformation_Translate                = 57, // <Transformation> ::= translate
    Rule_Transformation_Rotate                   = 58, // <Transformation> ::= rotate
    Rule_Transformation_Scale                    = 59, // <Transformation> ::= scale
    Rule_Colorname_Red                           = 60, // <Color Name> ::= red
    Rule_Colorname_Orange                        = 61, // <Color Name> ::= orange
    Rule_Colorname_Yellow                        = 62, // <Color Name> ::= yellow
    Rule_Colorname_Green                         = 63, // <Color Name> ::= green
    Rule_Colorname_Blue                          = 64, // <Color Name> ::= blue
    Rule_Colorname_Purple                        = 65, // <Color Name> ::= purple
    Rule_Colorname_Black                         = 66, // <Color Name> ::= black
    Rule_Colorname_White                         = 67, // <Color Name> ::= white
}
