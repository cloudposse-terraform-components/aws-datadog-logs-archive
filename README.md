

<!-- markdownlint-disable -->
<a href="https://cpco.io/homepage"><img src="https://github.com/cloudposse-terraform-components/aws-datadog-logs-archive/blob/main/.github/banner.png?raw=true" alt="Project Banner"/></a><br/>
    <p align="right">
<a href="https://github.com/cloudposse-terraform-components/aws-datadog-logs-archive/releases/latest"><img src="https://img.shields.io/github/release/cloudposse-terraform-components/aws-datadog-logs-archive.svg?style=for-the-badge" alt="Latest Release"/></a><a href="https://slack.cloudposse.com"><img src="https://slack.cloudposse.com/for-the-badge.svg" alt="Slack Community"/></a></p>
<!-- markdownlint-restore -->

<!--




  ** DO NOT EDIT THIS FILE
  **
  ** This file was automatically generated by the `cloudposse/build-harness`.
  ** 1) Make all changes to `README.yaml`
  ** 2) Run `make init` (you only need to do this once)
  ** 3) Run`make readme` to rebuild this file.
  **
  ** (We maintain HUNDREDS of open source projects. This is how we maintain our sanity.)
  **





-->

This component is responsible for provisioning Datadog Log Archives. It creates a single log archive pipeline for each
AWS account. If the `catchall` flag is set, it creates a catchall archive within the same S3 bucket.

Each log archive filters for the tag `env:$env` where $env is the environment/account name (ie sbx, prd, tools, etc), as
well as any tags identified in the additional_tags key. The `catchall` archive, as the name implies, filters for '\*'.

A second bucket is created for cloudtrail, and a cloudtrail is configured to monitor the log archive bucket and log
activity to the cloudtrail bucket. To forward these cloudtrail logs to datadog, the cloudtrail bucket's id must be added
to the s3_buckets key for our datadog-lambda-forwarder component.

Both buckets support object lock, with overridable defaults of COMPLIANCE mode with a duration of 7 days.

## Prerequisites

- Datadog integration set up in target environment
  - We rely on the datadog api and app keys added by our datadog integration component

## Issues, Gotchas, Good-to-Knows

### Destroy/reprovision process

Because of the protections for S3 buckets, if we want to destroy/replace our bucket, we need to do so in two passes or
destroy the bucket manually and then use terraform to clean up the rest. If reprovisioning a recently provisioned
bucket, the two-pass process works well. If the bucket has a full day or more of logs, though, deleting it manually
first will avoid terraform timeouts, and then the terraform process can be used to clean up everything else.

#### Two step process to destroy via terraform

- first set `s3_force_destroy` var to true and apply
- next set `enabled` to false and apply or use tf destroy

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component. It's suggested to apply this component to all accounts from
which Datadog receives logs.

```yaml
components:
  terraform:
    datadog-logs-archive:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
  #       additional_query_tags:
  #         - "forwardername:*-dev-datadog-lambda-forwarder-logs"
  #         - "account:123456789012"
```

## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 0.13.0 |
| aws       | >= 2.0    |
| datadog   | >= 3.3.0  |
| local     | >= 1.3    |

## Providers

| Name    | Version  |
| ------- | -------- |
| aws     | >= 2.0   |
| datadog | >= 3.7.0 |
| http    | >= 2.1.0 |

## Modules

| Name                 | Source                              | Version |
| -------------------- | ----------------------------------- | ------- |
| cloudtrail           | cloudposse/cloudtrail/aws           | 0.21.0  |
| cloudtrail_s3_bucket | cloudposse/cloudtrail-s3-bucket/aws | 0.23.1  |
| iam_roles            | ../account-map/modules/iam-roles    | n/a     |
| s3_bucket            | cloudposse/s3-bucket/aws            | 0.46.0  |
| this                 | cloudposse/label/null               | 0.25.0  |

## Resources

| Name                                    | Type        |
| --------------------------------------- | ----------- |
| aws_caller_identity.current             | data source |
| aws_partition.current                   | data source |
| aws_ssm_parameter.datadog_api_key       | data source |
| aws_ssm_parameter.datadog_app_key       | data source |
| aws_ssm_parameter.datadog_aws_role_name | data source |
| aws_ssm_parameter.datadog_external_id   | data source |
| datadog_logs_archive.catchall_archive   | resource    |
| datadog_logs_archive.logs_archive       | resource    |
| http.current_order                      | data source |

## Inputs

