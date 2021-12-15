# Wrapped Key Helper

This helper uses [cloudHSM](https://cloud.google.com/kms/docs/hsm#create-a-key) to generate 256 [random bits](https://cloud.google.com/kms/docs/generate-random), which are [wrapped by an encryption key](https://cloud.google.com/kms/docs/encrypt-decrypt) protected by cloudHSM.
It base64 encodes the output so it can be used in a Cloud DLP de-identification template.

The keyring used for encryption must be in a region that has cloudHSM [available](https://cloud.google.com/kms/docs/locations#regional:).
This script will be run with the credential configured in the [Cloud SDK](https://cloud.google.com/sdk/docs/authorizing#authorizing_with_a_user_account) tool.

__Note:__ This helper is mainly for sample purpose. You should use your security team's recommend approach to generate and handle key material properly.

## Wrapped Key helper usage

### Install PIP

```sh
python3 -m pip install --user --upgrade pip

python3 -m pip --version
```

### Install Virtual Env

```sh
python3 -m pip install --user virtualenv
```

### Creating a virtual environment

```sh
cd helpers/wrapped-key

python3 -m venv kms_helper
```

### Activating a virtual environment

```sh
source kms_helper/bin/activate
```

### Install dependencies

```sh
pip install -r requirements.txt
```

### Set default application credentials

```sh
gcloud auth application-default login
```

### Run Script

```sh
export project_id=<kms-project-id>
export location_id=<kms-location-id>
export key_ring_id=<kms-king-id>
export key_id=<kms-key-id>

python3 wrapped_key.py \
--project_id ${project_id} \
--location_id ${location_id} \
--key_ring_id ${key_ring_id} \
--key_id ${key_id} \
```

OR

```sh
export crypto_key_path=<crypto-key-path>

python3 wrapped_key.py \
--crypto_key_path ${crypto_key_path}
```

The `crypto-key-path` format is `projects/PROJECT-ID/locations/LOCATION-ID/keyRings/KEY-RING-ID/cryptoKeys/KEY-ID`
