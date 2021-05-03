%{

    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include<math.h>
    #include <stdbool.h>
    #include <ctype.h>

    extern int yylex();
	extern int yyparse();
	extern int yylineno;

    void yyerror(const char *output);
    extern FILE *yyin;

    void addVar(char *varName, char *sizeVar);
    void trimVar(char *varName);
    void checkVar(char *varName);
    void getFirstVar(char *varName);
    void validId(char *varName);
    void addIntToId(char *varName, char *int_var);
    void addDoubleToId(char *double_var, char *varName);
    void addIdToId(char *var_name1, char *var_name2);
    void toUppercase(char *varName);
    void checkIdAssignment(char *var1, char *var2);
    void checkIntAssignment(char *var1, char *int_var);
    void checkDoubleAssignment(char *var1, char *double_var);
    char* getVarSize(char *varName);
    int compareString(char *first, char *second);


    #define NUM_VARS 100
    char var_identifiers[NUM_VARS][32];
    char var_sizes[NUM_VARS][32];
    int identifier_counter = 0;

%}
%union { char *id; int intVal;}
%start start
%token<id> IDENTIFIER
%token<id> CAPACITY
%token<id> STRINGLITERAL
%token<id> DOUBLE
%token<id> INTEGER
%token START MAIN END ADD TO PRINT INPUT EQUALSTO EQUALSTOVALUE SEMICOLON COMMA TERMINATOR INVALID


%%
start:              START SEMICOLON declarations {}
                    | error {}
                    ;

declarations:		declaration declarations {}
					| main {}
					;

declaration:		CAPACITY IDENTIFIER SEMICOLON { addVar($2, $1);}
					| error {}
					;


main:               MAIN SEMICOLON operations {}
                    | error {}
                    ;

operations:         operation operations {}
                    | end {}
                    ;

operation:          print {} 
                    | input {}
                    | add {}
                    | assignment {}
                    | error {}
                    ; 

print:              PRINT print_msg {}
                    ;

print_msg:          STRINGLITERAL SEMICOLON {}
                    | IDENTIFIER SEMICOLON {checkVar($1);}
                    | STRINGLITERAL COMMA print_msg {} 
                    | IDENTIFIER COMMA print_msg {checkVar($1);}
                    ;
                
input:              INPUT input_arg {}
                    ;

input_arg:          IDENTIFIER SEMICOLON {checkVar($1);}
                    | IDENTIFIER COMMA input_arg {checkVar($1);}
                    ;

add:                ADD DOUBLE TO IDENTIFIER SEMICOLON { checkDoubleAssignment($4, $2);}
                    | ADD INTEGER TO IDENTIFIER SEMICOLON { checkIntAssignment($4, $2);}
                    | ADD IDENTIFIER TO IDENTIFIER SEMICOLON { checkIdAssignment($4, $2);}
                    ;

assignment:         IDENTIFIER EQUALSTO IDENTIFIER SEMICOLON { checkIdAssignment($1, $3);}
                    | IDENTIFIER EQUALSTOVALUE DOUBLE SEMICOLON { checkDoubleAssignment($1, $3);}
                    | IDENTIFIER EQUALSTOVALUE INTEGER SEMICOLON { checkIntAssignment($1, $3);}
                    ;

end:                END SEMICOLON {exit(EXIT_SUCCESS);}
                    ;

%%

int main() {
    yyparse();
    return 0;
}


void yyerror(const char *output){
    fprintf(stderr, "[ERROR line %d]: %s\n", yylineno, output);
}

void trimVar(char *varName) {
    // remove semicolon, comma and whitespace from identifier
    int var_len = strlen(varName);
    for (int i = 0;i < var_len;i++) {
        if (varName[i] == ';' || varName[i] == ' ' || varName[i] == ',') {
           varName[i] = '\0'; 
        }
    }
}

bool varExists(char *varName) { 
    bool found = false;
    for (int i = 0;i < identifier_counter; i++) {
        if (strcmp(var_identifiers[i], varName) == 0){
            return true;
        }
    }
    return false;
}

int compareString(char *first, char *second)
{
   while(*first==*second)
   {
      if ( *first == '\0' || *second == '\0' )
         break;
 
      first++;
      second++;
   }
   if( *first == '\0' && *second == '\0' )
      return 0;
   else
      return -1;
}


