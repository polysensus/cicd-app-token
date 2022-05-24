#!/bin/bash

echo $INPUT_APP_PEM > pem.b64.txt
python /app/authtoken.py
