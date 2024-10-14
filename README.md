# DevSecOpsPy

How to Implement the DevSecOps Process for a Simple Application and Cloud Resource Manifests: Creating an EC2 Instance and S3 Bucket with a Secure Connection.

## Requirements (for local and not CI/CD)

* Docker >=  27.1.x
* Python >= 3.9.x
* pipenv >= 2024.0.3
* aws-cli >= 2.17.x or AWS credentials set
* Terraform >= 1.5.x

## Contents

* [Architecture](#architecture)
* [Structure](#structure)
* [Describe CI/CD workflow](#describe-cicd-workflow)
* [Run CI/CD workflow](#run-cicd-workflow)
  * [Pull Request](#pull-request)
  * [Manually](#manually)
* [Infrastructure](#infrastructure)
  * [Deploy](#deploy)
  * [Destroy](#destroy)
* [Check and read security scan reports](#check-and-read-security-scan-reports)
  * [How to read](#how-to-read)

## Architecture

## Structure

Here I describe the most important files and folders of the project.

```sh
|-- Dockerfile # Use to build and ship the app
|-- Pipfile # Manage app dependecies
|-- Pipfile.lock # Manage app dependecies
|-- infra # Deploy AWS EC2 and s3 bucket with a secure connection
`-- devsecopspy # Source code of the app
```

## Describe CI/CD workflow

The pipeline or workflow is created and executed by Github Actions, more info [here](https://github.com/features/actions). The workflow consists of multiple steps, and if any one step fails, the entire workflow will fail.There are two workflows, `build.yaml` and `terraform_analysis.yaml`, located in the `.github/workflows` folder. Both workflows are executed simultaneously, allowing for efficient processing and analysis during the CI/CD pipeline.

`build.yaml`

This is used to scan security issues and build the app using Docker. In the workflow we have multiple steps:

* Checkout for the code
* Give a version for the docker image
* Install package dependecies and set virtual environment
* Scan code for security issues with `Bandit`
* Save the results as artifacts in Github Artifacts
* Build container image with Docker
* List the image we built

`terraform_analysis.yaml`

Used to scan Terraform code for security issues and best practices. The workflow contains miltiple steps:

* Checkout for code
* Install Terraform
* Install package dependecies and set virtual environment
* Scan the code for security issues / best practices with `checkov`

Tools I used to build the app and to scan the code:

* `Fast API` - Build the app
* `pipenv` - Managing lib/package dependecies and virtual environment
* `Bandit` - Find common security issues in Python code
* `Docker` - Build container image
* `Terraform` - Deploy and manage cloud resources
* `checkov` - Find security issues and apply best practices for Terraform code

## Run CI/CD workflow

There are two ways to execute the pipeline (workflow):

* Using a Pull Request (PR) opened against the `main` branch
* Manually by clicking the `Run workflow` button

### Pull Request

1. Do the changes on the code locally
2. Create local branch including the changes you made
3. Push the changes
4. Create a Pull Request against the `main` branch
5. You have two options to view the CI/CD results:

    * Click on `Show all checks` located under `All checks have passed` at the bottom of the Pull Request page
    * Click on the `Checks` tab at the top of the Pull Request page

    Regardless of the method you choose to view the workflows, you will see two:

    * `Scan and Build the App` workflow for scanning and building the application
    * `Terraform Analysis` workflow for scanning Terraform code

> [!NOTE]
>
> The CI/CD workflow will be triggered with every commit you push to the Pull Request.

### Manually

1. In your Git repository, navigate to the `Actions` tab located alongside the `Code` tab
2. On the left side, identify either the `Scan and Build the App` or `T`erraform Analysis` workflow and click on it
3. On the opened page, you will see a blue frame that includes the `Run workflow` button
4. Click the gray `Run workflow` button, select the branch you want to execute, and then click the green `Run workflow` button
5. You will see multiple steps of the pipeline; simply follow them to proceed

## Infrastructure

All the files that create cloud resources, in this case, an EC2 instance and an S3 bucket with a secure connection between them are located in the `infra` directory.

### Deploy

Steps to deploy cloud infrastructure:

* Install aws-cli or make sure you have `~/.aws/credentials` set which inlude AWS Secret and Access keys.
* Install Terraform ([Terraform install](https://developer.hashicorp.com/terraform/install), select 1.5.x version)
* Go to `infra` directory
* Run Terraform commands

    ```sh
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```

* Access the instance

    ```sh
    ssh -i keypair.pem ec2-user@[PUBLIC_IP]
    ```

* Copy file to the s3 bucket from the instance

    ```sh
    touch test
    aws s3 cp test s3://devsecopspy/
    ```

* You should be able to see the file `test` in `devsecopspy` bucket

### Destroy

To destroy the entire infrastructure use the command below.

```sh
terraform destroy # and type yes
```

## Check and read security scan reports

Each workflow, `Scan and Build the App` and `Terraform Analysis`, includes a scanning step. The key difference is that the `Scan and Build the App` workflow generates a report and stores it as an asset in GitHub Artifacts and you need to download it, while the `Terraform Analysis` workflow outputs the scan results directly in the CI/CD console.

Some examples are listed down bellow:

* For `Scan and Build the App` workflow you will find the artifacts [here](https://github.com/wmariuss/devsecopspy/actions/runs/11328529444), located down of the page on `Artifacts` section
* For `Terraform Analysis` workflow the results can be found [here](https://github.com/wmariuss/devsecopspy/actions/runs/11328529445/job/31501961777#step:6:1)

### How to read

`Scan and Build the App` workflow

After downloading the artifact containing the results, you will see a section labeled `Test Results` with multiple entries:

* Issue - A high-level description of the identified issue
* Severity - The severity level of the issue
* CWE - The data source related to the issue
* Location - The file and line number where the issue was found
* More - Additional information regarding the identified issue

Let’s consider an example. Suppose I implement a feature in my app that creates a temporary file on the server side using the `os.system()` function. When I run the scan, it will flag this as an issue.

```sh
Test results:
--------------------------------------------------
>> Issue: [B605:start_process_with_a_shell] Starting a process with a shell, possible injection detected, security issue.
   Severity: High   Confidence: High
   CWE: CWE-78 (https://cwe.mitre.org/data/definitions/78.html)
   Location: linuxcmd.py:44:2
   More Info: https://bandit.readthedocs.io/en/1.7.10/plugins/b605_start_process_with_a_shell.html
10
11                      os.system("touch "+file_name)
12

--------------------------------------------------
```

`Terraform Analysis` workflow

For this workflow there not reports file, instead the scan results are directly listed in the CI/CD console. Here we have multiple entries:

* Check - Policy details
* Status - Can be `PASSED` or `FAILED`
* File - The file and line number where the issue was found
* Guide - The fix - buildtime

Let’s consider an example. Terraform code for creating an AWS s3 bucket:

```hcl
# S3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    Name = var.resource_name
  }
}

resource "aws_s3_bucket_logging" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.bucket.id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

The output report is:

```sh
terraform scan results:

Passed checks: 12, Failed checks: 1, Skipped checks: 0

Check: CKV_AWS_93: "Ensure S3 bucket policy does not lockout all but root user. (Prevent lockouts needing root account fixes)"
    PASSED for resource: aws_s3_bucket.bucket
    File: /main.tf:38-44
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-24
Check: CKV_AWS_56: "Ensure S3 bucket has 'restrict_public_buckets' enabled"
    PASSED for resource: aws_s3_bucket_public_access_block.bucket
    File: /main.tf:61-67
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-22
Check: CKV_AWS_55: "Ensure S3 bucket has ignore public ACLs enabled"
    PASSED for resource: aws_s3_bucket_public_access_block.bucket
    File: /main.tf:61-67
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-21
Check: CKV_AWS_54: "Ensure S3 bucket has block public policy enabled"
    PASSED for resource: aws_s3_bucket_public_access_block.bucket
    File: /main.tf:61-67
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-20
Check: CKV_AWS_53: "Ensure S3 bucket has block public ACLS enabled"
    PASSED for resource: aws_s3_bucket_public_access_block.bucket
    File: /main.tf:61-67
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-19
Check: CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
    PASSED for resource: aws_s3_bucket.bucket
    File: /main.tf:38-44
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/s3-13-enable-logging
Check: CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
    PASSED for resource: aws_security_group.allow_ssh
    File: /security_groups.tf:5-36
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-that-security-groups-are-attached-to-ec2-instances-or-elastic-network-interfaces-enis
Check: CKV2_AWS_11: "Ensure VPC flow logging is enabled in all VPCs"
    PASSED for resource: aws_vpc.my_vpc
    File: /network.tf:2-8
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/logging-9-enable-vpc-flow-logging
Check: CKV_AWS_20: "S3 Bucket has an ACL defined which allows public READ access."
    PASSED for resource: aws_s3_bucket.bucket
    File: /main.tf:38-44
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/s3-1-acl-read-permissions-everyone
Check: CKV2_AWS_41: "Ensure an IAM role is attached to EC2 instance"
    PASSED for resource: aws_instance.ec2
    File: /main.tf:8-29
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-iam-policies/ensure-an-iam-role-is-attached-to-ec2-instance
Check: CKV2_AWS_6: "Ensure that S3 bucket has a Public Access block"
    PASSED for resource: aws_s3_bucket.bucket
    File: /main.tf:38-44
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/s3-bucket-should-have-public-access-blocks-defaults-to-false-if-the-public-access-block-is-not-attached
Check: CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
    PASSED for resource: aws_s3_bucket.bucket
    File: /main.tf:38-44
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/s3-16-enable-versioning
Check: CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
    FAILED for resource: aws_s3_bucket.bucket
    File: /main.tf:38-44
    Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-that-s3-buckets-are-encrypted-with-kms-by-default

    38 | resource "aws_s3_bucket" "bucket" {
    39 |   bucket = var.bucket_name
    40 |
    41 |   tags = {
    42 |     Name = var.resource_name
    43 |   }
    44 | }
```

In the scan results, the last check has failed. On the `Guide` entry there is a link that provides more information, including potential fixes.
