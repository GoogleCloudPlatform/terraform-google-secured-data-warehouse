{
    "deidentifyTemplate": {
        displayName: "${display_name}",
        description: "${description}",
        "deidentifyConfig": {
            "recordTransformations": {
                "fieldTransformations": [
                    {
                        "fields": [
                            {
                                "name": "name"
                            }
                        ],
                        "primitiveTransformation": {
                            "cryptoDeterministicConfig": {
                                "cryptoKey": {
                                    "kmsWrapped": {
                                        "cryptoKeyName": "${crypto_key}",
                                        "wrappedKey": "${wrapped_key}"
                                    }
                                },
                            }
                        }
                    }
                ]
            }
        }
    },
    "templateId": "${template_id}"
}
