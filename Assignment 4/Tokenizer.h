#ifndef TOKENIZER_H
#define TOKENIZER_H

#include <stdlib.h>
#include <string.h>
#include "Givens.h"


//Function prototypes
_Bool tokenizer(struct lexics *aLex, int *numLex, FILE *inf);
char checkNextChar(FILE *inf);
struct lexics * getNextLexic(FILE *inf);
void checkEquals(FILE *inf, char currentChar, struct lexics *currentLexics);
void checkSingleChars(char currentChar, struct lexics *currentLexics);
void checkNumeric(FILE *inf, char currentChar, struct lexics *currentLexics);
void checkAlphabetic(FILE *inf, char currentChar, struct lexics *currentLexics);
int isWhiteSpace(char check);
int isAlphabetic(char check);
int isDigit(char check);

#endif
