# DevSecOpsPy

How to Implement the DevSecOps Process for a Simple Application and Cloud Resource Manifests: Creating an EC2 Instance and S3 Bucket with a Secure Connection.

## Requirements (for local and not CI/CD)

* Docker >=  27.1.x
* Python >= 3.9.x
* pipenv >= 2024.0.3
* aws cli >= 2.17.x
* Terraform >= 1.5.x

## Structure

Here I describe the most important files and folders of the project.

```shell
|-- Dockerfile # Use to build and ship the app
|-- Pipfile # Manage app dependecies
|-- Pipfile.lock # Manage app dependecies
|-- infra # Deploy AWS EC2 and s3 bucket with a secure connection
`-- devsecopspy # Source code of the app
```

## How is implemented

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

Tools I used for the app and for scaning the code:

* `Fast API` for the app
* `pipenv` for managing lib dependecies and virtual environment
* `Bandit` to find common security issues in Python code
* `Docker` for build container image
* `Terraform` for cloud resources management
* `checkov` to find security issues and apply best practices for Terraform code

## Run CI/CD workflow(s)

There are two ways to execute the pipeline (workflow):

* Using a Pull Request (PR) opened against the `main` branch
* Manually by clicking the `Run workflow` button

### Pull Request

1. Do the changes on the code
2. Create local branch including the changes you made
3. Push the changes
4. Create a Pull Request against `main` branch
5. You have two option to see CI/CD checks:

    * Using `All checks have passed` located down of the Pull Request page, click on `Show all checks`
    * Using `Checks` tab located on the begging of the Pull Request page, click on it

    On any way you choose to see the workflows, you will see two:

    * `Scan and Build the app` workflow for scan and build the app
    * `Terraform Analysis` workflow to scan Terraform code

> [!NOTE]
>
> The CI/CD workflow will be triggered with every commit you push to the Pull Request.

### Manually

1. On the git repository you have the code, go to `Actions` tab located on the same line with `Code`
2. On the left side indetify `Scan and Build the app` or `Terraform Analysis` workflow, click on it
3. On the opened page you will see a blue frame and there you will see also `Run workflow` button
4. Press on `Run workflow` button, here select the branch you want to execute for and press on `Run workflow` green button
5. There you will see multiple steps of the pipeline. Just follow them.

## Infrastructure

All the files which create cloud resources: EC2 and s3 bucket with a secure conection are located to `infra` dir.

### Deploy

Steps to deploy infrastructure:

* Install aws cli or make sure you have `~/.aws/credentials` set which inlude AWS Secret and Access keys.
* Install Terraform ([Terraform install](https://developer.hashicorp.com/terraform/install), select 1.5.x)
* Go to `infra` dir
* Run the following commands:

    ```shell
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```

### Destroy

To destroy the entire infrastructure use the command below.

```shell
terraform destroy # type yes
```

## How to see security issues results
