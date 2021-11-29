# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def encrypt_symmetric(project_id, location_id, key_ring_id, key_id):
    """
    Encrypt securely generated random bytes using a symmetric key.

    Args:
        project_id (string): Google Cloud project ID.
        location_id (string): Cloud KMS location.
        key_ring_id (string): ID of the Cloud KMS key ring.
        key_id (string): ID of the key to use.

    Returns:
        bytes: Encrypted ciphertext.
    """

    # Import the client library.
    from google.cloud import kms

    # Import base64 for printing the ciphertext.
    import base64

    # Generate random bytes
    key = generate_random_bytes(project_id, location_id, 32)

    # Convert the key to bytes.
    plaintext_bytes = base64.b64encode(key)

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
    if not encrypt_response.ciphertext_crc32c == \
            crc32c(encrypt_response.ciphertext):
        raise Exception(
            'The response received from the server was corrupted in-transit.')
    # End integrity verification

    print(base64.b64encode(encrypt_response.ciphertext))
    return encrypt_response


def generate_random_bytes(project_id, location_id, num_bytes):
    """
    Generate random bytes with entropy sourced from the given location.

    Args:
        project_id (string): Google Cloud project ID (e.g. 'my-project').
        location_id (string): Cloud KMS location (e.g. 'us-east1').
        num_bytes (integer): number of bytes of random data.

    Returns:
        bytes: Encrypted ciphertext.

    """

    # Import the client library.
    from google.cloud import kms

    # Create the client.
    client = kms.KeyManagementServiceClient()

    # Build the location name.
    location_name = client.common_location_path(project_id, location_id)

    # Call the API.
    protection_level = kms.ProtectionLevel.HSM
    random_bytes_response = client.generate_random_bytes(
        request={'location': location_name, 'length_bytes': num_bytes,
                 'protection_level': protection_level})

    return random_bytes_response.data


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

    parser = argparse.ArgumentParser(
        description='Encrypt securely generated random bytes'
                    'using a symmetric key.')
    parser.add_argument('--project_id', dest='project_id',
                        help='project_id (string): Google Cloud project ID.')
    parser.add_argument('--location_id', dest='location_id',
                        help='location_id (string): Cloud KMS location.')
    parser.add_argument('--key_ring_id', dest='key_ring_id',
                        help="key_ring_id (string): ID of the"
                        "Cloud KMS key ring.")
    parser.add_argument('--key_id', dest='key_id',
                        help='key_id (string): ID of the key to use.')

    args = parser.parse_args()
    encrypt_symmetric(args.project_id, args.location_id,
                      args.key_ring_id, args.key_id)
