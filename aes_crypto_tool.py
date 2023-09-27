from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from base64 import b64encode, b64decode

def pad(text):
    block_size = 16
    padding = block_size - (len(text) % block_size)
    return text + bytes([padding] * padding)

def unpad(text):
    padding = text[-1]
    return text[:-padding]

def encrypt_ecb(text, key):
    cipher = Cipher(algorithms.AES(key), modes.ECB(), backend=default_backend())
    encryptor = cipher.encryptor()
    padded_text = pad(text)
    ciphertext = encryptor.update(padded_text) + encryptor.finalize()
    return b64encode(ciphertext)

def decrypt_ecb(ciphertext, key):
    cipher = Cipher(algorithms.AES(key), modes.ECB(), backend=default_backend())
    decryptor = cipher.decryptor()
    ciphertext = b64decode(ciphertext)
    padded_text = decryptor.update(ciphertext) + decryptor.finalize()
    return unpad(padded_text)

def main():
    key = input("Enter the key: ").encode('utf-8')

    operation = input("Enter 'e' for encryption or 'd' for decryption: ")

    if operation == 'e':
        text = input("Enter the text to encrypt: ").encode('utf-8')
        encrypted_text = encrypt_ecb(text, key)
        print("Encrypted Text:", encrypted_text)
    elif operation == 'd':
        text = input("Enter the text to decrypt (in base64 format): ")
        decrypted_text = decrypt_ecb(text, key)
        print("Decrypted Text:", decrypted_text.decode('utf-8'))
    else:
        print("Invalid operation. Please enter 'e' or 'd'.")

if __name__ == "__main__":
    main()
