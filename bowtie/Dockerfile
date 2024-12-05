FROM python:3.9-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bowtie \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["bowtie2"]

