#include "Tokenizer.h"

//the tokenizer function populates an array of lexics with the lexics found in a file pointer to by inf
//numLex counts how many lexics are found
//if there is an error with any of the lexics - if they don't fit the correct syntax of the grammar or if they
//have some similar error - then the function returns false
//if the lexics are valid, then the function returns true
_Bool tokenizer(struct lexics *aLex, int *numLex, FILE *inf)
{
	*numLex = 0;
	//getLexics is used to check if the Lexics are valid before we add them into the array
	struct lexics * getLexics;

	//a file is always finite in length, so this loop will always terminate
	while (1)
	{
		getLexics = getNextLexic(inf);

		//a lexics is returned as null if it has an error
		//a lexics is returned with an empty string as its lexeme if the file is finished
		//an empty string cannot be a valid lexeme, so this is a save way of signalling end of reading
		if (getLexics == NULL)
		{
			printf("Error occured\n");
			return FALSE;
		}
		if (!strcmp(getLexics->lexeme,""))
		{
			return TRUE;
		}
		//since the lexics is valid, we add it to the array and update the number of lexics found
		(aLex[*numLex])=*getLexics;
		(*numLex)++;
	}
	return TRUE;
}

//for some lexemes, we need to look at the next character to decide what lexeme we have
char checkNextChar(FILE *inf)
{
	fpos_t saveCharPtr;
	fgetpos(inf, &saveCharPtr);
	char nextChar = fgetc(inf);
	fsetpos(inf, &saveCharPtr);
	return nextChar;
}

//this function obtains the next lexics that can be found in the file inf
struct lexics * getNextLexic(FILE *inf)
{
	char nextChar = fgetc(inf);
	struct lexics *currentLexics = malloc(sizeof(struct lexics));
	strcpy(currentLexics->lexeme,"");
	
	//if we are at the end of the file (or if we iterated past the end of the file), we are finished
	if (nextChar == feof(inf) || nextChar == -1)
	{
		return currentLexics;
	}

	//iterate through any whitespace characters until a nonwhitespace character is found
	while (isWhiteSpace(nextChar))
	{
		if (nextChar == -1)
		{
			return currentLexics;
		}
		nextChar = fgetc(inf);
	}

	//make sure we didn't somehow iterate past the end of the file
	if (nextChar == -1)
	{
		return currentLexics;
	}

	//first check to see if the current character is a single-character lexeme
	checkSingleChars(nextChar, currentLexics);
	if (strcmp(currentLexics->lexeme,""))
	{
		return currentLexics;
	}

	//next check if the current character is "=","==", or "!="
	checkEquals(inf, nextChar,currentLexics);
	if (strcmp(currentLexics->lexeme,""))
	{
		return currentLexics;
	}
	
	//next check if the current lexics is a number
	checkNumeric(inf, nextChar,currentLexics);
	if (strcmp(currentLexics->lexeme,""))
	{
		return currentLexics;
	}
	
	//next check if the current lexics is something alphabetic
	checkAlphabetic(inf, nextChar,currentLexics);
	if (strcmp(currentLexics->lexeme,""))
	{
		return currentLexics;
	}

	//if we have something that doesn't fit these categories, then there is an error
	else 
	{
		currentLexics = NULL;
		return currentLexics;
	}
}

//this function checks to see if the current lexics's lexeme is a variation of "="
//since "=" and "==" are both valid lexemes, this takes a step more than just checking for the "=" symbol
//"!=" is also included here just because it involves "="
void checkEquals(FILE *inf, char currentChar, struct lexics *currentLexics)
{
	if (currentChar == '!' && checkNextChar(inf) == '=')
	{
		fgetc(inf);
		currentLexics->token = BINOP;
		strcpy(currentLexics->lexeme,"!=");
	}
	//these two else if statements check "=" vs "==" using checkNextChar
	else if (currentChar == '=' && checkNextChar(inf) == '=')
	{
		fgetc(inf);
		currentLexics->token = BINOP;
		strcpy(currentLexics->lexeme,"==");
	}
	else if (currentChar == '=')
	{
		currentLexics->token = EQUAL;
		strcpy(currentLexics->lexeme,"=");
	}
}

