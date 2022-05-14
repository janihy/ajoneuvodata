# syntax=docker/dockerfile:1
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
RUN apt-get update && apt-get install -y \
  sqlite3 \
  unzip \
  wget \
  && rm -rf /var/lib/apt/lists/*

RUN wget https://opendata.traficom.fi/Content/Ajoneuvorekisteri.zip
RUN unzip Ajoneuvorekisteri.zip && rm Ajoneuvorekisteri.zip
COPY import.sql import.sql
RUN sqlite3 ajoneuvodata.sqlite < import.sql && rm TieliikenneAvoinData_5_16.csv

COPY . .

EXPOSE 8000
CMD [ "gunicorn", "-w" , "2", "-b", "0.0.0.0:8000", "ajoneuvodata:app"]
