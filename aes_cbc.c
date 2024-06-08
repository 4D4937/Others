#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <openssl/evp.h>
#include <openssl/rand.h>
#include <openssl/err.h>

void handleErrors(void) {
    ERR_print_errors_fp(stderr);
    abort();
}

int pkcs7_pad(unsigned char *input, int length, unsigned char *output, int block_size) {
    int pad_size = block_size - (length % block_size);
    memcpy(output, input, length);
    for (int i = length; i < length + pad_size; i++) {
        output[i] = pad_size;
    }
    return length + pad_size;
}

int pkcs7_unpad(unsigned char *input, int length) {
    int pad_size = input[length - 1];
    return length - pad_size;
}

int encrypt_cbc(unsigned char *plaintext, int plaintext_len, unsigned char *key, unsigned char *iv, unsigned char *ciphertext) {
    EVP_CIPHER_CTX *ctx;
    int len;
    int ciphertext_len;

    if (!(ctx = EVP_CIPHER_CTX_new())) handleErrors();

    if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, iv)) handleErrors();

    if (1 != EVP_EncryptUpdate(ctx, ciphertext, &len, plaintext, plaintext_len)) handleErrors();
    ciphertext_len = len;

    if (1 != EVP_EncryptFinal_ex(ctx, ciphertext + len, &len)) handleErrors();
    ciphertext_len += len;

    EVP_CIPHER_CTX_free(ctx);

    return ciphertext_len;
}

int decrypt_cbc(unsigned char *ciphertext, int ciphertext_len, unsigned char *key, unsigned char *iv, unsigned char *plaintext) {
    EVP_CIPHER_CTX *ctx;
    int len;
    int plaintext_len;

    if (!(ctx = EVP_CIPHER_CTX_new())) handleErrors();

    if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, iv)) handleErrors();

    if (1 != EVP_DecryptUpdate(ctx, plaintext, &len, ciphertext, ciphertext_len)) handleErrors();
    plaintext_len = len;

    if (1 != EVP_DecryptFinal_ex(ctx, plaintext + len, &len)) handleErrors();
    plaintext_len += len;

    EVP_CIPHER_CTX_free(ctx);

    return plaintext_len;
}

void read_input(char *prompt, unsigned char *buffer, int length) {
    printf("%s", prompt);
    fgets((char *)buffer, length, stdin);
    buffer[strcspn((char *)buffer, "\n")] = 0; // Remove newline character
}

int main(void) {
    unsigned char key[17], iv[17];
    unsigned char input_text[1024];
    unsigned char padded_text[1040];
    unsigned char encrypted_text[1040];
    unsigned char decrypted_text[1040];

    memset(key, 0, 17);
    memset(iv, 0, 17);

    read_input("Enter the key (16 bytes): ", key, 17);
    read_input("Enter the IV (16 bytes): ", iv, 17);

    char operation;
    printf("Enter 'e' for encryption or 'd' for decryption: ");
    scanf(" %c", &operation);
    getchar(); // Clear the newline character left in the buffer

    if (operation == 'e') {
        read_input("Enter the text to encrypt: ", input_text, 1024);
        int input_len = strlen((char *)input_text);
        int padded_len = pkcs7_pad(input_text, input_len, padded_text, 16);

        int encrypted_len = encrypt_cbc(padded_text, padded_len, key, iv, encrypted_text);
        printf("Encrypted Text: ");
        for (int i = 0; i < encrypted_len; i++) {
            printf("%02x", encrypted_text[i]);
        }
        printf("\n");

    } else if (operation == 'd') {
        read_input("Enter the text to decrypt (in hex format): ", input_text, 1024);
        int input_len = strlen((char *)input_text) / 2;
        for (int i = 0; i < input_len; i++) {
            sscanf((char *)input_text + 2 * i, "%02hhx", &encrypted_text[i]);
        }

        int decrypted_len = decrypt_cbc(encrypted_text, input_len, key, iv, decrypted_text);
        int unpadded_len = pkcs7_unpad(decrypted_text, decrypted_len);
        decrypted_text[unpadded_len] = 0;

        printf("Decrypted Text: %s\n", decrypted_text);

    } else {
        printf("Invalid operation. Please enter 'e' or 'd'.\n");
    }

    return 0;
}
