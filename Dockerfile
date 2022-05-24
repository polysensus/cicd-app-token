FROM python:3.6-slim-stretch

COPY requirements.txt app/
COPY authtoken.py app/
COPY entrypoint.sh app/
RUN chmod u+x app/entrypoint.sh \
    && pip3 install -r app/requirements.txt

CMD /app/entrypoint.sh
