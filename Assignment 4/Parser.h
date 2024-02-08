#ifndef PARSER_H
#define PARSER_H

#include "Givens.h"

_Bool parser(struct lexics * someLexics, int numberOfLexics);
int checkLexics(struct lexics * checkLexics, int token);
int consume(struct lexics * checkLexics, int numLexics);
int consumeFunction(struct lexics * someLexics, int numLexics);
int consumeHeader(struct lexics * someLexics, int numLexics);
int consumeArgDecl(struct lexics * someLexics, int numLexics);
int consumeBody(struct lexics * someLexics, int numLexics);
int consumeStmtList(struct lexics * someLexics, int numLexics);
int consumeStmt(struct lexics * someLexics, int numLexics);
int consumeWhile(struct lexics * someLexics, int numLexics);
int consumeReturn(struct lexics * someLexics, int numLexics);
int consumeAssignment(struct lexics * someLexics, int numLexics);
int consumeExpression(struct lexics * someLexics, int numLexics);
int consumeTerm(struct lexics * someLexics, int  numLexics);

#endif
