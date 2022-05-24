#!/bin/bash

echo $INPT_APP_PEM > pem.b64.txt
python /app/authtoken.py
