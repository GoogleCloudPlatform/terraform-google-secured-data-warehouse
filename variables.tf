/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "labels" {
  description = "(Optional) Labels attached to Data Warehouse resources."
  type        = map(string)
  default     = {}
}

variable "remove_owner_role" {
  description = "(Optional) If set to true, remove all owner roles in all projects in case it has been found in some project."
  type        = bool
  default     = false
}

variable "trusted_locations" {
  description = "This is a list of trusted regions where location-based GCP resources can be created."
  type        = list(string)
  default     = ["us-locations"]
}

variable "trusted_subnetworks" {
  description = "The URI of the subnetworks where resources are going to be deployed."
  type        = list(string)
  default     = []
}

variable "org_id" {
  description = "GCP Organization ID."
  type        = string
}

variable "pubsub_resource_location" {
  description = "The location in which the messages published to Pub/Sub will be persisted. This location cannot be a multi-region."
  type        = string
  default     = "us-east4"
}

variable "location" {
  description = "The location for the KMS Customer Managed Encryption Keys, Cloud Storage Buckets, and Bigquery datasets. This location can be a multi-region."
  type        = string
  default     = "us-east4"
}

variable "terraform_service_account" {
  description = "The email address of the service account that will run the Terraform code."
  type        = string
}

variable "data_ingestion_project_id" {
  description = "The ID of the project in which the data ingestion resources will be created"
  type        = string
}

variable "data_governance_project_id" {
  description = "The ID of the project in which the data governance resources will be created."
  type        = string
}

variable "non_confidential_data_project_id" {
  description = "The ID of the project in which the Bigquery will be created."
  type        = string
}

variable "confidential_data_project_id" {
  description = "Project where the confidential datasets and tables are created."
  type        = string
}

variable "sdx_project_number" {
  description = "The Project Number to configure Secure data exchange with egress rule for dataflow templates. Required if using a dataflow job template from a private storage bucket outside of the perimeter."
  type        = string
  default     = ""
}

variable "access_context_manager_policy_id" {
  description = "The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format=\"value(name)\"`."
  type        = string
  default     = ""
}

variable "perimeter_additional_members" {
  description = "The list additional members to be added on perimeter access. Prefix user: (user:email@email.com) or serviceAccount: (serviceAccount:my-service-account@email.com) is required."
  type        = list(string)
  default     = []
}

variable "bucket_name" {
  description = "The name of the bucket being provisioned."
  type        = string

  validation {
    condition     = length(var.bucket_name) < 20
    error_message = "The bucket_name must contain less than 20 characters. This ensures the name can be prefixed with the project-id and suffixed with 8 random characters."
  }
}

variable "bucket_class" {
  description = "The storage class for the bucket being provisioned."
  type        = string
  default     = "STANDARD"
}

variable "bucket_lifecycle_rules" {
  description = "List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches_storage_class should be a comma delimited string."
  type = list(object({
    # Object with keys:
    # - type - The type of the action of this Lifecycle Rule. Supported values: Delete and SetStorageClass.
    # - storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.
    action = any

    # Object with keys:
    # - age - (Optional) Minimum age of an object in days to satisfy this condition.
    # - created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.
    # - with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".
    # - matches_storage_class - (Optional) Storage Class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.
    # - matches_prefix - (Optional) One or more matching name prefixes to satisfy this condition.
    # - matches_suffix - (Optional) One or more matching name suffixes to satisfy this condition
    # - num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.
    condition = any
  }))

  default = [{
    action = {
      type = "Delete"
    }
    condition = {
      age                   = 30
      with_state            = "ANY"
      matches_storage_class = "STANDARD"
    }
  }]
}

variable "confidential_dataset_id" {
  description = "Unique ID for the confidential dataset being provisioned."
  type        = string
  default     = "secured_dataset"
}

variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned."
  type        = string
}

variable "dataset_name" {
  description = "Friendly name for the dataset being provisioned."
  type        = string
  default     = "Data-ingestion dataset"
}

variable "dataset_description" {
  description = "Dataset description."
  type        = string
  default     = "Data-ingestion dataset"
}

variable "dataset_default_table_expiration_ms" {
  description = "TTL of tables using the dataset in MS. The default value is null."
  type        = number
  default     = null
}

