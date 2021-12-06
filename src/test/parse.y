%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <errno.h>
#include <arpa/inet.h>

#include "server.h"

config_t *p_config;

int  yylex(void);
void yyerror(char *str, ...);
int  yyval;
int  yyparse();

%}


%union
{
	double  d;
	char   *string;
	int     i;
}

%token <d> DECIMAL;
%token <i> INT;
%token <string> STRING;
%token <string> LOG_FACILITY;
%token <string> LOG_TYPE;
%token <string> LOG_LEVEL;

%token PID;
%token UID;
%token WORKERS;
%token SESSIONS;


%token KEY;
%token CHAIN;
%token CERT;
%token CERTS

%token LOG
%token LOGLEVEL;
%token LOGTYPE;

%token DELIM;

%%

configuration:
	| configuration common_sess
	| configuration LOG '{' log_sess '}'
	| configuration CERTS '{' certs_sess '}'
	;

common_sess:
	  PID   STRING { p_config->pid           = $2;        }
	| UID   STRING { p_config->uid           = $2;        }
	| WORKERS  INT    { p_config->workers       = $2;        }
	;

log_sess:
		|log_sess log_stmt;
log_stmt:
		LOGLEVEL LOG_LEVEL    { p_config->log.level    = $2; }
    |   LOGTYPE  LOG_TYPE     { p_config->log.type     = $2; }
    ;
		
certs_sess:
		  |certs_sess cert_stmt;

cert_stmt:
		  KEY    STRING { p_config->certs.key     = $2; }
    |     CHAIN  STRING { p_config->certs.chain   = $2; }
    |     CERT     STRING { p_config->certs.ca      = $2; }
    ;

opt_eol:
	   | opt_eol '\n';

%%

char * strdup(const char *src)
{
    size_t len = strlen(src) + 1;
    char *s = malloc(len);
    if (s == NULL)
        return NULL;
    return (char *)memcpy(s, src, len);
}

void strfree(char *src)
{
    free(src);
}


void yyerror(char *str, ...)
{
	fprintf(stderr, "error: %s\n", str);
	extern int yylineno;
	fprintf (stderr, "configuration file line: %d\n", yylineno);
}

int yywrap()
{
	return 1;
}

int parse_config_file (config_t *config_ref, const char *path)
{
	// parse the configuration file and store the results in the structure referenced
	// error messages are output to stderr
	// Returns: 0 for success, otherwise non-zero if an error occurred
	//
	extern FILE *yyin;
	extern int yylineno;

	p_config = malloc(sizeof(config_t));
	p_config = config_ref;

	yyin = fopen (path, "r");
	if (yyin == NULL) {
		fprintf (stderr, "can't open configuration file %s: %s\n", path, strerror(errno));
		return -1;
	}

	yylineno = 1;
	int ret = 0;
	if (ret = yyparse ()) {
		printf("ret =%d\n", ret);
		fclose (yyin);
		return -1;
	} else
		return 0;
}
void dump_config_file(config_t *p_config)
{
printf("pidfile %s\n", p_config->pid);
printf("user %s\n", p_config->uid);
printf("workers %d\n", p_config->workers);

printf("key %s\n", p_config->certs.key);
printf("cert %s\n", p_config->certs.chain);
printf("ca %s\n", p_config->certs.ca);

printf("log_type %s\n", p_config->log.type);
printf("log_level %s\n", p_config->log.level);
}


int main(int argc, char ** argv)
{
#ifdef YYDEBUG
yydebug = 1;
#endif
   config_t config;
  parse_config_file(&config, argv[1]);
  dump_config_file(&config);
}
