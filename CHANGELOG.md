# Changelog

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).
This changelog is generated automatically based on [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## [1.0.0](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/compare/v0.2.0...v1.0.0) (2025-12-11)


### ⚠ BREAKING CHANGES

* updates vpc-sc configuration ([#334](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/334))
* bumps providers and modules versions ([#330](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/330))
* bumps dev-tools image, fixes linting error ([#319](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/319))

### Features

* add audit log to the centralized-logging module ([#274](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/274)) ([987aaf3](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/987aaf34ae899edde82b7854530519ea9231e519))
* Add support to use labels in Data Warehouse ([#282](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/282)) ([a9edac1](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/a9edac12d910f4c65dbd5127c3139f67f2409b39))
* Adding integration tests for the Standalone example ([#298](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/298)) ([9badb1c](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/9badb1cd330cf4b36fed131af738f9e915c36ff5))
* adding service_account_key_creation_policy in main module ([#294](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/294)) ([3e3c90e](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/3e3c90e759a4bd912d9df22c12581e98861b0a6c))
* Allow providing custom project names in the creation of projects in the standalone harness ([#329](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/329)) ([78749af](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/78749afabf1fa0adc70c42673f5083af5ec2902a))
* Create a new example where user can create new projects or use its own with enhanced org policies ([#284](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/284)) ([37e0b3e](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/37e0b3e682c0d535d6e5747bbfbf8750025c9e48))
* Improve outputs for standalone example ([#290](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/290)) ([844d02f](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/844d02f11f52e9b87ac6c81e722b75a5137f38ff))
* make sdx_project_number optional ([#288](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/288)) ([467fab2](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/467fab2e9696f4f5415ad6fb3fd9389ca62ddea1))
* Python standalone example ([#264](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/264)) ([4fc7497](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/4fc749794d71bb7756d8c2d71e40f677ae75a703))
* set audit log config at project level ([#286](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/286)) ([1a461d8](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/1a461d8deac6bc2f090852fb1a81b9079b59e675))


### Bug Fixes

* add a validator to bucket name variables ([#279](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/279)) ([588df9a](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/588df9a14ed6ad804188b4553296e648dfdcbbeb))
* adds support to label, to use services accounts created in main module ([#336](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/336)) ([4f28981](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/4f2898131ab0c21c86d441190da1d08d605953f8))
* **deps:** update terraform null to v3.2.1 ([#339](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/339)) ([1982a0c](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/1982a0c7f8ec376876ccf551327e348604d92f5e))
* **deps:** update terraform random to v3.5.1 ([#347](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/347)) ([41d7da0](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/41d7da0d435af08d550e2709ec8f662320c09a6d))
* **deps:** update tf modules ([#350](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/350)) ([8b89911](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/8b899113400b8b6f996dc889cedb71a9ca93cb8a))
* list resources created by main module. ([#373](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/373)) ([d165499](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/d165499e49a39ba21f1bb124a1307f12d2c34d8e))
* set retention cycle logging bucket ([#299](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/299)) ([6b32180](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/6b321805cf3dc4c52da23a8e32f060bf9c23f4e0))
* waits iam policies propagates before submit builds ([#320](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/320)) ([67aa9e4](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/67aa9e4ae4bef4feb24a1c875092380db8ab620b))


### Miscellaneous Chores

* bumps dev-tools image, fixes linting error ([#319](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/319)) ([6e980df](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/6e980dfc594780147bf856cc6a5c54ca44bbc3a7))
* bumps providers and modules versions ([#330](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/330)) ([4358c29](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/4358c2954d9bea9709d99aaec0c5cd9c92a1f79e))
* updates vpc-sc configuration ([#334](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/334)) ([b64b2ea](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/b64b2eae502f4ff1a2bef3f706d1b1ef05a62d10))

## [0.2.0](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/compare/v0.1.0...v0.2.0) (2022-02-23)


### Features

* Make Python Flex template bq-to-bq de-identify and re-identify data ([#257](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/257)) ([29079d6](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/29079d6940a70db1fb5635b974ec8cb610f50a9c))


### Bug Fixes

* pin the version of the bridge_service_perimeter ([#268](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/268)) ([af9a522](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/af9a522f2e5e4cf0fcec469269aaf4ef315c0e40))
* Python dataflow fixes for CMEK in streaming engine, network tags and user defined experiments ([#261](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/261)) ([77be7ef](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/77be7ef31ff043c70e82c9eea83b2578bfdde54c))
* Set key helper key length to 32 bytes ([#253](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/253)) ([06b21ab](https://github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/06b21ab98afdaadad4e679cd98066c1b33630160))

## [0.1.0](https://github.com/terraform-google-modules/terraform-google-secured-data-warehouse/releases/tag/v0.1.0) (2021-12-22)


### Features

* Add an output value denoting the type of the blueprint ([#184](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/184)) ([e5fec3e](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/e5fec3ecf01f7f326db1af97175774a3d6681842))
* add cmek into reidentification ([#137](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/137)) ([e1c0c0c](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/e1c0c0c182e1007fcae5c1d96dd45738021afc44))
* Add predefined security groups ([#185](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/185)) ([d643faf](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/d643faf59e4c93a8efd9f071b8aee814447260b8))
* add root main module ([#80](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/80)) ([5703861](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/570386169ac1826f86f2482ba27082b447027ffa))
* Add troubleshooting ([#208](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/208)) ([66ed0a0](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/66ed0a070bba392ef2e433535ee61cce33e60c9e))
* Added ignore resources in the ignore_changes of the perimeter creation ([#198](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/198)) ([249f87d](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/249f87d197c9e598b9ab6b31dbb75a90015f4d57))
* Added simple example in the test ([#87](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/87)) ([2175631](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/2175631b107d035492c0ed7c2a35d25de9deae3d))
* Adds policies and step for terraform-validator in build ([#170](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/170)) ([1ddf387](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/1ddf387886005b46e8b0fb4b4cdde69f3a3292a5))
* Adds variables for data governance project and bigquery project ([#124](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/124)) ([e68e760](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/e68e76034652a612bdb1df8e98d07b507b89debe))
* Adds variables to receive data ingestion bucket, location for dataflow bucket ([#77](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/77)) ([ff60f2a](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/ff60f2a3de0067b300a0bfe7c8dfce5041136b98))
* allow reuse of VPC-SC perimeters ([#203](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/203)) ([c68c0c4](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/c68c0c4dc0dfbe7934ca39c4746ca6f0059634a2))
* Allow users to configure egress policies for all the VPC-SC perimeters ([#189](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/189)) ([63c70c9](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/63c70c93832a3b00f5536244d6f06086895d7b02))
* create dataflow flex template module ([#168](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/168)) ([c0398be](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/c0398befe4fe4df9ee2fef64f61322de2e4a7054))
* Initial data governance (DLP) module ([#11](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/11)) ([eaaf957](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/eaaf9576006f1521f95d6ebc6105e27222501414))
* org policy module ([#52](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/52)) ([16f6795](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/16f679547c4422f57c33edfaedbf7d459fb8ae15))
* re-id dataflow with dlp ([#123](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/123)) ([1b81324](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/1b8132417d8ba8b7add357cf80a00641d77bee4d))


### Bug Fixes

* add an Organization Policy that prevents VM instances with public IPs ([#245](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/245)) ([5f1d3ad](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/5f1d3adca586e26e4cf3f4d3683c77e20e6ec46e))
* add new services to the perimeter ([#187](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/187)) ([d81914e](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/d81914ef0e63be00ad8a0c0943f88a80f4069efc))
* add storage class for bucket creation ([#66](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/66)) ([b51a8e6](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/b51a8e669a83f225fea18652b5bba90ff776c6e2))
* add VPC Service Controls and Access Context Manager outputs in the simple example ([#231](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/231)) ([48c1270](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/48c1270c8fc820fba40b0013b3ab57e82e7a80b0))
* Added a random suffix in the keyring creation ([#201](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/201)) ([2d6496d](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/2d6496d9845544385b541015b7dda1efeaac77b3))
* Adds variable for members policy ([#75](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/75)) ([1a7d394](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/1a7d39494c1ef98c37a10a7ea9a4ea6f8a04f2fb))
* Adds variable for receive region in pub/sub ([#78](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/78)) ([53dfe3d](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/53dfe3d40eb1255b1904b767b1214d148d0917d7))
* change default expiration value for dataset to null ([#157](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/157)) ([02f87d4](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/02f87d455f34f172593c8280398da4cfc76c2aea))
* Change the bytes size of the wrapped_key ([#248](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/248)) ([cfb61bc](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/cfb61bc2ad5cb60291d7a9025021bcbbe781b48e))
* changing storage and pub/sub privileges to resource only ([#91](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/91)) ([40a82cc](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/40a82cc1959c70fae0678d63275c2cc0894ae6f2))
* check if the blueprint_type has a valid semver ([#250](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/250)) ([6155964](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/6155964c849921358a2b3d81f4ed4e703c89cdde))
* create access_context_manager_access_policy only once if it does not exist ([#206](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/206)) ([b8b48be](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/b8b48be89571673c20350edf5657741a9b4142dd))
* Dataflow flex job module readme review ([#222](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/222)) ([914cdfc](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/914cdfcfe86e4484268a343f2bee0b8f8736e815))
* fix the description of example variables and outputs ([#251](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/251)) ([7cc1098](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/7cc1098348f7831c52bb77f62ded82459fc4c741))
* hardcode blueprint type ([#252](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/252)) ([e9921f9](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/e9921f9e1314e1d0362697768eee41a2762c5122))
* Pin major version for vpc-sc module ([#27](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/27)) ([fb859f1](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/fb859f13bd38e8cbf7769e1b473e01191a76bbd0))
* Readme edits for secured data warehouse ([#30](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/30)) ([7b0924f](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/7b0924f5f760815db0ff6b6a3db16d2350018ffe))
* readme of de identification ([#237](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/237)) ([af0b7a7](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/af0b7a7968766f186cd92ed8ba7be4b821a452a2))
* Regional DLP readme review ([#216](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/216)) ([6a1ba40](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/6a1ba403fdbeac4aea1cac33460997ba8d445d7e))
* remove labels from buckets and bq datasets ([#233](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/233)) ([574add6](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/574add6adcb4f5b47a98002f5db6f3d0d68e0ac2))
* Remove the explicit depends on with kms module ([#92](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/92)) ([aa05de0](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/aa05de01e6b172c57a58f7852eb9f36c883518cf))
* rename variables to privilege project ([#130](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/130)) ([f2087fc](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/f2087fc4fa4e09edfdc9f62f7bc8938d0ac68ff3))
* Swap from custom service account module to upstream module ([#50](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/50)) ([92972f8](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/92972f84433a0f4f61fddc3ecf0e15efbb012727))
* transform 1-data-ingestion into  module base-data-ingestion ([#72](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/72)) ([a6e0af0](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/a6e0af05cc1c36542197488bfa2bf6329cd4eb2b))
* trim main module outputs ([#174](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/174)) ([1abe7c1](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/1abe7c1ef4f1659960f20b519f2a79d669daa904))
* update location and region handling to allow deploy outside of the US  ([#226](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/226)) ([16eaff7](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/16eaff7e2f7209b2cc0ec62a60ea4856703ea68c))
* update pattern name of resources ([#151](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/151)) ([98d9d2e](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/98d9d2e7dc64c793bb2c9feabc8117b4ca9b6268))
* Use service account impersonation in command line calls to cloud build ([#197](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/issues/197)) ([e6c4a57](https://www.github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse/commit/e6c4a5796ef039c3cacaa1608d065dc60b77680a))


[0.1.0]: https://github.com/terraform-google-modules/terraform-google-secured-data-warehouse/releases/tag/v0.1.0
