# Secured Data Warehouse Blueprint

[FAQ](./docs/FAQ.md) | [Troubleshooting Guide](./docs/TROUBLESHOOTING.md).

This repository contains Terraform configuration modules that allow Google Cloud customers to
quickly deploy a secured [BigQuery](https://cloud.google.com/bigquery) data warehouse,
following the [Secure a BigQuery data warehouse that stores confidential data](https://cloud.google.com/architecture/confidential-data-warehouse-blueprint) guide.
The blueprint allows customers
to use Google Cloud's core strengths in data analytics, and to overcome typical
challenges that include:

- Limited knowledge/experience with best practices for creating, deploying, and operating in Google
Cloud.
- Security/risk concerns and restrictions from their internal security, risk, and compliance teams.
- Regulatory and compliance approval from external auditors.

The Terraform configurations in this repository provide customers with an opinionated architecture
that incorporates and documents best practices for a performant and scalable design, combined with
security by default for control, logging and evidence generation. It can be  simply deployed by
customers through a Terraform workflow.

## Resources created by this module

- Data Ingestion
  - Data Ingestion bucket
  - Data Flow Bucket
  - Data Ingestion Pub/Sub topic
  - DataFlow Controller Service Account
- Data Governance
  - Cloud KMS Keyring
  - Cloud KMS Keys
    - Data Ingestion Key
    - BigQuery Key
    - Re-Identification Key
    - De-Identification Key
  - Encrypters and Decrypters roles
- Non-confidential Data
  - Big Query Dataset
- Confidential Data
  - DataFlow Bucket
  - BigQuery Dataset
  - DataFlow Controller Service Account
- VPC Service Control
  - Data Ingestion Perimeter
  - Data Governance Perimeter
  - Confidential Data Perimeter
  - Access Level policy
  - VPC SC Bridges between:
    - Confidential Data and Data Governance
    - Confidential Data and Data Ingestion
    - Data Ingestion and Data Governance
- IAM
  - Remove Owner roles
  - Grant roles to groups listed at [Security Groups](#security-groups) section
- Organization Policies
  - Restrict Protocol Forwarding Creation Policy
  - Disable Serial Port Logging Policy
  - Require OS Login
  - Trusted VPC Subnetwork Policy
  - VM External IP Access Policy
  - Location Restriction Policy
  - Service Account Disable Key Policy
  - Service Account Disable Creation Policy

## Disclaimer

When using this blueprint, it is important to understand how you manage [separation of duties](https://cloud.google.com/kms/docs/separation-of-duties). We recommend you remove all primitive `owner` roles in the projects used as inputs for the *Data Warehouse module*. The secured data warehouse itself does not need any primitive owner roles for correct operations.

When using this blueprint in the example mode or when using this blueprint to create the new projects with default configurations for the deployment, we automatically remove the owner role as it has too broad access.

However, if you choose to use this blueprint with pre-existing projects in your organization, we will not proactively remove any pre-existing owner role assignments, as we won’t know your intent for or dependency on these role assignments in your pre-existing workloads. The pre-existing presence of these roles does expand the attack and risk surface of the resulting deployment. Therefore, we highly recommend you review your use of owner roles in these pre-existing cases and see if you can eliminate them to improve your resulting security posture. Only you can determine the appropriate trade-off to meet your business requirements.

You can check the current situation of your project with either of the following methods:

- Using [Security Health Analytics](https://cloud.google.com/security-command-center/docs/concepts-vulnerabilities-findings#security-health-analytics-detectors) (SHA), checking the [KMS vulnerability findings](https://cloud.google.com/security-command-center/docs/concepts-vulnerabilities-findings#kms-findings), for the Detector `KMS_PROJECT_HAS_OWNER`.
  - You can search for the SHA findings with category `KMS_PROJECT_HAS_OWNER` in the Security Command Center in the  Google Cloud Console.
- You can also use Cloud Asset Inventory [search-all-iam-policies](https://cloud.google.com/asset-inventory/docs/searching-iam-policies#search_policies) gcloud command doing a [Query by role](https://cloud.google.com/asset-inventory/docs/searching-iam-policies#examples_query_by_role) to search for owner of the project.

See the [terraform-example-foundation](https://github.com/terraform-google-modules/terraform-example-foundation) for additional good practices.

## Usage

Basic usage of this module is as follows:

```hcl
module "secured_data_warehouse" {
  source  = "terraform-google-modules/secured-data-warehouse/google"
  version = "~> 0.1"

  org_id                           = ORG_ID
  data_governance_project_id       = DATA_GOVERNANCE_PROJECT_ID
  confidential_data_project_id     = CONFIDENTIAL_DATA_PROJECT_ID
  non_confidential_data_project_id = NON_CONFIDENTIAL_DATA_PROJECT_ID
  data_ingestion_project_id        = DATA_INGESTION_PROJECT_ID
  sdx_project_number               = EXTERNAL_TEMPLATE_PROJECT_NUMBER
  terraform_service_account        = TERRAFORM_SERVICE_ACCOUNT
  access_context_manager_policy_id = ACCESS_CONTEXT_MANAGER_POLICY_ID
  bucket_name                      = DATA_INGESTION_BUCKET_NAME
  pubsub_resource_location         = PUBSUB_RESOURCE_LOCATION
  location                         = LOCATION
  trusted_locations                = TRUSTED_LOCATIONS
  dataset_id                       = DATASET_ID
  confidential_dataset_id          = CONFIDENTIAL_DATASET_ID
  cmek_keyring_name                = CMEK_KEYRING_NAME
  perimeter_additional_members     = PERIMETER_ADDITIONAL_MEMBERS
  data_engineer_group              = DATA_ENGINEER_GROUP
  data_analyst_group               = DATA_ANALYST_GROUP
  security_analyst_group           = SECURITY_ANALYST_GROUP
  network_administrator_group      = NETWORK_ADMINISTRATOR_GROUP
  security_administrator_group     = SECURITY_ADMINISTRATOR_GROUP
  delete_contents_on_destroy       = false
}
```

**Note:** There are three inputs related to GCP Locations in the module:

- `pubsub_resource_location`: is used to define which GCP location will be used to [Restrict Pub/Sub resource locations](https://cloud.google.com/pubsub/docs/resource-location-restriction). This policy offers a way to ensure that messages published to a topic are never persisted outside of a Google Cloud regions you specify, regardless of where the publish requests originate. **Zones or multi-region locations are not supported**.
- `location`: is used to define which GCP region will be used for all other resources created: [Cloud Storage buckets](https://cloud.google.com/storage/docs/locations), [BigQuery datasets](https://cloud.google.com/bigquery/docs/locations), and [Cloud KMS key rings](https://cloud.google.com/kms/docs/locations). **Multi-region locations are supported**.
- `trusted_locations`: is a list of locations that are used to set an [Organization Policy](https://cloud.google.com/resource-manager/docs/organization-policy/defining-locations#location_types) that restricts the GCP locations that can be used in the projects of the Secured Data Warehouse. Both `pubsub_resource_location` and `location` must respect this restriction.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | `string` | `""` | no |
| bucket\_class | The storage class for the bucket being provisioned. | `string` | `"STANDARD"` | no |
| bucket\_lifecycle\_rules | List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches\_storage\_class should be a comma delimited string. | <pre>list(object({<br>    # Object with keys:<br>    # - type - The type of the action of this Lifecycle Rule. Supported values: Delete and SetStorageClass.<br>    # - storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.<br>    action = any<br><br>    # Object with keys:<br>    # - age - (Optional) Minimum age of an object in days to satisfy this condition.<br>    # - created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.<br>    # - with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".<br>    # - matches_storage_class - (Optional) Storage Class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.<br>    # - matches_prefix - (Optional) One or more matching name prefixes to satisfy this condition.<br>    # - matches_suffix - (Optional) One or more matching name suffixes to satisfy this condition<br>    # - num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.<br>    condition = any<br>  }))</pre> | <pre>[<br>  {<br>    "action": {<br>      "type": "Delete"<br>    },<br>    "condition": {<br>      "age": 30,<br>      "matches_storage_class": "STANDARD",<br>      "with_state": "ANY"<br>    }<br>  }<br>]</pre> | no |
| bucket\_name | The name of the bucket being provisioned. | `string` | n/a | yes |
| cmek\_keyring\_name | The Keyring prefix name for the KMS Customer Managed Encryption Keys being provisioned. | `string` | n/a | yes |
| confidential\_data\_access\_level\_allowed\_device\_management\_levels | Condition - A list of allowed device management levels. An empty list allows all management levels. | `list(string)` | `[]` | no |
| confidential\_data\_access\_level\_allowed\_encryption\_statuses | Condition - A list of allowed encryptions statuses. An empty list allows all statuses. | `list(string)` | `[]` | no |
| confidential\_data\_access\_level\_combining\_function | How the conditions list should be combined to determine if a request is granted this AccessLevel. If AND is used, each Condition must be satisfied for the AccessLevel to be applied. If OR is used, at least one Condition must be satisfied for the AccessLevel to be applied. | `string` | `"AND"` | no |
| confidential\_data\_access\_level\_ip\_subnetworks | Condition - A list of CIDR block IP subnetwork specification. May be IPv4 or IPv6. Note that for a CIDR IP address block, the specified IP address portion must be properly truncated (that is, all the host bits must be zero) or the input is considered malformed. For example, "192.0.2.0/24" is accepted but "192.0.2.1/24" is not. Similarly, for IPv6, "2001:db8::/32" is accepted whereas "2001:db8::1/32" is not. The originating IP of a request must be in one of the listed subnets in order for this Condition to be true. If empty, all IP addresses are allowed. | `list(string)` | `[]` | no |
| confidential\_data\_access\_level\_minimum\_version | The minimum allowed OS version. If not set, any version of this OS satisfies the constraint. Format: "major.minor.patch" such as "10.5.301", "9.2.1". | `string` | `""` | no |
| confidential\_data\_access\_level\_negate | Whether to negate the Condition. If true, the Condition becomes a NAND over its non-empty fields, each field must be false for the Condition overall to be satisfied. | `bool` | `false` | no |
| confidential\_data\_access\_level\_os\_type | The operating system type of the device. | `string` | `"OS_UNSPECIFIED"` | no |
| confidential\_data\_access\_level\_regions | Condition - The request must originate from one of the provided countries or regions. Format: A valid ISO 3166-1 alpha-2 code. | `list(string)` | `[]` | no |
| confidential\_data\_access\_level\_require\_corp\_owned | Condition - Whether the device needs to be corp owned. | `bool` | `false` | no |
| confidential\_data\_access\_level\_require\_screen\_lock | Condition - Whether or not screenlock is required for the DevicePolicy to be true. | `bool` | `false` | no |
| confidential\_data\_dataflow\_deployer\_identities | List of members in the standard GCP form: user:{email}, serviceAccount:{email} that will deploy Dataflow jobs in the Confidential Data project. These identities will be added to the VPC-SC secure data exchange egress rules. | `list(string)` | `[]` | no |
| confidential\_data\_egress\_policies | A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) for the Confidential Data perimeter, each list object has a `from` and `to` value that describes egress\_from and egress\_to. See also [secure data exchange](https://cloud.google.com/vpc-service-controls/docs/secure-data-exchange#allow_access_to_a_google_cloud_resource_outside_the_perimeter) and the [VPC-SC](https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/blob/v3.1.0/modules/regular_service_perimeter/README.md) module.  You can use the placeholders `DATA_INGESTION_DATAFLOW_CONTROLLER_SA` and `CONFIDENTIAL_DATA_DATAFLOW_CONTROLLER_SA` to refer to the services accounts being created by the main module. | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| confidential\_data\_ingress\_policies | A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress\_from and ingress\_to.<br><br>Example: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions). You can use the placeholders `DATA_INGESTION_DATAFLOW_CONTROLLER_SA` and `CONFIDENTIAL_DATA_DATAFLOW_CONTROLLER_SA` to refer to the services accounts being created by the main module. | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| confidential\_data\_perimeter | Existing confidential data perimeter to be used instead of the auto-created perimeter. The service account provided in the variable `terraform_service_account` must be in an access level member list for this perimeter **before** this perimeter can be used in this module. | `string` | `""` | no |
| confidential\_data\_project\_id | Project where the confidential datasets and tables are created. | `string` | n/a | yes |
| confidential\_data\_required\_access\_levels | Condition - A list of other access levels defined in the same Policy, referenced by resource name. Referencing an AccessLevel which does not exist is an error. All access levels listed must be granted for the Condition to be true. | `list(string)` | `[]` | no |
| confidential\_dataset\_id | Unique ID for the confidential dataset being provisioned. | `string` | `"secured_dataset"` | no |
| data\_analyst\_group | Google Cloud IAM group that analyzes the data in the warehouse. | `string` | n/a | yes |
| data\_engineer\_group | Google Cloud IAM group that sets up and maintains the data pipeline and warehouse. | `string` | n/a | yes |
| data\_governance\_access\_level\_allowed\_device\_management\_levels | Condition - A list of allowed device management levels. An empty list allows all management levels. | `list(string)` | `[]` | no |
| data\_governance\_access\_level\_allowed\_encryption\_statuses | Condition - A list of allowed encryptions statuses. An empty list allows all statuses. | `list(string)` | `[]` | no |
| data\_governance\_access\_level\_combining\_function | How the conditions list should be combined to determine if a request is granted this AccessLevel. If AND is used, each Condition must be satisfied for the AccessLevel to be applied. If OR is used, at least one Condition must be satisfied for the AccessLevel to be applied. | `string` | `"AND"` | no |
| data\_governance\_access\_level\_ip\_subnetworks | Condition - A list of CIDR block IP subnetwork specification. May be IPv4 or IPv6. Note that for a CIDR IP address block, the specified IP address portion must be properly truncated (that is, all the host bits must be zero) or the input is considered malformed. For example, "192.0.2.0/24" is accepted but "192.0.2.1/24" is not. Similarly, for IPv6, "2001:db8::/32" is accepted whereas "2001:db8::1/32" is not. The originating IP of a request must be in one of the listed subnets in order for this Condition to be true. If empty, all IP addresses are allowed. | `list(string)` | `[]` | no |
| data\_governance\_access\_level\_minimum\_version | The minimum allowed OS version. If not set, any version of this OS satisfies the constraint. Format: "major.minor.patch" such as "10.5.301", "9.2.1". | `string` | `""` | no |
| data\_governance\_access\_level\_negate | Whether to negate the Condition. If true, the Condition becomes a NAND over its non-empty fields, each field must be false for the Condition overall to be satisfied. | `bool` | `false` | no |
| data\_governance\_access\_level\_os\_type | The operating system type of the device. | `string` | `"OS_UNSPECIFIED"` | no |
| data\_governance\_access\_level\_regions | Condition - The request must originate from one of the provided countries or regions. Format: A valid ISO 3166-1 alpha-2 code. | `list(string)` | `[]` | no |
| data\_governance\_access\_level\_require\_corp\_owned | Condition - Whether the device needs to be corp owned. | `bool` | `false` | no |
| data\_governance\_access\_level\_require\_screen\_lock | Condition - Whether or not screenlock is required for the DevicePolicy to be true. | `bool` | `false` | no |
| data\_governance\_egress\_policies | A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) for the Data Governance perimeter, each list object has a `from` and `to` value that describes egress\_from and egress\_to. See also [secure data exchange](https://cloud.google.com/vpc-service-controls/docs/secure-data-exchange#allow_access_to_a_google_cloud_resource_outside_the_perimeter) and the [VPC-SC](https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/blob/v3.1.0/modules/regular_service_perimeter/README.md) module.  You can use the placeholders `DATA_INGESTION_DATAFLOW_CONTROLLER_SA` and `CONFIDENTIAL_DATA_DATAFLOW_CONTROLLER_SA` to refer to the services accounts being created by the main module. | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| data\_governance\_ingress\_policies | A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress\_from and ingress\_to.<br><br>Example: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions).  You can use the placeholders `DATA_INGESTION_DATAFLOW_CONTROLLER_SA` and `CONFIDENTIAL_DATA_DATAFLOW_CONTROLLER_SA` to refer to the services accounts being created by the main module. | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| data\_governance\_perimeter | Existing data governance perimeter to be used instead of the auto-created perimeter. The service account provided in the variable `terraform_service_account` must be in an access level member list for this perimeter **before** this perimeter can be used in this module. | `string` | `""` | no |
| data\_governance\_project\_id | The ID of the project in which the data governance resources will be created. | `string` | n/a | yes |
| data\_governance\_required\_access\_levels | Condition - A list of other access levels defined in the same Policy, referenced by resource name. Referencing an AccessLevel which does not exist is an error. All access levels listed must be granted for the Condition to be true. | `list(string)` | `[]` | no |
| data\_ingestion\_access\_level\_allowed\_device\_management\_levels | Condition - A list of allowed device management levels. An empty list allows all management levels. | `list(string)` | `[]` | no |
| data\_ingestion\_access\_level\_allowed\_encryption\_statuses | Condition - A list of allowed encryptions statuses. An empty list allows all statuses. | `list(string)` | `[]` | no |
| data\_ingestion\_access\_level\_combining\_function | How the conditions list should be combined to determine if a request is granted this AccessLevel. If AND is used, each Condition must be satisfied for the AccessLevel to be applied. If OR is used, at least one Condition must be satisfied for the AccessLevel to be applied. | `string` | `"AND"` | no |
| data\_ingestion\_access\_level\_ip\_subnetworks | Condition - A list of CIDR block IP subnetwork specification. May be IPv4 or IPv6. Note that for a CIDR IP address block, the specified IP address portion must be properly truncated (that is, all the host bits must be zero) or the input is considered malformed. For example, "192.0.2.0/24" is accepted but "192.0.2.1/24" is not. Similarly, for IPv6, "2001:db8::/32" is accepted whereas "2001:db8::1/32" is not. The originating IP of a request must be in one of the listed subnets in order for this Condition to be true. If empty, all IP addresses are allowed. | `list(string)` | `[]` | no |
| data\_ingestion\_access\_level\_minimum\_version | The minimum allowed OS version. If not set, any version of this OS satisfies the constraint. Format: "major.minor.patch" such as "10.5.301", "9.2.1". | `string` | `""` | no |
| data\_ingestion\_access\_level\_negate | Whether to negate the Condition. If true, the Condition becomes a NAND over its non-empty fields, each field must be false for the Condition overall to be satisfied. | `bool` | `false` | no |
| data\_ingestion\_access\_level\_os\_type | The operating system type of the device. | `string` | `"OS_UNSPECIFIED"` | no |
| data\_ingestion\_access\_level\_regions | Condition - The request must originate from one of the provided countries or regions. Format: A valid ISO 3166-1 alpha-2 code. | `list(string)` | `[]` | no |
| data\_ingestion\_access\_level\_require\_corp\_owned | Condition - Whether the device needs to be corp owned. | `bool` | `false` | no |
| data\_ingestion\_access\_level\_require\_screen\_lock | Condition - Whether or not screenlock is required for the DevicePolicy to be true. | `bool` | `false` | no |
| data\_ingestion\_dataflow\_deployer\_identities | List of members in the standard GCP form: user:{email}, serviceAccount:{email} that will deploy Dataflow jobs in the Data Ingestion project. These identities will be added to the VPC-SC secure data exchange egress rules. | `list(string)` | `[]` | no |
| data\_ingestion\_egress\_policies | A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) for the Data Ingestion perimeter, each list object has a `from` and `to` value that describes egress\_from and egress\_to. See also [secure data exchange](https://cloud.google.com/vpc-service-controls/docs/secure-data-exchange#allow_access_to_a_google_cloud_resource_outside_the_perimeter) and the [VPC-SC](https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/blob/v3.1.0/modules/regular_service_perimeter/README.md) module.  You can use the placeholders `DATA_INGESTION_DATAFLOW_CONTROLLER_SA` and `CONFIDENTIAL_DATA_DATAFLOW_CONTROLLER_SA` to refer to the services accounts being created by the main module. | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| data\_ingestion\_ingress\_policies | A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress\_from and ingress\_to.<br><br>Example: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions).  You can use the placeholders `DATA_INGESTION_DATAFLOW_CONTROLLER_SA` and `CONFIDENTIAL_DATA_DATAFLOW_CONTROLLER_SA` to refer to the services accounts being created by the main module. | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| data\_ingestion\_perimeter | Existing data ingestion perimeter to be used instead of the auto-created perimeter. The service account provided in the variable `terraform_service_account` must be in an access level member list for this perimeter **before** this perimeter can be used in this module. | `string` | `""` | no |
| data\_ingestion\_project\_id | The ID of the project in which the data ingestion resources will be created | `string` | n/a | yes |
| data\_ingestion\_required\_access\_levels | Condition - A list of other access levels defined in the same Policy, referenced by resource name. Referencing an AccessLevel which does not exist is an error. All access levels listed must be granted for the Condition to be true. | `list(string)` | `[]` | no |
| dataset\_default\_table\_expiration\_ms | TTL of tables using the dataset in MS. The default value is null. | `number` | `null` | no |
| dataset\_description | Dataset description. | `string` | `"Data-ingestion dataset"` | no |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | n/a | yes |
| dataset\_name | Friendly name for the dataset being provisioned. | `string` | `"Data-ingestion dataset"` | no |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| enable\_bigquery\_read\_roles\_in\_data\_ingestion | (Optional) If set to true, it will grant to the dataflow controller service account created in the data ingestion project the necessary roles to read from a bigquery table. | `bool` | `false` | no |
| key\_rotation\_period\_seconds | Rotation period for keys. The default value is 30 days. | `string` | `"2592000s"` | no |
| kms\_key\_protection\_level | The protection level to use when creating a key. Possible values: ["SOFTWARE", "HSM"] | `string` | `"HSM"` | no |
| labels | (Optional) Labels attached to Data Warehouse resources. | `map(string)` | `{}` | no |
| location | The location for the KMS Customer Managed Encryption Keys, Cloud Storage Buckets, and Bigquery datasets. This location can be a multi-region. | `string` | `"us-east4"` | no |
| network\_administrator\_group | Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team. | `string` | n/a | yes |
| non\_confidential\_data\_project\_id | The ID of the project in which the Bigquery will be created. | `string` | n/a | yes |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_additional\_members | The list additional members to be added on perimeter access. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required. | `list(string)` | `[]` | no |
| pubsub\_resource\_location | The location in which the messages published to Pub/Sub will be persisted. This location cannot be a multi-region. | `string` | `"us-east4"` | no |
| remove\_owner\_role | (Optional) If set to true, remove all owner roles in all projects in case it has been found in some project. | `bool` | `false` | no |
| sdx\_project\_number | The Project Number to configure Secure data exchange with egress rule for dataflow templates. Required if using a dataflow job template from a private storage bucket outside of the perimeter. | `string` | `""` | no |
| security\_administrator\_group | Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter). | `string` | n/a | yes |
| security\_analyst\_group | Google Cloud IAM group that monitors and responds to security incidents. | `string` | n/a | yes |
| terraform\_service\_account | The email address of the service account that will run the Terraform code. | `string` | n/a | yes |
| trusted\_locations | This is a list of trusted regions where location-based GCP resources can be created. | `list(string)` | <pre>[<br>  "us-locations"<br>]</pre> | no |
| trusted\_subnetworks | The URI of the subnetworks where resources are going to be deployed. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| blueprint\_type | Type of blueprint this module represents. |
| cmek\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the BigQuery service. |
| cmek\_bigquery\_crypto\_key\_name | The Customer Managed Crypto Key name for the BigQuery service. |
| cmek\_confidential\_bigquery\_crypto\_key | The Customer Managed Crypto Key for the confidential BigQuery service. |
| cmek\_confidential\_bigquery\_crypto\_key\_name | The Customer Managed Crypto Key name for the confidential BigQuery service. |
| cmek\_data\_ingestion\_crypto\_key | The Customer Managed Crypto Key for the data ingestion crypto boundary. |
| cmek\_data\_ingestion\_crypto\_key\_name | The Customer Managed Crypto Key name for the data ingestion crypto boundary. |
| cmek\_keyring\_name | The Keyring name for the KMS Customer Managed Encryption Keys. |
| cmek\_reidentification\_crypto\_key | The Customer Managed Crypto Key for the Confidential crypto boundary. |
| cmek\_reidentification\_crypto\_key\_name | The Customer Managed Crypto Key name for the reidentification crypto boundary. |
| confidential\_access\_level\_name | Access context manager access level name. |
| confidential\_data\_dataflow\_bucket\_name | The name of the bucket created for dataflow in the confidential data pipeline. |
| confidential\_dataflow\_controller\_service\_account\_email | The confidential Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
| confidential\_service\_perimeter\_name | Access context manager service perimeter name. |
| data\_governance\_access\_level\_name | Access context manager access level name. |
| data\_governance\_service\_perimeter\_name | Access context manager service perimeter name. |
| data\_ingestion\_access\_level\_name | Access context manager access level name. |
| data\_ingestion\_bigquery\_dataset | The bigquery dataset created for data ingestion pipeline. |
| data\_ingestion\_bucket\_name | The name of the bucket created for the data ingestion pipeline. |
| data\_ingestion\_dataflow\_bucket\_name | The name of the bucket created for dataflow in the data ingestion pipeline. |
| data\_ingestion\_service\_perimeter\_name | Access context manager service perimeter name. |
| data\_ingestion\_topic\_name | The topic created for data ingestion pipeline. |
| dataflow\_controller\_service\_account\_email | The Dataflow controller service account email. See https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#specifying_a_user-managed_controller_service_account. |
| pubsub\_writer\_service\_account\_email | The PubSub writer service account email. Should be used to write data to the PubSub topics the data ingestion pipeline reads from. |
| scheduler\_service\_account\_email | The Cloud Scheduler service account email, no roles granted. |
| storage\_writer\_service\_account\_email | The Storage writer service account email. Should be used to write data to the buckets the data ingestion pipeline reads from. |
| vpc\_sc\_bridge\_confidential\_data\_ingestion | Access context manager bridge name. |
| vpc\_sc\_bridge\_confidential\_governance | Access context manager bridge name. |
| vpc\_sc\_bridge\_data\_ingestion\_governance\_name | Access context manager bridge name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

**Note:** Please see the [Disclaimer](#disclaimer) regarding **project owners** before creating projects.

### Software

Install the following dependencies:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 357.0.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 0.13.7 or later
- [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) version 3.77 or later
- [Terraform Provider for GCP Beta](https://github.com/terraform-providers/terraform-provider-google-beta) version 3.77 or later

### Security Groups

Provide the following groups for separation of duty.
Each group is granted roles to perform their tasks.
Then, add users to the appropriate groups as needed.

- **Data Engineer group**: Google Cloud IAM group that sets up and maintains the data pipeline and warehouse.
- **Data Analyst group**: Google Cloud IAM group that analyzes the data in the warehouse.
- **Security Analyst group**: Google Cloud IAM group that monitors and responds to security incidents.
- **Network Administrator group**: Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team.
- **Security Administrator group**: Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter).

Groups can be created in the Google [Workspace Admin Console](https://support.google.com/a/answer/9400082?hl=en), in the Google [Cloud Console](https://cloud.google.com/iam/docs/groups-in-cloud-console), and using gcloud identity [groups create](https://cloud.google.com/sdk/gcloud/reference/identity/groups/create).

### Service Account

To provision the resources of this module, create a privileged service account, where the service account key cannot be created.
In addition, consider using Cloud Monitoring to alert on this service account's activity.
Grant the following roles to the service account.

- Organization level
  - Access Context Manager Admin: `roles/accesscontextmanager.policyAdmin`
  - Organization Policy Administrator: `roles/orgpolicy.policyAdmin`
  - Organization Administrator: `roles/resourcemanager.organizationAdmin`
- Project level:
  - Data ingestion project
    - App Engine Creator:`roles/appengine.appCreator`
    - Cloud Scheduler Admin:`roles/cloudscheduler.admin`
    - Compute Network Admin:`roles/compute.networkAdmin`
    - Compute Security Admin:`roles/compute.securityAdmin`
    - Dataflow Developer:`roles/dataflow.developer`
    - DNS Administrator:`roles/dns.admin`
    - Project IAM Admin:`roles/resourcemanager.projectIamAdmin`
    - Pub/Sub Admin:`roles/pubsub.admin`
    - Service Account Admin:`roles/iam.serviceAccountAdmin`
    - Service Account Token Creator:`roles/iam.serviceAccountTokenCreator`
    - Service Usage Admin: `roles/serviceusage.serviceUsageAdmin`
    - Storage Admin:`roles/storage.admin`
  - Data governance project
    - Cloud KMS Admin:`roles/cloudkms.admin`
    - Cloud KMS CryptoKey Encrypter:`roles/cloudkms.cryptoKeyEncrypter`
    - DLP De-identify Templates Editor:`roles/dlp.deidentifyTemplatesEditor`
    - DLP Inspect Templates Editor:`roles/dlp.inspectTemplatesEditor`
    - DLP User:`roles/dlp.user`
    - Data Catalog Admin:`roles/datacatalog.admin`
    - Project IAM Admin:`roles/resourcemanager.projectIamAdmin`
    - Secret Manager Admin: `roles/secretmanager.admin`
    - Service Account Admin:`roles/iam.serviceAccountAdmin`
    - Service Account Token Creator:`roles/iam.serviceAccountTokenCreator`
    - Service Usage Admin: `roles/serviceusage.serviceUsageAdmin`
    - Storage Admin:`roles/storage.admin`
  - Non Confidential project
    - BigQuery Admin:`roles/bigquery.admin`
    - Project IAM Admin:`roles/resourcemanager.projectIamAdmin`
    - Service Account Admin:`roles/iam.serviceAccountAdmin`
    - Service Account Token Creator:`roles/iam.serviceAccountTokenCreator`
    - Service Usage Admin: `roles/serviceusage.serviceUsageAdmin`
    - Storage Admin:`roles/storage.admin`
  - Confidential project
    - BigQuery Admin:`roles/bigquery.admin`
    - Compute Network Admin:`roles/compute.networkAdmin`
    - Compute Security Admin:`roles/compute.securityAdmin`
    - DNS Administrator:`roles/dns.admin`
    - Dataflow Developer:`roles/dataflow.developer`
    - Project IAM Admin:`roles/resourcemanager.projectIamAdmin`
    - Service Account Admin:`roles/iam.serviceAccountAdmin`
    - Service Account Token Creator:`roles/iam.serviceAccountTokenCreator`
    - Service Usage Admin: `roles/serviceusage.serviceUsageAdmin`
    - Storage Admin:`roles/storage.admin`

You can use the [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) and the
[IAM module](https://github.com/terraform-google-modules/terraform-google-iam) in combination to provision a
service account with the necessary roles applied.

The user using this service account must have the necessary roles to [impersonate](https://cloud.google.com/iam/docs/impersonating-service-accounts) the service account.

### APIs

Create four projects with the following APIs enabled to host the
resources of this module:

#### Data ingestion project

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- App Engine Admin API:`appengine.googleapis.com`
- Artifact Registry API:`artifactregistry.googleapis.com`
- BigQuery API:`bigquery.googleapis.com`
- Cloud Billing API:`cloudbilling.googleapis.com`
- Cloud Build API:`cloudbuild.googleapis.com`
- Cloud Key Management Service (KMS) API:`cloudkms.googleapis.com`
- Cloud Resource Manager API:`cloudresourcemanager.googleapis.com`
- Cloud Scheduler API:`cloudscheduler.googleapis.com`
- Compute Engine API:`compute.googleapis.com`
- Google Cloud Data Catalog API:`datacatalog.googleapis.com`
- Dataflow API:`dataflow.googleapis.com`
- Cloud Data Loss Prevention (DLP) API:`dlp.googleapis.com`
- Cloud DNS API:`dns.googleapis.com`
- Identity and Access Management (IAM) API:`iam.googleapis.com`
- Cloud Pub/Sub API:`pubsub.googleapis.com`
- Service Usage API:`serviceusage.googleapis.com`
- Google Cloud Storage JSON API:`storage-api.googleapis.com`

#### Data governance project

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- Cloud Billing API:`cloudbilling.googleapis.com`
- Cloud Key Management Service (KMS) API:`cloudkms.googleapis.com`
- Cloud Resource Manager API:`cloudresourcemanager.googleapis.com`
- Google Cloud Data Catalog API:`datacatalog.googleapis.com`
- Cloud Data Loss Prevention (DLP) API:`dlp.googleapis.com`
- Identity and Access Management (IAM) API:`iam.googleapis.com`
- Service Usage API:`serviceusage.googleapis.com`
- Google Cloud Storage JSON API:`storage-api.googleapis.com`
- Secrect Manager API: `secretmanager.googleapis.com`

#### Non-confidential data project

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- BigQuery API:`bigquery.googleapis.com`
- Cloud Billing API:`cloudbilling.googleapis.com`
- Cloud Key Management Service (KMS) API:`cloudkms.googleapis.com`
- Cloud Resource Manager API:`cloudresourcemanager.googleapis.com`
- Identity and Access Management (IAM) API:`iam.googleapis.com`
- Service Usage API:`serviceusage.googleapis.com`
- Google Cloud Storage JSON API:`storage-api.googleapis.com`

#### Confidential data project

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- Artifact Registry API:`artifactregistry.googleapis.com`
- BigQuery API:`bigquery.googleapis.com`
- Cloud Billing API:`cloudbilling.googleapis.com`
- Cloud Build API:`cloudbuild.googleapis.com`
- Cloud Key Management Service (KMS) API:`cloudkms.googleapis.com`
- Cloud Resource Manager API:`cloudresourcemanager.googleapis.com`
- Compute Engine API:`compute.googleapis.com`
- Google Cloud Data Catalog API:`datacatalog.googleapis.com`
- Dataflow API:`dataflow.googleapis.com`
- Cloud Data Loss Prevention (DLP) API:`dlp.googleapis.com`
- Cloud DNS API:`dns.googleapis.com`
- Identity and Access Management (IAM) API:`iam.googleapis.com`
- Service Usage API:`serviceusage.googleapis.com`
- Google Cloud Storage JSON API:`storage-api.googleapis.com`

#### The following APIs must be enabled in the project where the service account was created

- Access Context Manager API: `accesscontextmanager.googleapis.com`
- App Engine Admin API: `appengine.googleapis.com`
- Cloud Billing API:`cloudbilling.googleapis.com`
- Cloud Key Management Service (KMS) API:`cloudkms.googleapis.com`
- Cloud Pub/Sub API: `pubsub.googleapis.com`
- Cloud Resource Manager API:`cloudresourcemanager.googleapis.com`
- Compute Engine API:`compute.googleapis.com`
- Dataflow API:`dataflow.googleapis.com`
- Identity and Access Management (IAM) API:`iam.googleapis.com`

You can use the [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) to
provision the projects with the necessary APIs enabled.

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

- [iam-module](https://registry.terraform.io/modules/terraform-google-modules/iam/google)
- [project-factory-module](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google)
- [terraform-provider-gcp](https://www.terraform.io/docs/providers/google/index.html)
- [terraform](https://www.terraform.io/downloads.html)

---
This is not an officially supported Google product
