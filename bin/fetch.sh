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
# as this is CSV data, which could have spaces and commas in placenames, it's
# easiest to just extract them one by one.
name=$(echo ${match[0]} | qsv select 2)
slug=$(echo ${match[0]} | qsv select 3)
repo=$(echo ${match[0]} | qsv select 4)
srce=$(echo ${match[0]} | qsv select 5)

dir="docs/leaders/$slug"
csv="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/current.csv"
csv21="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/holders21.csv"
csvmp="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/legislators.csv"
rca="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/family.csv"
bio="https://raw.githubusercontent.com/every-politician-scrapers/$repo/main/html/bio.csv"

echo $name
mkdir -p $dir

curl -L -o $dir/bio.csv $bio

curl -L -o $TMPFILE $csv
qsv search -s repo "^$repo$" repos.csv |
  qsv select country |
  qsv rename catalog |
  qsv cat -p columns $TMPFILE - |
  qsv join personID - id $dir/bio.csv |
  qsv select catalog,position,person,personID,start,gender,dob,dod,image,enwiki |
  qsv rename catalog,position,person,personID,start,gender,DOB,DOD,image,enwiki |
  qsv fill catalog |
  ifne tee $dir/current.csv

# These next two also have an 'end' column
# TODO: also have that in `current.csv`
curl -L -o $TMPFILE $csv21
qsv search -s repo "^$repo$" repos.csv |
  qsv select country |
  qsv rename catalog |
  qsv cat -p columns $TMPFILE - |
  qsv join personID - id $dir/bio.csv |
  qsv select catalog,position,person,personID,start,end,gender,dob,dod,image,enwiki |
  qsv rename catalog,position,person,personID,start,end,gender,DOB,DOD,image,enwiki |
  qsv fill catalog |
  ifne tee $dir/leaders-historic.csv

curl -L -o $TMPFILE $csvmp
qsv search -s repo "^$repo$" repos.csv |
  qsv select country |
  qsv rename catalog |
  qsv cat -p columns $TMPFILE - |
  qsv join personID - id $dir/bio.csv |
  qsv select catalog,position,person,personID,start,end,gender,dob,dod,image,enwiki |
  qsv rename catalog,position,person,personID,start,end,gender,DOB,DOD,image,enwiki |
  qsv fill catalog |
  ifne tee $dir/legislators-historic.csv

curl -L -o $TMPFILE $rca
qsv search -s repo "^$repo$" repos.csv |
  qsv select country |
  qsv rename catalog |
  qsv cat -p columns $TMPFILE - |
  qsv select 6,1-5 |
  qsv fill catalog |
  ifne tee $dir/relatives.csv

erb country="$name" countrydir=$dir src=$srce -r csv -T- template/index.erb > $dir/index.html

qsv cat rows docs/leaders/**/current.csv > everywhere-current.csv
qsv cat rows docs/leaders/**/leaders-historic.csv > everywhere-leaders.csv
qsv cat rows docs/leaders/**/legislators-historic.csv > everywhere-legislators.csv
qsv cat rows docs/leaders/**/relatives.csv | qsv search -s relative Q > everywhere-rca.csv
