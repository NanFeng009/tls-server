#ifndef _TLS_SERVER_H
#define _TLS_SERVER_H

#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>

typedef struct {
	int     workers;
	int     verbose;
	char   *pid;
	char   *uid;
	struct {
		char *key;
		char *chain;
		char *ca;
	} certs;
	struct {
		char *facility;
		char *type;
		char *level;
	} log;
} config_t;

//int serve(config_t *conf);
#endif