variable "cmek_keyring_name" {
  description = "The Keyring prefix name for the KMS Customer Managed Encryption Keys being provisioned."
  type        = string
}

variable "key_rotation_period_seconds" {
  description = "Rotation period for keys. The default value is 30 days."
  type        = string
  default     = "2592000s"
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = false
}

variable "data_ingestion_dataflow_deployer_identities" {
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email} that will deploy Dataflow jobs in the Data Ingestion project. These identities will be added to the VPC-SC secure data exchange egress rules."
  type        = list(string)
  default     = []
}

variable "confidential_data_dataflow_deployer_identities" {
  description = "List of members in the standard GCP form: user:{email}, serviceAccount:{email} that will deploy Dataflow jobs in the Confidential Data project. These identities will be added to the VPC-SC secure data exchange egress rules."
  type        = list(string)
  default     = []
}

variable "kms_key_protection_level" {
  description = "The protection level to use when creating a key. Possible values: [\"SOFTWARE\", \"HSM\"]"
  type        = string
  default     = "HSM"
}

variable "security_administrator_group" {
  description = "Google Cloud IAM group that administers security configurations in the organization(org policies, KMS, VPC service perimeter)."
  type        = string
}

variable "network_administrator_group" {
  description = "Google Cloud IAM group that reviews network configuration. Typically, this includes members of the networking team."
  type        = string
}

variable "security_analyst_group" {
  description = "Google Cloud IAM group that monitors and responds to security incidents."
  type        = string
}

variable "data_analyst_group" {
  description = "Google Cloud IAM group that analyzes the data in the warehouse."
  type        = string
}

variable "data_engineer_group" {
  description = "Google Cloud IAM group that sets up and maintains the data pipeline and warehouse."
  type        = string
}

