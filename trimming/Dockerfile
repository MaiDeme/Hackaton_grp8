FROM ubuntu:22.04

RUN apt-get update && apt-get install trim_galore \    
    && trim_galore -q 20 --phred33 --length 25 <a venir > \
    && apt-get clean \