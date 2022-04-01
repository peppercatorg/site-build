#!/bin/zsh

TMPFILE=$(mktemp)

pushd docs/leaders
for d in *; do
  pushd -q $d
  leaders=$(qsv select personID current.csv | qsv dedup | qsv search Q | qsv count)
  histlead=$(qsv select personID leaders-historic.csv | qsv dedup | qsv search Q | qsv count)
  histleg=$(qsv select personID legislators-historic.csv | qsv dedup | qsv search Q | qsv count)
  uniqppl=$((for f in *.csv; do qsv select personID $f; done) | qsv sort | qsv dedup | qsv search Q | qsv count)
  echo $d,$leaders,$histlead,$histleg,$uniqppl | tr -d ' '
  popd -q
done 2>/dev/null | tee $TMPFILE
popd

qsv rename -n "country,leaders,historic,legislators,unique" $TMPFILE | tee stats.csv

leaders=$(qsv cat rows **/current.csv | qsv select personID | qsv dedup | qsv search Q | qsv count)
histlead=$(qsv cat rows **/leaders-historic.csv | qsv select personID | qsv dedup | qsv search Q | qsv count)
histleg=$(qsv cat rows **/legislators-historic.csv | qsv select personID | qsv dedup | qsv search Q | qsv count)
uniqppl=$((for f in everywhere-*s.csv; do; qsv select personID $f; done) | qsv sort | qsv dedup | qsv search Q | qsv count)

echo "TOTAL",$leaders,$histlead,$histleg,$uniqppl | sed -e 's/ //g' >> stats.csv
