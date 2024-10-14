#!/bin/bash

set -xe

# Check common security issues
pipenv run bandit -r devsecopspy