void checkIdAssignment(char *var1, char *var2) {

    getFirstVar(var1);
    getFirstVar(var2);
    checkVar(var1);
    checkVar(var2);

    char *ch1 = getVarSize(var1);
    char *ch2 = getVarSize(var2);
    
    if (ch1 != NULL && ch2 != NULL) {
        if (compareString(ch1, ch2) != 0) {
            printf("[WARN line %d]: Identifiers %s (%s) & %s (%s) have different sizes \n", yylineno, var1, ch1, var2, ch2);
        }
    }
}

void checkIntAssignment(char *var1, char *int_var) {
    getFirstVar(var1);
    getFirstVar(int_var);
    checkVar(var1);
    char *ch = getVarSize(var1);
    if (ch != NULL) {
        trimVar(int_var);

        if (strlen(ch) != strlen(int_var)) {
            printf("[WARN line %d]: Identifier %s with size (%s) does not match integer value %s\n", yylineno, var1, ch, int_var);
        }
    }
}

void checkDoubleAssignment(char *var1, char *double_var) {
    getFirstVar(var1);
    getFirstVar(double_var);
    checkVar(var1);
    char *ch = getVarSize(var1);
    if (ch != NULL) {    
        trimVar(double_var);

        if (strlen(ch) != strlen(double_var)){
            printf("[WARN line %d]: Identifier %s with size (%s) does not match double value %s\n", yylineno, var1, ch, double_var);
        } else {

            bool valid = false;
            for (int i = 0;i < strlen(ch);i++){            
                // check if the size & double delimiter in same position
                if (ch[i] == '-' && double_var[i] == '.') {
                    valid = true;
                }
            }

            if (!valid) {
                printf("[WARN line %d]: Identifier %s with size (%s) does not match double value %s\n", yylineno, var1, ch, double_var);
            } 
        }
    }
}



void checkVar(char *varName) {
    getFirstVar(varName);
    trimVar(varName);
    toUppercase(varName);

    bool found = varExists(varName);
    if (!found) {
        printf("[WARN line %d]: Identifier %s is not declared.\n", yylineno, varName);
    }
}



void toUppercase(char *varName) {
    int var_len = strlen(varName);
    for (int i = 0;i < var_len;i++) {
        varName[i] = toupper(varName[i]);
    }
}



void addVar(char *varName, char *sizeVar) {
    
    trimVar(varName);

    validId(varName);

    toUppercase(varName);
    bool found = varExists(varName);


    if (found) {
        printf("Error on line %d variable %s - already initialised \n", yylineno, varName);
    } else {
        
        int name_len = strlen(varName);
        getFirstVar(sizeVar);
        toUppercase(sizeVar);
        //add identifier and its size to lists
        strcpy(var_identifiers[identifier_counter], varName);
        strcpy(var_sizes[identifier_counter], sizeVar);
        identifier_counter++;

        getVarSize(varName);
    }
}


void validId(char *varName) {
    toUppercase(varName);
    // if (strlen(varName) >= 7) {
    //     printf("[WARN line %d]: variable: %s - cannot be greater than 7 \n", yylineno, varName);
    // } 
    //CONTIGUOUS Xs IN IDENTIFIER
    // printf("%s\n", varName);
    if (strstr(varName, "XX") != NULL) {
        printf("[WARN line %d]: variable: %s - cannot contain contiguous Xs \n", yylineno, varName);
    }
}


void getFirstVar(char *var) {
    for (int i = 0; i < strlen(var); i++) {
        if (var[i] == ';' || var[i] == ' ' || var[i] == ',') {
            var[i] = '\0';
            break;
        }
    }
}

void addIntToId(char *varName, char *int_var) {

}

void addDoubleToId(char *double_var, char *varName) {

    getFirstVar(double_var);

}

void addIdToId(char *var_name1, char *var_name2) {
    //todo potentially move the size checker to the direct methods
    //todo NEED TO ADD UPPERCASEE METHOD
    trimVar(var_name1);
    trimVar(var_name2);
    // validId(var_name1);
    // validId(var_name2);
    toUppercase(var_name1);
    toUppercase(var_name2);

    checkVar(var_name1);
    checkVar(var_name2);


}

char* getVarSize(char *varName) {
    for (int i = 0;i < identifier_counter; i++) {
        if (strcmp(var_identifiers[i], varName) == 0){
            // printf(var_sizes[i], " UHDS AUWHDWUHD");
            return var_sizes[i];
        }
    }
    return '\0';
}


int yywrap() {
    return 1;
}




