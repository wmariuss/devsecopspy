#!/bin/bash

set -xe

# Run devsecopspy init API service
pipenv run uvicorn devsecopspy.main:app --reload --host 0.0.0.0 --port 30350
