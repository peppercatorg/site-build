#!/bin/bash

repo=$1; shift
slug=$1; shift
name=$*

dir="leaders/$slug"
csv="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/current.csv"
html="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/index.html"

echo $name
mkdir -p $dir
cd $dir
  curl -L -O $csv
  curl -L -O $html
cd ~
