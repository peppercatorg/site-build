#!/bin/zsh

TEMPDIR=$(mktemp -d)

qsv select catalog,personID everywhere-current.csv |
  qsv dedup |
  qsv select catalog |
  qsv frequency -l 0 |
  qsv select value,count |
  qsv rename country,leaders > $TEMPDIR/1.csv

qsv select catalog,personID everywhere-leaders.csv |
  qsv dedup |
  qsv select catalog |
  qsv frequency -l 0 |
  qsv select value,count |
  qsv rename country,leaders_total > $TEMPDIR/2.csv

qsv search -s end -v . everywhere-legislators.csv |
  qsv select catalog,personID |
  qsv dedup |
  qsv select catalog |
  qsv frequency -l 0 |
  qsv select value,count |
  qsv rename country,legislators > $TEMPDIR/3.csv

qsv select catalog,personID everywhere-legislators.csv |
  qsv dedup |
  qsv select catalog |
  qsv frequency -l 0 |
  qsv select value,count |
  qsv rename country,legislators_total > $TEMPDIR/4.csv

qsv cat rows everywhere-leaders.csv everywhere-legislators.csv |
  qsv select catalog,personID |
  qsv dedup |
  qsv select catalog |
  qsv frequency -l 0 |
  qsv select value,count |
  qsv rename country,unique > $TEMPDIR/5.csv

qsv join --left country repos.csv country $TEMPDIR/1.csv |
  qsv join --left country - country $TEMPDIR/2.csv |
  qsv join --left country - country $TEMPDIR/3.csv |
  qsv join --left country - country $TEMPDIR/4.csv |
  qsv join --left country - country $TEMPDIR/5.csv |
  qsv select slug,leaders,leaders_total,legislators,legislators_total,unique |
  qsv rename country,leaders,leaders_total,legislators,legislators_total,unique |
  qsv sort -s country | sed -e 's/,,/,0,/' -e 's/,,/,0,/' > stats.csv

# Calculate the unique totals across everywhere
leaders=$(qsv select personID everywhere-current.csv | qsv dedup | qsv count)
histlead=$(qsv select personID everywhere-leaders.csv | qsv dedup | qsv count)
curleg=$(qsv search -s end -v . everywhere-legislators.csv | qsv select personID | qsv dedup | qsv count)
histleg=$(qsv select personID everywhere-legislators.csv | qsv dedup | qsv count)
uniqppl=$(qsv cat rows everywhere-leaders.csv everywhere-legislators.csv | qsv select personID | qsv dedup | qsv count)

echo "TOTAL",$leaders,$histlead,$curleg,$histleg,$uniqppl >> stats.csv
