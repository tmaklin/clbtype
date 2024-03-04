#!/bin/sh

export PATH=$PATH:bin/

set -euo pipefail

in_filename=$(echo $1 | sed 's/^.*\///g')

tmp_refs=refs_$RANDOM".txt"
tmp_db=$in_filename"_bifrost"

ls -d $1 > $tmp_refs
Bifrost build -t 1 -k 31 -i -d -r $tmp_refs -c -o $tmp_db

res=$in_filename"_db.fasta.search"
bin/BlastFrost -o $in_filename -g $tmp_db".gfa" -f $tmp_db".bfg_colors" -q db/db.fasta  > /dev/null
cat $res | sed 's/|locus.*bactin//g' | sed 's/,$//g' | awk '{ print $2 "\t" $1 "\t" $3 "\t" $4}'
rm $res

rm $tmp_refs
rm $tmp_db".gfa"
rm $tmp_db".bfg_colors"
