#!/bin/bash

echo $INPT_APP_PEM | base64 -d > pem.txt
python /app/authtoken.py pem.txt
