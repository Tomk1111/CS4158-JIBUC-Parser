%{

	#include <stdlib.h>
	#include <ctype.h>
	#include <string.h>
	#include "y.tab.h"

%}

%option noyywrap
%option caseless
%option yylineno


whitespace  [\n\t ]+
integer       [0-9]+
id          ([a-zA-Z]{1}[a-zxxA-Z0-9]{0,4}[a-zA-Z]{1})|([a-wyzA-WYZ]{1})
capacity 	([Xx]+)|([Xx]+\-[Xx]+)


%%
{whitespace}+                                     /* whitespace */ ;

(?i:START)                                      {return START; }    
(?i:MAIN)                                       { return MAIN; }
(?i:END)                                        { return END; }
(?i:EQUALS-TO)                                  { return EQUALSTO; }
(?i:EQUALS-TO-VALUE)                            { return EQUALSTOVALUE; }
(?i:ADD)                                        { return ADD; }
(?i:TO)                                         { return TO;}
(?i:INPUT)                                      { return INPUT; }
(?i:PRINT)                                      { return PRINT; }


{capacity}                                      {yylval.id = yytext; return CAPACITY; }
{id}                                            {yylval.id = yytext; return IDENTIFIER; }

{integer}                                      { yylval.id = yytext; return INTEGER;}
{integer}+\.{integer}+                          {yylval.id = yytext; return DOUBLE; }

\"(\\.|[^\"])*\"                              	{ yylval.id = yytext; return STRINGLITERAL;}
;                                               { return SEMICOLON; }
","                                             {return COMMA;}
\.                                              {return TERMINATOR;}
%%