//this function checks if the current lexics's lexeme is a single symbol character
//these are easy to check since there's no ambiguity like with "=" vs "=="
void checkSingleChars(char currentChar, struct lexics *currentLexics)
{
	if (currentChar == '(')
	{
		currentLexics->token = LEFT_PARENTHESIS;
	}
	else if (currentChar == ')')
	{
		currentLexics->token = RIGHT_PARENTHESIS;
	}
	else if (currentChar == '{')
	{
		currentLexics->token = LEFT_BRACKET;
	}
	else if (currentChar == '}')
	{
		currentLexics->token = RIGHT_BRACKET;
	}
	else if (currentChar == ',')
	{
		currentLexics->token = COMMA;
	}
	else if (currentChar == ';')
	{
		currentLexics->token = EOL;
	}
	else if (currentChar == '+' || currentChar == '*' || currentChar == '%')
	{
		currentLexics->token = BINOP;
	}
	//if the current lexics's lexeme is not a single symbol character, don't change its lexeme
	else
	{
		return;
	}
	//if the current lexics's lexeme is a single symbol character, set its lexeme accordingly
	currentLexics->lexeme[0] = currentChar;
	currentLexics->lexeme[1] = '\0'; //end of string character
}

//if a lexeme starts with a digit, it must be a number, we just need to find how long it is
void checkNumeric(FILE * inf, char currentChar, struct lexics *currentLexics)
{
	//since the length of a number varies, we use a buffer to figure out its length
	char * buffer = (char *)malloc(sizeof(char) * LEXEME_MAX);
	int i;
	char tryChar;
	if (isDigit(currentChar))
	{
		buffer[0] = currentChar;
		buffer[1] = '\0';
		i = 1;
	}
	else
	{
		return;
	}
	//try adding the next character to the buffer, 
	//if this makes the buffer not a valid number, don't add it and stop looping
	while (validNumber(buffer))
	{
		tryChar = checkNextChar(inf);
		buffer[i] = tryChar;
		buffer[i+1] = '\0';
		if (!validNumber(buffer))
		{
			buffer[i] = '\0';
			break;
		}
		else
		{
			currentChar = fgetc(inf);
			i++;
		}
	}
	currentLexics->token = NUMBER;
	strcpy(currentLexics->lexeme,buffer);
}

//if a lexeme starts with a letter, there are several possibilities
void checkAlphabetic(FILE * inf, char currentChar, struct lexics *currentLexics)
{
	//since the length of alphabetical lexemes varies, we use a buffer to construct the strings
	char * buffer = (char *)malloc(sizeof(char) * LEXEME_MAX);
	int i;
	char tryChar;
	if (isAlphabetic(currentChar))
	{
		buffer[0] = currentChar;
		buffer[1] = '\0';
		i = 1;
	}
	else
	{
		return;
	}
	//we try adding characters to the buffer, if trying to add a character makes the buffer
	//an invalid lexeme, then we remove it and finish looping
	while(validIdentifier(buffer))
	{
		tryChar = checkNextChar(inf);
		buffer[i] = tryChar;
		buffer[i+1] = '\0';
		//if adding the next character makes the buffer invalid, remove it
		if (!validIdentifier(buffer))
		{
			buffer[i] = '\0';
			break;
		}
		else
		{
			currentChar = fgetc(inf);
			i++;
		}
	}

	//we don't check for these keyword type strings while filling the buffer
	//because we need to follow the principle of longest substring
	if (!strcmp(buffer, "while"))
	{
		currentLexics->token = WHILE_KEYWORD;
		strcpy(currentLexics->lexeme,"while");
		return;
	}
	else if(!strcmp(buffer,"return"))
	{
		currentLexics->token = RETURN_KEYWORD;
		strcpy(currentLexics->lexeme,"return");
		return;
	}
	else if ( !strcmp(buffer,"void") || !strcmp(buffer, "int") )
	{
		currentLexics->token = VARTYPE;
		strcpy(currentLexics->lexeme, buffer);
		return;
	}
	currentLexics->token = IDENTIFIER;
	strcpy(currentLexics->lexeme,buffer);
}

//this function checks if the current character is a whitespace character
int isWhiteSpace(char check)
{
	if (check == ' ' || check == '\t' || check == '\n' || 
			check == '\n' || check == '\v' || check == '\f' || check == '\r')
	{
		return TRUE;
	}
	return FALSE;
}

//this function checks if the current character is a letter
int isAlphabetic(char check)
{
	if ((check >= 'a' && check <= 'z') || (check >= 'A' && check <= 'Z'))
	{
		return TRUE;
	}
	return FALSE;
}

//this function checks if the current chaarcter is a digit
int isDigit(char check)
{
	if (check >= '0' && check <= '9')
	{
		return TRUE;
	}
	return FALSE;
}