| Name                        | Description                                                                                                             | Type     | Default      | Required         |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------- | -------- | ------------ | ---------------- |
| additional_query_tags       | Additional tags to include in query for logs for this archive                                                           | `list`   | []           | no               |
| catchall                    | Set to true to enable a catchall for logs unmatched by any queries. This should only be used in one environment/account | `bool`   | false        | no               |
| datadog_aws_account_id      | The AWS account ID Datadog's integration servers use for all integrations                                               | `string` | 464622532012 | no               |
| enable_glacier_transition   | Enable/disable transition to glacier. Has no effect unless `lifecycle_rules_enabled` set to true                        | `bool`   | true         | no               |
| glacier_transition_days     | Number of days after which to transition objects to glacier storage                                                     | `number` | 365          | no               |
| lifecycle_rules_enabled     | Enable/disable lifecycle management rules for s3 objects                                                                | `bool`   | true         | no               |
| object_lock_days_archive    | Set duration of archive bucket object lock                                                                              | `number` | 7            | yes              |
| object_lock_days_cloudtrail | Set duration of cloudtrail bucket object lock                                                                           | `number` | 7            | yes              |
| object_lock_mode_archive    | Set mode of archive bucket object lock                                                                                  | `string` | COMPLIANCE   | yes              |
| object_lock_mode_cloudtrail | Set mode of cloudtrail bucket object lock                                                                               | `string` | COMPLIANCE   | yes              |
| s3_force_destroy            | Set to true to delete non-empty buckets when `enabled` is set to false                                                  | `bool`   | false        | for destroy only |

## Outputs

| Name                          | Description                                                 |
| ----------------------------- | ----------------------------------------------------------- |
| archive_id                    | The ID of the environment-specific log archive              |
| bucket_arn                    | The ARN of the bucket used for log archive storage          |
| bucket_domain_name            | The FQDN of the bucket used for log archive storage         |
| bucket_id                     | The ID (name) of the bucket used for log archive storage    |
| bucket_region                 | The region of the bucket used for log archive storage       |
| cloudtrail_bucket_arn         | The ARN of the bucket used for cloudtrail log storage       |
| cloudtrail_bucket_domain_name | The FQDN of the bucket used for cloudtrail log storage      |
| cloudtrail_bucket_id          | The ID (name) of the bucket used for cloudtrail log storage |
| catchall_id                   | The ID of the catchall log archive                          |

## References

