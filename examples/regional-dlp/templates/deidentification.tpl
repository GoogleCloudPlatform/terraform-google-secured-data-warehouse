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
                                "name": "author"
                            }
                        ],
                        "primitiveTransformation": {
                            "cryptoReplaceFfxFpeConfig": {
                                "cryptoKey": {
                                    "kmsWrapped": {
                                        "cryptoKeyName": "${crypto_key}",
                                        "wrappedKey": "${wrapped_key}"
                                    }
                                },
                                "customAlphabet": "abcdefghijklmnopqrstuvwxyz _-;:,.ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                            }
                        }
                    }
                ]
            }
        }
    },
    "templateId": "${template_id}"
}
