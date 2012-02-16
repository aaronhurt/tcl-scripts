#include <stdio.h>
#include <string.h>
#include "defkey.h"

int main(int argc, char **argv) {
	if(argc < 2) {
		printf("Usage, %s <key> \"string\"\n",argv[0]);
		return 0;
	}
		
	if(argc > 2) {
		if(strlen(argv[1]) > 512) {
			printf("Error, Maximum key length is 512 characters.\n");
			return 0;
		}
		printf("%s\n", encrypt_string(argv[1], argv[2]));
		return 0;
	} else {
		printf("%s\n", encrypt_string(DEFAULTKEY, argv[1]));
		return 0;
	}
}
