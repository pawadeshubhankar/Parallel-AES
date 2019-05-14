#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <cuda.h>
#include <sys/stat.h>
#include <math.h>

// Enable ECB, CTR and CBC mode. Note this can be done before including aes.h or at compile-time.
// E.g. with GCC by using the -D flag: gcc -c aes.c -DCBC=0 -DCTR=1 -DECB=1
#define CBC 0
#define CTR 1
#define ECB 0

#include "aes.h"
#define THREADS_PER_BLOCK 1024

void test_xcrypt_ctr(const char* xcrypt)
{
    uint8_t key[16] = { 0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c };
    
    uint8_t iv[16]  = { 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff };
    
    struct AES_ctx ctx;
    
    if (strcmp(xcrypt, "encrypt")==0) {
        AES_init_ctx_iv(&ctx, key, iv);
        printf("Encryption kernel launching..\n");
    	static const char filenamer[] = "plaintext.txt";
    	static const char filenamee[] = "encrypted.txt";
    	FILE *fr = fopen(filenamer, "rb");
    	FILE *fe = fopen(filenamee, "wb");
    	if (fr == NULL || fe == NULL)
		exit(EXIT_FAILURE);
    	size_t len = 0, BufContSz;
    	ssize_t read;
    	int i;
        uint8_t *d_file;
        struct AES_ctx *d_ctx;
        cudaMalloc(&d_ctx, sizeof(AES_ctx));
        cudaMemcpy(d_ctx, &ctx, sizeof(AES_ctx), cudaMemcpyHostToDevice);
        struct stat buffer;
        int status = stat(filenamer, &buffer);
        if (status != 0)
		printf("File size reading error");
        size_t file_size = buffer.st_size;
        uint8_t *file_data = (uint8_t *)malloc(file_size);
        uint8_t *file_dat = (uint8_t *)malloc(file_size);
        cudaMalloc(&d_file, file_size);
        fread(file_data, 1, file_size, fr);
	int numThreads = (file_size+63)/64;
	int numBlocks = numThreads/1024;
	int sqrtBlocks = sqrt(numBlocks)+1;
        cudaMemcpy(d_file, file_data, file_size, cudaMemcpyHostToDevice);
        dim3 dimBlock(32, 32, 1);
        dim3 dimGrid(sqrtBlocks, sqrtBlocks, 1);
	AES_CTR_xcrypt_buffer<<<dimGrid, dimBlock>>>(d_ctx, d_file, 64, file_size);
        cudaDeviceSynchronize();
        cudaMemcpy(file_dat, d_file, file_size, cudaMemcpyDeviceToHost);
        fwrite(file_dat, 1, file_size, fe);

    	fclose(fr);
    	fclose(fe);
	cudaFree(d_file);
	cudaFree(d_ctx);
	free(file_data);
	free(file_dat);
    }
    else {
        AES_init_ctx_iv(&ctx, key, iv);
        printf("Decryption kernel launching..\n");
	static const char filenamed[] = "decrypted.txt";
    	static const char filenamee[] = "encrypted.txt";
    	FILE *fe = fopen(filenamee, "rb");
    	FILE *fd = fopen(filenamed, "wb");
    	if (fe == NULL || fd == NULL)
		exit(EXIT_FAILURE);
    	size_t len = 0, BufContSz;
    	ssize_t read;
    	int i;
        uint8_t *de_file;
        struct AES_ctx *de_ctx;
        cudaMalloc(&de_ctx, sizeof(AES_ctx));
        cudaMemcpy(de_ctx, &ctx, sizeof(AES_ctx), cudaMemcpyHostToDevice);
        struct stat buffer;
        int status = stat(filenamee, &buffer);
        if (status != 0)
		printf("File size reading error");
        size_t file_size = buffer.st_size;
        uint8_t *file_data = (uint8_t *)malloc(file_size);
        uint8_t *file_dat = (uint8_t *)malloc(file_size);
        cudaMalloc(&de_file, file_size);
        fread(file_data, 1, file_size, fe);
	int numThreads = (file_size+63)/64;
	int numBlocks = numThreads/1024;
	int sqrtBlocks = sqrt(numBlocks)+1;
        cudaMemcpy(de_file, file_data, file_size, cudaMemcpyHostToDevice);
        dim3 dimBlock(32, 32, 1);
        dim3 dimGrid(sqrtBlocks, sqrtBlocks, 1);
	AES_CTR_xcrypt_buffer<<<dimGrid, dimBlock>>>(de_ctx, de_file, 64, file_size);
        cudaDeviceSynchronize();
        cudaMemcpy(file_dat, de_file, file_size, cudaMemcpyDeviceToHost);
        fwrite(file_dat, 1, file_size, fd);

    	fclose(fe);
    	fclose(fd);
	cudaFree(de_file);
	cudaFree(de_ctx);
	free(file_data);
	free(file_dat);

    }
 
}

int main(void)
{
    clock_t start, end;
    double cpu_time_used;
    start = clock();
    test_xcrypt_ctr("encrypt");
    end = clock();
    cpu_time_used = ((double)(end - start))/CLOCKS_PER_SEC;
    printf("Encryption time: %fs\n", cpu_time_used);
    start = clock();
    test_xcrypt_ctr("decrypt");
    end = clock();
    cpu_time_used = ((double)(end - start))/CLOCKS_PER_SEC;
    printf("Decryption time: %fs\n", cpu_time_used);
    return 0;
}
