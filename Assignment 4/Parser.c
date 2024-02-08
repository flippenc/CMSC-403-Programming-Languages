#include "Parser.h"

//currentPosition keeps track of which lexics is the current one
int currentPosition = 0;

_Bool parser(struct lexics * someLexics, int numberOfLexics)
{
	//the grammar begins with function, so we start recursively descending through function
	//if we finish the parse but symbols are left over, also return false since it means there is something invalid
	if (consumeFunction(someLexics, numberOfLexics) == TRUE && currentPosition == numberOfLexics)
	{
		return TRUE;
	}
	return FALSE;
}

//Function to check if the current lexics has the token we are looking for
int checkLexics(struct lexics * checkLexics, int token)
{
	if (checkLexics->token == token)
	{
		return TRUE;
	}
	return FALSE;
}

//Function to "consume" a lexics by updating the array index
int consume(struct lexics * someLexics, int numLexics)
{
	if (currentPosition < numLexics)
	{
		currentPosition++;
		*someLexics = someLexics[currentPosition];
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

//This function describes the rule:
//function --> header body
//if header or body returns false, then there is an issue
int consumeFunction(struct lexics * someLexics, int numLexics)
{
	if (consumeHeader(someLexics, numLexics) == FALSE)
	{
		return FALSE;
	}
	if (consumeBody(someLexics, numLexics) == FALSE)
	{
		return FALSE;
	}
	return TRUE;
}

//This function describes the rule:
//header --> VARTYPE IDENTIFIER LEFT_PARENTHESIS [arg-decl] RIGHT_PARENTHESIS
//If any of the required components are missing or different, there is an error
//arg-decl is optional but if the contents of arg-decl are invalid, there is an error
int consumeHeader(struct lexics * someLexics, int numLexics)
{
	if (checkLexics(someLexics,VARTYPE) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	if (checkLexics(someLexics, IDENTIFIER) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	if (checkLexics(someLexics, LEFT_PARENTHESIS) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	//check if arg-decl is present and descend into it if so
	if (checkLexics(someLexics, VARTYPE) == TRUE)
	{
		if (consumeArgDecl(someLexics, numLexics) == FALSE)
		{
			return FALSE;
		}
	}

	if (checkLexics(someLexics, RIGHT_PARENTHESIS) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
		return TRUE;
	}
}

//This function describes the rule:
//arg-decl --> VARTYPE IDENTIFIER {COMMA VARTYPE IDENTIFIER }
//If VARTYPE or IDENTIFIER is not present or is incorrectly formatted, there is an error
//loop through COMMA VARTYPE IDENTIFIER as needed - having it is optional but if it is not correctly formatted, there is an error
int consumeArgDecl(struct lexics * someLexics, int numLexics)
{
	if (checkLexics(someLexics, VARTYPE) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	if (checkLexics(someLexics, IDENTIFIER) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	while(checkLexics(someLexics, COMMA) == TRUE)
	{
		//consume the comma, then check for VARTYPE and IDENTIFIER
		consume(someLexics, numLexics);

		if (checkLexics(someLexics, VARTYPE) == FALSE)
		{
			return FALSE;
		}
		else
		{
			consume(someLexics, numLexics);
		}

		if (checkLexics(someLexics, IDENTIFIER) == FALSE)
		{
			return FALSE;
		}
		else
		{
			consume(someLexics, numLexics);
		}
	}
	
	return TRUE;
}

//This function represents the rule:
//body --> LEFT_BRACKET [statement-list] RIGHT_BRACKET
//statement-list is optional
int consumeBody(struct lexics * someLexics, int numLexics)
{
	if (checkLexics(someLexics, LEFT_BRACKET) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	//stmtlist is optional, we need to check if it is present
	//stmtlist is present if the next token is part of a statement
	//statements involve while loops, returns, assignments, or another body
	//so the tokens to check for are WHILE_KEYWORD, RETURN_KEYWORD, IDENTIFIER, and LEFT_BRACKET
	if (checkLexics(someLexics, WHILE_KEYWORD) == TRUE
		|| checkLexics(someLexics, RETURN_KEYWORD) == TRUE
		|| checkLexics(someLexics, IDENTIFIER) == TRUE
		|| checkLexics(someLexics, LEFT_BRACKET) == TRUE)
	{
		//we know it must be a stmtlist now, so we will consume it
		if (consumeStmtList(someLexics, numLexics) == FALSE)
		{
			return FALSE;
		}
	}

	if (checkLexics(someLexics, RIGHT_BRACKET) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
		return TRUE;
	}
}

//This function represents the rule:
//statement-list -> statement {statement}
//At least one statement is required, but many are allowed
int consumeStmtList(struct lexics * someLexics, int numLexics)
{
	if (consumeStmt(someLexics, numLexics) == FALSE)
	{
		return FALSE;
	}

	//now we must check if other statements are present in the list
	//the tokens that can begin a statement are WHILE_KEYWORD, RETURN_KEYWORD, IDENTIFIER, and LEFT_BRACKET
	while (checkLexics(someLexics, WHILE_KEYWORD) == TRUE
		|| checkLexics(someLexics, RETURN_KEYWORD) == TRUE
		|| checkLexics(someLexics, IDENTIFIER) == TRUE
		|| checkLexics(someLexics, LEFT_BRACKET) == TRUE)
	{
		if (consumeStmt(someLexics, numLexics) == FALSE)
		{
			return FALSE;
		}
	}

	return TRUE;
}

//This function represents the rule:
//statement -> while-loop | return | assignment | body
//Checking which choice appears involves checking if the current token matches the first token
//of while-loop, return, assignment, or body 
//(since we are using single-symbol lookahead, we can only look at the current token)
int consumeStmt(struct lexics * someLexics, int numLexics)
{
	if (checkLexics(someLexics, WHILE_KEYWORD) == TRUE)
	{
		if (consumeWhile(someLexics, numLexics) == FALSE)
		{
			return FALSE;
		}
	}

	else if (checkLexics(someLexics, RETURN_KEYWORD) == TRUE)
	{
		if (consumeReturn(someLexics, numLexics) == FALSE)
		{
			return FALSE;
		}
	}

	else if (checkLexics(someLexics, IDENTIFIER) == TRUE)
	{
		if (consumeAssignment(someLexics, numLexics) == FALSE)
		{
			return FALSE;
		}
	}

	else if (checkLexics(someLexics, LEFT_BRACKET) == TRUE)
	{
		if (consumeBody(someLexics, numLexics) == FALSE)
		{
			return FALSE;
		}
	}

	else
	{
		return FALSE;
	}

	return TRUE;
}

//This function represents the rule:
//while-loop -> WHILE_KEYWORD LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement
//all of these parts are required and if any of them are missing, there is an error
int consumeWhile(struct lexics * someLexics, int numLexics)
{
	if (checkLexics(someLexics, WHILE_KEYWORD) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	if (checkLexics(someLexics, LEFT_PARENTHESIS) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	if (consumeExpression(someLexics, numLexics) == FALSE)
	{
		return FALSE;
	}

	if (checkLexics(someLexics, RIGHT_PARENTHESIS) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	if (consumeStmt(someLexics, numLexics) == FALSE)
	{
		return FALSE;
	}

	return TRUE;
}

//This function represents the rule:
//return --> RETURN_KEYWORD expression EOL
//all of these parts are required and if any of them are missing, there is an error
int consumeReturn(struct lexics * someLexics, int numLexics)
{
	if (checkLexics(someLexics, RETURN_KEYWORD) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	if (consumeExpression(someLexics, numLexics) == FALSE)
	{
		return FALSE;
	}

	if (checkLexics(someLexics, EOL) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
		return TRUE;
	}
}

//This function represents the rule:
//assignment --> IDENTIFIER EQUAL expression EOL
//all of these parts are required and if any of them are missing, there is an error
int consumeAssignment(struct lexics * someLexics, int numLexics)
{
	if (checkLexics(someLexics, IDENTIFIER) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	if (checkLexics(someLexics, EQUAL) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
	}

	if (consumeExpression(someLexics, numLexics) == FALSE)
	{
		return FALSE;
	}

	if (checkLexics(someLexics, EOL) == FALSE)
	{
		return FALSE;
	}
	else
	{
		consume(someLexics, numLexics);
		return TRUE;
	}
}

//This function represents the rule:
//expression --> term {BINOP term} | LEFT_PARENTHESIS expression RIGHT_PARENTHESIS
//There are two options here, so we have to check which one is chosen
//If an options is chosen but as incorrect syntax, or neither option is chosen, there is an error
int consumeExpression(struct lexics * someLexics, int numLexics)
{
	//either term {BINOP term} is next or LEFT_PARENTHESIS expression RIGHT_PARENTHESIS is next
	//first we check for term, meaning either IDENTIFIER or NUMBER is next
	if (checkLexics(someLexics, IDENTIFIER) == TRUE
		|| checkLexics(someLexics, NUMBER) == TRUE)
	{
		if (consumeTerm(someLexics, numLexics) == FALSE)
		{
			return FALSE;
		}

		while (checkLexics(someLexics, BINOP) == TRUE)
		{
			consume(someLexics, numLexics);
			if (consumeTerm(someLexics, numLexics) == FALSE)
			{
				return FALSE;
			}
		}

		return TRUE;
	}
	//now we check if LEFT_PARENTHESIS expression RIGHT_PARENTHESIS is next
	else if (checkLexics(someLexics, LEFT_PARENTHESIS) == TRUE)
	{
		//consume the left paren
		consume(someLexics, numLexics);

		if (consumeExpression(someLexics, numLexics) == FALSE)
		{
			return FALSE;
		}
		
		if (checkLexics(someLexics, RIGHT_PARENTHESIS) == FALSE)
		{
			return FALSE;
		}
		else
		{
			consume(someLexics, numLexics);
			return TRUE;
		}
	}
	//if the two cases weren't met, we have something invalid
	else
	{
		return FALSE;
	}
}

//This function represents the rule:
//term -> IDENTIFIER | NUMBER
//We have to check which option is chosen
int consumeTerm(struct lexics * someLexics, int numLexics)
{
	if (checkLexics(someLexics, IDENTIFIER) == TRUE)
	{
		return consume(someLexics, numLexics);
	}
	else if (checkLexics(someLexics, NUMBER) == TRUE)
	{
		return consume(someLexics, numLexics);
	}
	else
	{
		return FALSE;
	}
}

