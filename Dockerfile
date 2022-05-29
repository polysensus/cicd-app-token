FROM python:3.10-slim

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        unzip \
        jq

COPY requirements.txt app/
RUN pip3 install -r app/requirements.txt

COPY accesstoken.sh app/
COPY actionauth.sh app/
RUN    chmod u+x app/actionauth.sh \
    && chmod u+x app/actionauth.sh

CMD /app/actionauth.sh
