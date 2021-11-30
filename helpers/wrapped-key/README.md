# Wrapped Key Helper

This helper uses cloudHSM to generate 256 bits, which is wrapped by an encryption key protected by cloudHSM.
It base64 encodes the output so it can be used in a Cloud DLP de-identification template.

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
