#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#define CTR 1

#include "aes.h"


static int test_encrypt_ctr(void);
static int test_decrypt_ctr(void);

int main(void)
{
    clock_t start, end;
    double cpu_time_used;
    start = clock();
    test_encrypt_ctr();
    end = clock();
    cpu_time_used = ((double)(end - start))/CLOCKS_PER_SEC;
    printf("Encryption time: %fs\n", cpu_time_used);
    start = clock();
    test_decrypt_ctr();
    end = clock();
    cpu_time_used = ((double)(end - start))/CLOCKS_PER_SEC;
    printf("Decryption time: %fs\n", cpu_time_used);
    return 0;
}


static int test_xcrypt_ctr(const char* xcrypt);
static int test_encrypt_ctr(void)
{
    return test_xcrypt_ctr("encrypt");
}

static int test_decrypt_ctr(void)
{
    return test_xcrypt_ctr("decrypt");
}

static int test_xcrypt_ctr(const char* xcrypt)
{
    uint8_t key[16] = { 0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c };
    uint8_t iv[16]  = { 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff };
    struct AES_ctx ctx;
    // CTR mode - Encryption part
    if (strcmp(xcrypt, "encrypt")==0) {
        AES_init_ctx_iv(&ctx, key, iv);
	// input file name - plaintext.txt
    	static const char filenamer[] = "plaintext.txt";
    	static const char filenamee[] = "encrypted.txt";
    	FILE *fr = fopen(filenamer, "rb");
    	FILE *fe = fopen(filenamee, "wb");
    	if (fr == NULL || fe == NULL)
		exit(EXIT_FAILURE);
    	uint8_t * line = (uint8_t *) malloc(64);
    	size_t len = 0, BufContSz;
    	ssize_t read;
    	int i;
    	// reading the file line by line, encrypting and writing back to encrypted.txt
        while ((BufContSz = fread(line, sizeof(uint8_t), 64, fr)) > 0) {
		AES_CTR_xcrypt_buffer(&ctx, line, BufContSz);
		fwrite(line, sizeof(uint8_t), BufContSz, fe);
	}

    	fclose(fr);
    	fclose(fe);
    	if (line)
		free(line);
    }
    // CTR mode - Decryption part
    else {
        AES_init_ctx_iv(&ctx, key, iv);
	// input file encrypted.txt(will be written by encryption part, no need to create
	static const char filenamed[] = "decrypted.txt";
    	static const char filenamee[] = "encrypted.txt";
    	FILE *fe = fopen(filenamee, "rb");
    	FILE *fd = fopen(filenamed, "wb");
    	if (fe == NULL || fd == NULL)
		exit(EXIT_FAILURE);
    	uint8_t * line = (uint8_t *) malloc(64);
    	size_t len = 0, BufContSz;
    	ssize_t read;
    	int i;
    	// Decrypting line by line and writing back to decrypted.txt
	while ((BufContSz = fread(line, sizeof(uint8_t), 64, fe)) > 0) {
		AES_CTR_xcrypt_buffer(&ctx, line, BufContSz);
		fwrite(line, sizeof(uint8_t), BufContSz, fd);
	}

    	fclose(fe);
    	fclose(fd);
    	if (line)
		free(line);

    }
 
}
