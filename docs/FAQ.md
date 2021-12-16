# Frequently Asked Questions

## How do I use an existing VPC-SC service perimeter instead of the perimeter auto-created by the Secured Data Warehouse module?

The Secured Data Warehouse has inputs to use an existing VPC-SC service perimeter:

- `data_ingestion_perimeter`
- `data_governance_perimeter`
- `confidential_data_perimeter`

On your existing VPC-SC service perimeter:

- Configure the additional [services](../service_control.tf#L47) from the Secured Data Warehouse that need to be protected
- Add the terraform service account to the access level member list for this perimeter. The service Account must be in the access level member list **before** this perimeter can be used in this module.
- Add an egress rule to allow access to external Dataflow templates using Cloud Storage API, see [How do I call a Google service protected by the perimeters from a project outside of the auto-created perimeters?](#how-do-i-call-a-google-service-protected-by-the-perimeters-from-a-project-outside-of-the-auto-created-perimeters).

## How do I add new projects to one of the auto-created perimeters?

Use the Terraform resource [google_access_context_manager_service_perimeter_resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/access_context_manager_service_perimeter_resource) to add add new projects to the perimiter.

Each auto-created perimeter has an output for its name:

- `data_ingestion_service_perimeter_name`
- `data_governance_service_perimeter_name`
- `confidential_service_perimeter_name`

example

```hcl
resource "google_access_context_manager_service_perimeter_resource" "service-perimeter-resource" {
  perimeter_name = "accessPolicies/ACCESS-CONTEXT-MANAGER-POLICY-ID/servicePerimeters/PERIMETER-NAME"
  resource       = "projects/PROJECT-NUMBER"
}

```

**Note:** use the input `additional_restricted_services` for additional services from your project that need to be protected by the service perimeter.

## How do I call a Google service protected by the perimeters from a project outside of the auto-created perimeters?

To be able to call a Google service from a project [outside of the perimeter](https://cloud.google.com/vpc-service-controls/docs/secure-data-exchange#access-google-cloud-resource-outside-the-perimeter) you will need to configure
an [egress rule](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) that allows communication to the external service.

Each perimeter has an input for a list of egress rules:

- `data_ingestion_egress_policies`
- `data_governance_egress_policies`
- `confidential_data_egress_policies`

Example of an egress rule that allows reading from a private bucket outside of the project:

```hcl
[
    {
      "from" = {
        "identity_type" = ""
        "identities" = ["user:YOUR-EMAIL","serviceAccount:YOUR-SERVICE-ACCOUNT-EMAIL"]
      },
      "to" = {
        "resources" = ["projects/TARGET-PROJECT-NUMBER"]
        "operations" = {
          "storage.googleapis.com" = {
            "methods" = [
              "google.storage.objects.get"
            ]
          }
        }
      }
    }
]
```

The format is the same one used in the module [terraform-google-vpc-service-controls](https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/blob/v3.1.0/modules/regular_service_perimeter/README.md#usage).

Use the VPC-SC error created when trying to access a service to find out the information for the egress rule:

- The identities that where trying to access the Google API service.
- The Google API service blocked.
- The Google API method blocked.

The error will have a component like:

```shell
Request is prohibited by organization's policy. vpcServiceControlsUniqueIdentifier: UNIQUE-IDENTIFIER
```

Use the Unique Identifier `UNIQUE-IDENTIFIER` value in the [Troubleshoot page](https://console.cloud.google.com/security/service-perimeter/troubleshoot-landing)
to obtain the details regarding the policy violation.

**Note:** Some API methods may not be directly available to be added to the egress rule. In this case use `"methods" = ["*"]`.
