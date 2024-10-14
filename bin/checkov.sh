#!/bin/bash

set -xe

pipenv run checkov --hard-fail-on 1 --directory infra