- [cloudposse/s3-bucket/aws](https://registry.terraform.io/modules/cloudposse/s3-bucket/aws/latest) - Cloud Posse's S3
  component
- [datadog_logs_archive resource]
  (https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/logs_archive) - Datadog's provider
  documentation for the datadog_logs_archive resource


> [!TIP]
> #### 👽 Use Atmos with Terraform
> Cloud Posse uses [`atmos`](https://atmos.tools) to easily orchestrate multiple environments using Terraform. <br/>
> Works with [Github Actions](https://atmos.tools/integrations/github-actions/), [Atlantis](https://atmos.tools/integrations/atlantis), or [Spacelift](https://atmos.tools/integrations/spacelift).
>
> <details>
> <summary><strong>Watch demo of using Atmos with Terraform</strong></summary>
> <img src="https://github.com/cloudposse/atmos/blob/main/docs/demo.gif?raw=true"/><br/>
> <i>Example of running <a href="https://atmos.tools"><code>atmos</code></a> to manage infrastructure from our <a href="https://atmos.tools/quick-start/">Quick Start</a> tutorial.</i>
> </detalis>











## Related Projects

Check out these related projects.

- [Cloud Posse Terraform Modules](https://docs.cloudposse.com/modules/) - Our collection of reusable Terraform modules used by our reference architectures.
- [Atmos](https://atmos.tools) - Atmos is like docker-compose but for your infrastructure


> [!TIP]
> #### Use Terraform Reference Architectures for AWS
>
> Use Cloud Posse's ready-to-go [terraform architecture blueprints](https://cloudposse.com/reference-architecture/) for AWS to get up and running quickly.
>
> ✅ We build it together with your team.<br/>
> ✅ Your team owns everything.<br/>
> ✅ 100% Open Source and backed by fanatical support.<br/>
>
> <a href="https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-datadog-logs-archive&utm_content=commercial_support"><img alt="Request Quote" src="https://img.shields.io/badge/request%20quote-success.svg?style=for-the-badge"/></a>
> <details><summary>📚 <strong>Learn More</strong></summary>
>
> <br/>
>
> Cloud Posse is the leading [**DevOps Accelerator**](https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-datadog-logs-archive&utm_content=commercial_support) for funded startups and enterprises.
>
> *Your team can operate like a pro today.*
>
> Ensure that your team succeeds by using Cloud Posse's proven process and turnkey blueprints. Plus, we stick around until you succeed.
> #### Day-0:  Your Foundation for Success
> - **Reference Architecture.** You'll get everything you need from the ground up built using 100% infrastructure as code.
> - **Deployment Strategy.** Adopt a proven deployment strategy with GitHub Actions, enabling automated, repeatable, and reliable software releases.
> - **Site Reliability Engineering.** Gain total visibility into your applications and services with Datadog, ensuring high availability and performance.
> - **Security Baseline.** Establish a secure environment from the start, with built-in governance, accountability, and comprehensive audit logs, safeguarding your operations.
> - **GitOps.** Empower your team to manage infrastructure changes confidently and efficiently through Pull Requests, leveraging the full power of GitHub Actions.
>
> <a href="https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-datadog-logs-archive&utm_content=commercial_support"><img alt="Request Quote" src="https://img.shields.io/badge/request%20quote-success.svg?style=for-the-badge"/></a>
>
> #### Day-2: Your Operational Mastery
> - **Training.** Equip your team with the knowledge and skills to confidently manage the infrastructure, ensuring long-term success and self-sufficiency.
> - **Support.** Benefit from a seamless communication over Slack with our experts, ensuring you have the support you need, whenever you need it.
> - **Troubleshooting.** Access expert assistance to quickly resolve any operational challenges, minimizing downtime and maintaining business continuity.
> - **Code Reviews.** Enhance your team’s code quality with our expert feedback, fostering continuous improvement and collaboration.
> - **Bug Fixes.** Rely on our team to troubleshoot and resolve any issues, ensuring your systems run smoothly.
> - **Migration Assistance.** Accelerate your migration process with our dedicated support, minimizing disruption and speeding up time-to-value.
> - **Customer Workshops.** Engage with our team in weekly workshops, gaining insights and strategies to continuously improve and innovate.
>
> <a href="https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-datadog-logs-archive&utm_content=commercial_support"><img alt="Request Quote" src="https://img.shields.io/badge/request%20quote-success.svg?style=for-the-badge"/></a>
> </details>

## ✨ Contributing

This project is under active development, and we encourage contributions from our community.



Many thanks to our outstanding contributors:

<a href="https://github.com/cloudposse-terraform-components/aws-datadog-logs-archive/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudposse-terraform-components/aws-datadog-logs-archive&max=24" />
</a>

For 🐛 bug reports & feature requests, please use the [issue tracker](https://github.com/cloudposse-terraform-components/aws-datadog-logs-archive/issues).

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.
 1. Review our [Code of Conduct](https://github.com/cloudposse-terraform-components/aws-datadog-logs-archive/?tab=coc-ov-file#code-of-conduct) and [Contributor Guidelines](https://github.com/cloudposse/.github/blob/main/CONTRIBUTING.md).
 2. **Fork** the repo on GitHub
 3. **Clone** the project to your own machine
 4. **Commit** changes to your own branch
 5. **Push** your work back up to your fork
 6. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!

### 🌎 Slack Community

Join our [Open Source Community](https://cpco.io/slack?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-datadog-logs-archive&utm_content=slack) on Slack. It's **FREE** for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build totally *sweet* infrastructure.

### 📰 Newsletter

Sign up for [our newsletter](https://cpco.io/newsletter?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-datadog-logs-archive&utm_content=newsletter) and join 3,000+ DevOps engineers, CTOs, and founders who get insider access to the latest DevOps trends, so you can always stay in the know.
Dropped straight into your Inbox every week — and usually a 5-minute read.

### 📆 Office Hours <a href="https://cloudposse.com/office-hours?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-datadog-logs-archive&utm_content=office_hours"><img src="https://img.cloudposse.com/fit-in/200x200/https://cloudposse.com/wp-content/uploads/2019/08/Powered-by-Zoom.png" align="right" /></a>

[Join us every Wednesday via Zoom](https://cloudposse.com/office-hours?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-datadog-logs-archive&utm_content=office_hours) for your weekly dose of insider DevOps trends, AWS news and Terraform insights, all sourced from our SweetOps community, plus a _live Q&A_ that you can’t find anywhere else.
It's **FREE** for everyone!
## License

<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge" alt="License"></a>

<details>
<summary>Preamble to the Apache License, Version 2.0</summary>
<br/>
<br/>



```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```
</details>

## Trademarks

All other trademarks referenced herein are the property of their respective owners.


---
Copyright © 2017-2025 [Cloud Posse, LLC](https://cpco.io/copyright)


<a href="https://cloudposse.com/readme/footer/link?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-datadog-logs-archive&utm_content=readme_footer_link"><img alt="README footer" src="https://cloudposse.com/readme/footer/img"/></a>

<img alt="Beacon" width="0" src="https://ga-beacon.cloudposse.com/UA-76589703-4/cloudposse-terraform-components/aws-datadog-logs-archive?pixel&cs=github&cm=readme&an=aws-datadog-logs-archive"/>

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.19 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 2.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | >= 3.19 |
| <a name="provider_http"></a> [http](#provider\_http) | >= 2.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_archive_bucket"></a> [archive\_bucket](#module\_archive\_bucket) | cloudposse/s3-bucket/aws | 3.1.2 |
| <a name="module_bucket_policy"></a> [bucket\_policy](#module\_bucket\_policy) | cloudposse/iam-policy/aws | 1.0.1 |
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | cloudposse/cloudtrail/aws | 0.21.0 |
| <a name="module_cloudtrail_s3_bucket"></a> [cloudtrail\_s3\_bucket](#module\_cloudtrail\_s3\_bucket) | cloudposse/s3-bucket/aws | 3.1.2 |
| <a name="module_datadog_configuration"></a> [datadog\_configuration](#module\_datadog\_configuration) | ../datadog-configuration/modules/datadog_keys | n/a |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [datadog_logs_archive.catchall_archive](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/logs_archive) | resource |
| [datadog_logs_archive.logs_archive](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/logs_archive) | resource |
| [datadog_logs_archive_order.archive_order](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/logs_archive_order) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.datadog_aws_role_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [http_http.current_order](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_query_tags"></a> [additional\_query\_tags](#input\_additional\_query\_tags) | Additional tags to be used in the query for this archive | `list(any)` | `[]` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_catchall_enabled"></a> [catchall\_enabled](#input\_catchall\_enabled) | Set to true to enable a catchall for logs unmatched by any queries. This should only be used in one environment/account | `bool` | `false` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enable_glacier_transition"></a> [enable\_glacier\_transition](#input\_enable\_glacier\_transition) | Enable/disable transition to glacier for log archive bucket. Has no effect unless lifecycle\_rules\_enabled set to true | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_glacier_transition_days"></a> [glacier\_transition\_days](#input\_glacier\_transition\_days) | Number of days after which to transition objects to glacier storage in log archive bucket | `number` | `365` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_lifecycle_rules_enabled"></a> [lifecycle\_rules\_enabled](#input\_lifecycle\_rules\_enabled) | Enable/disable lifecycle management rules for log archive s3 objects | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_object_lock_days_archive"></a> [object\_lock\_days\_archive](#input\_object\_lock\_days\_archive) | Object lock duration for archive buckets in days | `number` | `7` | no |
| <a name="input_object_lock_days_cloudtrail"></a> [object\_lock\_days\_cloudtrail](#input\_object\_lock\_days\_cloudtrail) | Object lock duration for cloudtrail buckets in days | `number` | `7` | no |
| <a name="input_object_lock_mode_archive"></a> [object\_lock\_mode\_archive](#input\_object\_lock\_mode\_archive) | Object lock mode for archive bucket. Possible values are COMPLIANCE or GOVERNANCE | `string` | `"COMPLIANCE"` | no |
| <a name="input_object_lock_mode_cloudtrail"></a> [object\_lock\_mode\_cloudtrail](#input\_object\_lock\_mode\_cloudtrail) | Object lock mode for cloudtrail bucket. Possible values are COMPLIANCE or GOVERNANCE | `string` | `"COMPLIANCE"` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_s3_force_destroy"></a> [s3\_force\_destroy](#input\_s3\_force\_destroy) | Set to true to delete non-empty buckets when enabled is set to false | `bool` | `false` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_archive_id"></a> [archive\_id](#output\_archive\_id) | The ID of the environment-specific log archive |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the bucket used for log archive storage |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The FQDN of the bucket used for log archive storage |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The ID (name) of the bucket used for log archive storage |
| <a name="output_bucket_region"></a> [bucket\_region](#output\_bucket\_region) | The region of the bucket used for log archive storage |
| <a name="output_catchall_id"></a> [catchall\_id](#output\_catchall\_id) | The ID of the catchall log archive |
| <a name="output_cloudtrail_bucket_arn"></a> [cloudtrail\_bucket\_arn](#output\_cloudtrail\_bucket\_arn) | The ARN of the bucket used for access logging via cloudtrail |
| <a name="output_cloudtrail_bucket_domain_name"></a> [cloudtrail\_bucket\_domain\_name](#output\_cloudtrail\_bucket\_domain\_name) | The FQDN of the bucket used for access logging via cloudtrail |
| <a name="output_cloudtrail_bucket_id"></a> [cloudtrail\_bucket\_id](#output\_cloudtrail\_bucket\_id) | The ID (name) of the bucket used for access logging via cloudtrail |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
