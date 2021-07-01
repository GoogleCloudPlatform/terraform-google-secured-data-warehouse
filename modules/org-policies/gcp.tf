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
 *
 */

 # Organizational Policies
 #
 # These are the policies define
 # - Resource Location Restriction - constraints/gcp.resourceLocations


 module "location_restriction_policy" {
   source             = "terraform-google-modules/org-policy/google"
   version            = "~> 4.0"
   constraint         = "gcp.resourceLocations"
   policy_for         = "folder"
   folder_id          = local.folder_trusted
   policy_type        = "list"
   allow              = local.locations[*]
   allow_list_length  = 1
 }
