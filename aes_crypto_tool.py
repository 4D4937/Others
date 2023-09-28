from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from base64 import b64encode, b64decode
from cryptography.hazmat.primitives import padding
from getpass import getpass


def pad(text):
    padder = padding.PKCS7(128).padder()
    padded_data = padder.update(text) + padder.finalize()
    return padded_data


def unpad(padded_data):
    unpadder = padding.PKCS7(128).unpadder()
    data = unpadder.update(padded_data) + unpadder.finalize()
    return data


def encrypt_cbc(text, key, iv):
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
    encryptor = cipher.encryptor()
    padded_text = pad(text)
    ciphertext = encryptor.update(padded_text) + encryptor.finalize()
    return b64encode(ciphertext)


def decrypt_cbc(ciphertext, key, iv):
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
    decryptor = cipher.decryptor()
    ciphertext = b64decode(ciphertext)
    padded_text = decryptor.update(ciphertext) + decryptor.finalize()
    return unpad(padded_text)


def main():
    key = getpass("Enter the key: ").encode('utf-8')
    iv = getpass("Enter the IV: ").encode('utf-8')

    # Pad key and IV if their length is less than 16 bytes
    key = key.ljust(16, b'\x00')
    iv = iv.ljust(16, b'\x00')

    operation = input("Enter 'e' for encryption or 'd' for decryption: ")

    if operation == 'e':
        text = input("Enter the text to encrypt: ").encode('utf-8')
        encrypted_text = encrypt_cbc(text, key, iv)
        print("Encrypted Text:", encrypted_text.decode('utf-8'))
    elif operation == 'd':
        text = input("Enter the text to decrypt (in base64 format): ")
        decrypted_text = decrypt_cbc(text, key, iv)
        print("Decrypted Text:", decrypted_text.decode('utf-8'))
    else:
        print("Invalid operation. Please enter 'e' or 'd'.")


if __name__ == "__main__":
    main()