variable "data_ingestion_egress_policies" {
  description = "A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) for the Data Ingestion perimeter, each list object has a `from` and `to` value that describes egress_from and egress_to. See also [secure data exchange](https://cloud.google.com/vpc-service-controls/docs/secure-data-exchange#allow_access_to_a_google_cloud_resource_outside_the_perimeter) and the [VPC-SC](https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/blob/v3.1.0/modules/regular_service_perimeter/README.md) module."
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "data_ingestion_ingress_policies" {
  description = "A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress_from and ingress_to.\n\nExample: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)."
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "data_ingestion_access_level_combining_function" {
  description = "How the conditions list should be combined to determine if a request is granted this AccessLevel. If AND is used, each Condition must be satisfied for the AccessLevel to be applied. If OR is used, at least one Condition must be satisfied for the AccessLevel to be applied."
  type        = string
  default     = "AND"
}

variable "data_ingestion_access_level_ip_subnetworks" {
  description = "Condition - A list of CIDR block IP subnetwork specification. May be IPv4 or IPv6. Note that for a CIDR IP address block, the specified IP address portion must be properly truncated (that is, all the host bits must be zero) or the input is considered malformed. For example, \"192.0.2.0/24\" is accepted but \"192.0.2.1/24\" is not. Similarly, for IPv6, \"2001:db8::/32\" is accepted whereas \"2001:db8::1/32\" is not. The originating IP of a request must be in one of the listed subnets in order for this Condition to be true. If empty, all IP addresses are allowed."
  type        = list(string)
  default     = []
}

variable "data_ingestion_access_level_negate" {
  description = "Whether to negate the Condition. If true, the Condition becomes a NAND over its non-empty fields, each field must be false for the Condition overall to be satisfied."
  type        = bool
  default     = false
}

variable "data_ingestion_access_level_require_screen_lock" {
  description = "Condition - Whether or not screenlock is required for the DevicePolicy to be true."
  type        = bool
  default     = false
}

variable "data_ingestion_access_level_require_corp_owned" {
  description = "Condition - Whether the device needs to be corp owned."
  type        = bool
  default     = false
}

variable "data_ingestion_access_level_allowed_encryption_statuses" {
  description = "Condition - A list of allowed encryptions statuses. An empty list allows all statuses."
  type        = list(string)
  default     = []
}

variable "data_ingestion_access_level_allowed_device_management_levels" {
  description = "Condition - A list of allowed device management levels. An empty list allows all management levels."
  type        = list(string)
  default     = []
}

variable "data_ingestion_access_level_minimum_version" {
  description = "The minimum allowed OS version. If not set, any version of this OS satisfies the constraint. Format: \"major.minor.patch\" such as \"10.5.301\", \"9.2.1\"."
  type        = string
  default     = ""
}

variable "data_ingestion_access_level_os_type" {
  description = "The operating system type of the device."
  type        = string
  default     = "OS_UNSPECIFIED"
}

variable "data_ingestion_required_access_levels" {
  description = "Condition - A list of other access levels defined in the same Policy, referenced by resource name. Referencing an AccessLevel which does not exist is an error. All access levels listed must be granted for the Condition to be true."
  type        = list(string)
  default     = []
}

variable "data_ingestion_access_level_regions" {
  description = "Condition - The request must originate from one of the provided countries or regions. Format: A valid ISO 3166-1 alpha-2 code."
  type        = list(string)
  default     = []
}

variable "data_governance_egress_policies" {
  description = "A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) for the Data Governance perimeter, each list object has a `from` and `to` value that describes egress_from and egress_to. See also [secure data exchange](https://cloud.google.com/vpc-service-controls/docs/secure-data-exchange#allow_access_to_a_google_cloud_resource_outside_the_perimeter) and the [VPC-SC](https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/blob/v3.1.0/modules/regular_service_perimeter/README.md) module."
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "data_governance_ingress_policies" {
  description = "A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress_from and ingress_to.\n\nExample: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)."
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}


variable "data_governance_access_level_combining_function" {
  description = "How the conditions list should be combined to determine if a request is granted this AccessLevel. If AND is used, each Condition must be satisfied for the AccessLevel to be applied. If OR is used, at least one Condition must be satisfied for the AccessLevel to be applied."
  type        = string
  default     = "AND"
}

variable "data_governance_access_level_ip_subnetworks" {
  description = "Condition - A list of CIDR block IP subnetwork specification. May be IPv4 or IPv6. Note that for a CIDR IP address block, the specified IP address portion must be properly truncated (that is, all the host bits must be zero) or the input is considered malformed. For example, \"192.0.2.0/24\" is accepted but \"192.0.2.1/24\" is not. Similarly, for IPv6, \"2001:db8::/32\" is accepted whereas \"2001:db8::1/32\" is not. The originating IP of a request must be in one of the listed subnets in order for this Condition to be true. If empty, all IP addresses are allowed."
  type        = list(string)
  default     = []
}

variable "data_governance_access_level_negate" {
  description = "Whether to negate the Condition. If true, the Condition becomes a NAND over its non-empty fields, each field must be false for the Condition overall to be satisfied."
  type        = bool
  default     = false
}

variable "data_governance_access_level_require_screen_lock" {
  description = "Condition - Whether or not screenlock is required for the DevicePolicy to be true."
  type        = bool
  default     = false
}

variable "data_governance_access_level_require_corp_owned" {
  description = "Condition - Whether the device needs to be corp owned."
  type        = bool
  default     = false
}

variable "data_governance_access_level_allowed_encryption_statuses" {
  description = "Condition - A list of allowed encryptions statuses. An empty list allows all statuses."
  type        = list(string)
  default     = []
}

variable "data_governance_access_level_allowed_device_management_levels" {
  description = "Condition - A list of allowed device management levels. An empty list allows all management levels."
  type        = list(string)
  default     = []
}

variable "data_governance_access_level_minimum_version" {
  description = "The minimum allowed OS version. If not set, any version of this OS satisfies the constraint. Format: \"major.minor.patch\" such as \"10.5.301\", \"9.2.1\"."
  type        = string
  default     = ""
}

variable "data_governance_access_level_os_type" {
  description = "The operating system type of the device."
  type        = string
  default     = "OS_UNSPECIFIED"
}

variable "data_governance_required_access_levels" {
  description = "Condition - A list of other access levels defined in the same Policy, referenced by resource name. Referencing an AccessLevel which does not exist is an error. All access levels listed must be granted for the Condition to be true."
  type        = list(string)
  default     = []
}

variable "data_governance_access_level_regions" {
  description = "Condition - The request must originate from one of the provided countries or regions. Format: A valid ISO 3166-1 alpha-2 code."
  type        = list(string)
  default     = []
}


variable "confidential_data_egress_policies" {
  description = "A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) for the Confidential Data perimeter, each list object has a `from` and `to` value that describes egress_from and egress_to. See also [secure data exchange](https://cloud.google.com/vpc-service-controls/docs/secure-data-exchange#allow_access_to_a_google_cloud_resource_outside_the_perimeter) and the [VPC-SC](https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/blob/v3.1.0/modules/regular_service_perimeter/README.md) module."
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "confidential_data_ingress_policies" {
  description = "A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress_from and ingress_to.\n\nExample: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)."
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "confidential_data_access_level_combining_function" {
  description = "How the conditions list should be combined to determine if a request is granted this AccessLevel. If AND is used, each Condition must be satisfied for the AccessLevel to be applied. If OR is used, at least one Condition must be satisfied for the AccessLevel to be applied."
  type        = string
  default     = "AND"
}

variable "confidential_data_access_level_ip_subnetworks" {
  description = "Condition - A list of CIDR block IP subnetwork specification. May be IPv4 or IPv6. Note that for a CIDR IP address block, the specified IP address portion must be properly truncated (that is, all the host bits must be zero) or the input is considered malformed. For example, \"192.0.2.0/24\" is accepted but \"192.0.2.1/24\" is not. Similarly, for IPv6, \"2001:db8::/32\" is accepted whereas \"2001:db8::1/32\" is not. The originating IP of a request must be in one of the listed subnets in order for this Condition to be true. If empty, all IP addresses are allowed."
  type        = list(string)
  default     = []
}

variable "confidential_data_access_level_negate" {
  description = "Whether to negate the Condition. If true, the Condition becomes a NAND over its non-empty fields, each field must be false for the Condition overall to be satisfied."
  type        = bool
  default     = false
}

variable "confidential_data_access_level_require_screen_lock" {
  description = "Condition - Whether or not screenlock is required for the DevicePolicy to be true."
  type        = bool
  default     = false
}

variable "confidential_data_access_level_require_corp_owned" {
  description = "Condition - Whether the device needs to be corp owned."
  type        = bool
  default     = false
}

variable "confidential_data_access_level_allowed_encryption_statuses" {
  description = "Condition - A list of allowed encryptions statuses. An empty list allows all statuses."
  type        = list(string)
  default     = []
}

variable "confidential_data_access_level_allowed_device_management_levels" {
  description = "Condition - A list of allowed device management levels. An empty list allows all management levels."
  type        = list(string)
  default     = []
}

variable "confidential_data_access_level_minimum_version" {
  description = "The minimum allowed OS version. If not set, any version of this OS satisfies the constraint. Format: \"major.minor.patch\" such as \"10.5.301\", \"9.2.1\"."
  type        = string
  default     = ""
}

variable "confidential_data_access_level_os_type" {
  description = "The operating system type of the device."
  type        = string
  default     = "OS_UNSPECIFIED"
}

variable "confidential_data_required_access_levels" {
  description = "Condition - A list of other access levels defined in the same Policy, referenced by resource name. Referencing an AccessLevel which does not exist is an error. All access levels listed must be granted for the Condition to be true."
  type        = list(string)
  default     = []
}

variable "confidential_data_access_level_regions" {
  description = "Condition - The request must originate from one of the provided countries or regions. Format: A valid ISO 3166-1 alpha-2 code."
  type        = list(string)
  default     = []
}


variable "data_ingestion_perimeter" {
  description = "Existing data ingestion perimeter to be used instead of the auto-created perimeter. The service account provided in the variable `terraform_service_account` must be in an access level member list for this perimeter **before** this perimeter can be used in this module."
  type        = string
  default     = ""
}

variable "data_governance_perimeter" {
  description = "Existing data governance perimeter to be used instead of the auto-created perimeter. The service account provided in the variable `terraform_service_account` must be in an access level member list for this perimeter **before** this perimeter can be used in this module."
  type        = string
  default     = ""
}

variable "confidential_data_perimeter" {
  description = "Existing confidential data perimeter to be used instead of the auto-created perimeter. The service account provided in the variable `terraform_service_account` must be in an access level member list for this perimeter **before** this perimeter can be used in this module."
  type        = string
  default     = ""
}

variable "enable_bigquery_read_roles_in_data_ingestion" {
  description = "(Optional) If set to true, it will grant to the dataflow controller service account created in the data ingestion project the necessary roles to read from a bigquery table."
  type        = bool
  default     = false
}
