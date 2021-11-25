
def encrypt_symmetric(project_id, location_id, key_ring_id, key_id, plaintext):
    """
    Encrypt plaintext using a symmetric key.

    Args:
        project_id (string): Google Cloud project ID.
        location_id (string): Cloud KMS location.
        key_ring_id (string): ID of the Cloud KMS key ring.
        key_id (string): ID of the key to use.
        plaintext (string): message to encrypt

    Returns:
        bytes: Encrypted ciphertext.
    """

    # Import the client library.
    from google.cloud import kms

    # Import base64 for printing the ciphertext.
    import base64

    # Convert the plaintext to bytes.
    plaintext_bytes = plaintext.encode('utf-8')

    # Optional, but recommended: compute plaintext's CRC32C.
    # See crc32c() function defined below.
    plaintext_crc32c = crc32c(plaintext_bytes)

    # Create the client.
    client = kms.KeyManagementServiceClient()

    # Build the key name.
    key_name = client.crypto_key_path(
        project_id, location_id, key_ring_id, key_id)

    # Call the API.
    encrypt_response = client.encrypt(
        request={'name': key_name, 'plaintext': plaintext_bytes,
                 'plaintext_crc32c': plaintext_crc32c})

    # Optional, but recommended: perform integrity verification
    # on encrypt_response.
    # For more details on ensuring E2E in-transit integrity to
    # and from Cloud KMS visit:
    # https://cloud.google.com/kms/docs/data-integrity-guidelines
    if not encrypt_response.verified_plaintext_crc32c:
        raise Exception(
            'The request sent to the server was corrupted in-transit.')
    if not encrypt_response.ciphertext_crc32c == crc32c(encrypt_response.ciphertext):
        raise Exception(
            'The response received from the server was corrupted in-transit.')
    # End integrity verification

    print('Ciphertext: {}'.format(base64.b64encode(encrypt_response.ciphertext)))
    return encrypt_response


def crc32c(data):
    """
    Calculates the CRC32C checksum of the provided data.

    Args:
        data: the bytes over which the checksum should be calculated.

    Returns:
        An int representing the CRC32C checksum of the provided bytes.
    """
    import crcmod
    import six
    crc32c_fun = crcmod.predefined.mkPredefinedCrcFun('crc-32c')
    return crc32c_fun(six.ensure_binary(data))


if __name__ == '__main__':
    import argparse
    import sys

    parser = argparse.ArgumentParser(
        description='Encrypt plaintext using a symmetric key.')
    parser.add_argument('--project_id', dest='project_id',
                        help='project_id (string): Google Cloud project ID.')
    parser.add_argument('--location_id', dest='location_id',
                        help='location_id (string): Cloud KMS location.')
    parser.add_argument('--key_ring_id', dest='key_ring_id',
                        help='key_ring_id (string): ID of the Cloud KMS key ring.')
    parser.add_argument('--key_id', dest='key_id',
                        help='key_id (string): ID of the key to use.')
    parser.add_argument('--plaintext', dest='plaintext',
                        help='plaintext (string): message to encrypt')

    args = parser.parse_args()
    sys.exit(encrypt_symmetric(args.project_id, args.location_id,
             args.key_ring_id, args.key_id, args.plaintext))
