#!/bin/zsh

TMPFILE=$(mktemp)

# For each country specified (or all, if none specified), generate the latest counts
pushd docs/leaders
for d in $1*; do
  pushd -q $d
  leaders=$(qsv select personID current.csv | qsv dedup | qsv search Q | qsv count)
  histlead=$(qsv select personID leaders-historic.csv | qsv dedup | qsv search Q | qsv count)
  histleg=$(qsv select personID legislators-historic.csv | qsv dedup | qsv search Q | qsv count)
  uniqppl=$((for f in *.csv; do qsv select personID $f; done) | qsv sort | qsv dedup | qsv search Q | qsv count)
  echo $d,$leaders,$histlead,$histleg,$uniqppl | tr -d ' '
  popd -q
done 2>/dev/null | tee $TMPFILE
popd

# Append the latest counts to the end of the existing ones, and then take the latest of each
qsv rename -n "country,leaders,historic,legislators,unique" $TMPFILE | sponge $TMPFILE
qsv cat rows stats.csv $TMPFILE | qsv search -s country -v TOTAL | qsv dedup -s country | sponge stats.csv

# Recalculate the unique totals across everywhere
leaders=$(qsv cat rows **/current.csv | qsv select personID | qsv dedup | qsv search Q | qsv count)
histlead=$(qsv cat rows **/leaders-historic.csv | qsv select personID | qsv dedup | qsv search Q | qsv count)
histleg=$(qsv cat rows **/legislators-historic.csv | qsv select personID | qsv dedup | qsv search Q | qsv count)
uniqppl=$((for f in everywhere-*s.csv; do; qsv select personID $f; done) | qsv sort | qsv dedup | qsv search Q | qsv count)

echo "TOTAL",$leaders,$histlead,$histleg,$uniqppl | sed -e 's/ //g' >> stats.csv
