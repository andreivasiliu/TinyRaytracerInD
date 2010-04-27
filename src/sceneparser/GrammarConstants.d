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
    Symbol_Bounding       = 24, // bounding
    Symbol_Box            = 25, // box
    Symbol_Call           = 26, // call
    Symbol_Csg            = 27, // csg
    Symbol_Cube           = 28, // cube
    Symbol_Display        = 29, // display
    Symbol_Do             = 30, // do
    Symbol_Draw           = 31, // draw
    Symbol_Else           = 32, // else
    Symbol_End            = 33, // end
    Symbol_False          = 34, // false
    Symbol_Function       = 35, // function
    Symbol_Green          = 36, // green
    Symbol_Id             = 37, // Id
    Symbol_If             = 38, // if
    Symbol_Local          = 39, // local
    Symbol_Numberliteral  = 40, // NumberLiteral
    Symbol_Orange         = 41, // orange
    Symbol_Plane          = 42, // plane
    Symbol_Purple         = 43, // purple
    Symbol_Red            = 44, // red
    Symbol_Rgb            = 45, // rgb
    Symbol_Rotate         = 46, // rotate
    Symbol_Scale          = 47, // scale
    Symbol_Setcamera      = 48, // 'set camera'
    Symbol_Sphere         = 49, // sphere
    Symbol_Stringliteral  = 50, // StringLiteral
    Symbol_Texture        = 51, // texture
    Symbol_Then           = 52, // then
    Symbol_Translate      = 53, // translate
    Symbol_True           = 54, // true
    Symbol_While          = 55, // while
    Symbol_White          = 56, // white
    Symbol_Yellow         = 57, // yellow
    Symbol_Boolexpression = 58, // <Bool Expression>
    Symbol_Boundingtype   = 59, // <Bounding Type>
    Symbol_Color          = 60, // <Color>
    Symbol_Colorname      = 61, // <Color Name>
    Symbol_Command        = 62, // <Command>
    Symbol_Comparison     = 63, // <Comparison>
    Symbol_Expression     = 64, // <Expression>
    Symbol_Idlist         = 65, // <Id List>
    Symbol_Multexp        = 66, // <Mult Exp>
    Symbol_Negateexp      = 67, // <Negate Exp>
    Symbol_Objname        = 68, // <Obj Name>
    Symbol_Object         = 69, // <Object>
    Symbol_Paramlist      = 70, // <Param List>
    Symbol_Start          = 71, // <Start>
    Symbol_Statement      = 72, // <Statement>
    Symbol_Statements     = 73, // <Statements>
    Symbol_Transformation = 74, // <Transformation>
    Symbol_Value          = 75, // <Value>
    Symbol_Vector         = 76, // <Vector>
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
    Rule_Statement_Bounding                      = 15, // <Statement> ::= bounding <Bounding Type> <Statement>
    Rule_Paramlist                               = 16, // <Param List> ::= 
    Rule_Paramlist_Comma                         = 17, // <Param List> ::= <Object> ',' <Param List>
    Rule_Paramlist2                              = 18, // <Param List> ::= <Object>
    Rule_Idlist                                  = 19, // <Id List> ::= 
    Rule_Idlist_Id_Comma                         = 20, // <Id List> ::= Id ',' <Id List>
    Rule_Idlist_Id                               = 21, // <Id List> ::= Id
    Rule_Boolexpression_True                     = 22, // <Bool Expression> ::= true
    Rule_Boolexpression_False                    = 23, // <Bool Expression> ::= false
    Rule_Boolexpression                          = 24, // <Bool Expression> ::= <Object> <Comparison> <Object>
    Rule_Boolexpression_Lparan_Rparan            = 25, // <Bool Expression> ::= '(' <Bool Expression> ')'
    Rule_Object                                  = 26, // <Object> ::= <Expression>
    Rule_Object_Stringliteral                    = 27, // <Object> ::= StringLiteral
    Rule_Object_Lparan_Rparan                    = 28, // <Object> ::= <Obj Name> '(' <Param List> ')'
    Rule_Object_Texture_Lparan_Rparan            = 29, // <Object> ::= texture '(' <Object> ')'
    Rule_Expression_Plus                         = 30, // <Expression> ::= <Expression> '+' <Mult Exp>
    Rule_Expression_Minus                        = 31, // <Expression> ::= <Expression> '-' <Mult Exp>
    Rule_Expression                              = 32, // <Expression> ::= <Mult Exp>
    Rule_Multexp_Times                           = 33, // <Mult Exp> ::= <Mult Exp> '*' <Negate Exp>
    Rule_Multexp_Div                             = 34, // <Mult Exp> ::= <Mult Exp> '/' <Negate Exp>
    Rule_Multexp_Percent                         = 35, // <Mult Exp> ::= <Mult Exp> '%' <Negate Exp>
    Rule_Multexp                                 = 36, // <Mult Exp> ::= <Negate Exp>
    Rule_Negateexp_Minus                         = 37, // <Negate Exp> ::= '-' <Value>
    Rule_Negateexp                               = 38, // <Negate Exp> ::= <Value>
    Rule_Value_Id                                = 39, // <Value> ::= Id
    Rule_Value_Numberliteral                     = 40, // <Value> ::= NumberLiteral
    Rule_Value                                   = 41, // <Value> ::= <Color>
    Rule_Value2                                  = 42, // <Value> ::= <Vector>
    Rule_Value_Lparan_Rparan                     = 43, // <Value> ::= '(' <Expression> ')'
    Rule_Color                                   = 44, // <Color> ::= <Color Name>
    Rule_Color_Rgb_Lparan_Comma_Comma_Rparan     = 45, // <Color> ::= rgb '(' <Expression> ',' <Expression> ',' <Expression> ')'
    Rule_Vector_Lt_Comma_Comma_Gt                = 46, // <Vector> ::= '<' <Expression> ',' <Expression> ',' <Expression> '>'
    Rule_Boundingtype_Sphere                     = 47, // <Bounding Type> ::= sphere
    Rule_Boundingtype_Box                        = 48, // <Bounding Type> ::= box
    Rule_Comparison_Lt                           = 49, // <Comparison> ::= '<'
    Rule_Comparison_Lteq                         = 50, // <Comparison> ::= '<='
    Rule_Comparison_Gt                           = 51, // <Comparison> ::= '>'
    Rule_Comparison_Gteq                         = 52, // <Comparison> ::= '>='
    Rule_Comparison_Eqeq                         = 53, // <Comparison> ::= '=='
    Rule_Comparison_Exclameq                     = 54, // <Comparison> ::= '!='
    Rule_Command_Draw                            = 55, // <Command> ::= draw
    Rule_Command_Display                         = 56, // <Command> ::= display
    Rule_Objname_Sphere                          = 57, // <Obj Name> ::= sphere
    Rule_Objname_Plane                           = 58, // <Obj Name> ::= plane
    Rule_Objname_Csg                             = 59, // <Obj Name> ::= csg
    Rule_Objname_Cube                            = 60, // <Obj Name> ::= cube
    Rule_Transformation_Translate                = 61, // <Transformation> ::= translate
    Rule_Transformation_Rotate                   = 62, // <Transformation> ::= rotate
    Rule_Transformation_Scale                    = 63, // <Transformation> ::= scale
    Rule_Colorname_Red                           = 64, // <Color Name> ::= red
    Rule_Colorname_Orange                        = 65, // <Color Name> ::= orange
    Rule_Colorname_Yellow                        = 66, // <Color Name> ::= yellow
    Rule_Colorname_Green                         = 67, // <Color Name> ::= green
    Rule_Colorname_Blue                          = 68, // <Color Name> ::= blue
    Rule_Colorname_Purple                        = 69, // <Color Name> ::= purple
    Rule_Colorname_Black                         = 70, // <Color Name> ::= black
    Rule_Colorname_White                         = 71, // <Color Name> ::= white
}
