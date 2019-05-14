# Parallel-AES

Usage:

========For Serial Implementation of AES: (steps) ==========

1. cd SERIAL_AES

2. replace the plaintext.txt with your file. But, the name should be plaintext.txt

3. make

4. ./test.elf

5. Result - encrypted.txt decrypted.txt with time

You can compare decrypted with plaintext for the accuracy

6. diff decrypted.txt plaintext.txt

=========For Parallel Implementation of AES: (steps) =========

1. cd CUDA_AES

2. replace the plaintext.txt with your file. But, the name should be plaintext.txt

3. Setup the CUDA environment (nvcc should work)

4. make

5. ./test.elf

6. Result - encrypted.txt decrypted.txt with time

You can compare decrypted with plaintext for the accuracy

7. diff decrypted.txt plaintext.txt


Data we used to test our implementation was tweets1m.txt which was used during Mini-Project-2
