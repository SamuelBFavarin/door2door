#!/bin/bash

# CREATE & ACTIVE VIRTUAL ENV
echo "Prepare env"
python3 -m venv env
source env/bin/activate 

# INSTALL REQUIRED LIBS
pip install -r requirements.txt

# DEFINE ENV VARS
export GOOGLE_APPLICATION_CREDENTIALS="/Users/samuel/Documents/GitHub/door2door/credentials/door2door-381302-68f36cb5370c.json"
export BUCKET_NAME="door2door_api_events"
export FILE_NAME_SUFIX="-events.json"
export DATASET_NAME="bronze"
export TABLE_NAME="api_events"
export PROJECT_ID="door2door-381302"

# RUN PYTHON SCRIPT
echo "Running Ingestions"
python main.py

echo "Deactive ENV"
deactivate
