#!/bin/bash

repo=$1; shift
slug=$1; shift
name=$*

dir="docs/leaders/$slug"
csv="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/current.csv"
csv21="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/holders21.csv"
csvmp="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/legislators.csv"
html="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/index.html"

echo $name
mkdir -p $dir

curl -L -o $dir/current.csv $csv
curl -L -o $dir/leaders-historic.csv $csv21
curl -L -o $dir/legislators-historic.csv $csvmp
erb country="$name" countrydir=$dir -r csv -T- template/index.erb > $dir/index.html
