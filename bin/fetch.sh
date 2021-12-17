#!/bin/bash

TMPFILE=$(mktemp)
IFS=$'\n'

# This needs to be anchored as some places are full subsets of others,
# e.g. Ireland / Northern Ireland
match=($(qsv search -u -i ^$* repos.csv | qsv behead))
if [[ ${#match[@]} != 1 ]]; then
  echo "No unique match for $1"
  printf '\t%s\n' "${match[@]}"
  exit
fi

# There's almost certainly a better way to pass these as parameters, but
# as this is CSV data, which could have spaces and commas in placeames, it's
# easiest to just extract them one by one.
name=$(echo ${match[0]} | qsv select 1)
slug=$(echo ${match[0]} | qsv select 2)
repo=$(echo ${match[0]} | qsv select 3)
srce=$(echo ${match[0]} | qsv select 4)

dir="docs/leaders/$slug"
csv="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/current.csv"
csv21="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/holders21.csv"
csvmp="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/legislators.csv"
html="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/index.html"

echo $name
mkdir -p $dir

curl -L -o $TMPFILE $csv
qsv search -s repo ^$repo repos.csv |
  qsv select country |
  qsv rename catalog |
  qsv cat -p columns $TMPFILE - |
  qsv select 10,1-9 |
  qsv fill catalog |
  ifne tee $dir/current.csv
curl -L -o $dir/leaders-historic.csv $csv21
curl -L -o $dir/legislators-historic.csv $csvmp
erb country="$name" countrydir=$dir src=$srce -r csv -T- template/index.erb > $dir/index.html

qsv cat rows docs/leaders/**/current.csv > everywhere-current.csv
