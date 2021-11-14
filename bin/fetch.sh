#!/bin/bash

repo=$1; shift
slug=$1; shift
name=$*

dir="site/leaders/$slug"
csv="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/current.csv"
html="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/index.html"

echo $name
mkdir -p $dir

curl -L -o $dir/current.csv $csv
erb country="$name" csvfile=$dir/current.csv -r csv -T- template/index.erb > $dir/index.html
