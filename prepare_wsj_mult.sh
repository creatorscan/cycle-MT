#!/bin/bash
. cmd.sh
data=$1
wsj=$2

set -e
<<"over"
mkdir -p $wsj/tmp

if [ ! -s $wsj/corpus.phonemes ]; then
if [ ! -s ${wsj}/tmp/file.1 ]; then
       # split -l 10000 -d $data ${wsj}/tmp/file.; fi
       len=`wc -l $data`
       count=0
       for i in $(seq 1 10000 1626991); do
	count=$((count+1))
       	j=$((i+9999))
	echo "$i and $j"
        sed -n "${i},${j}p" $data > $wsj/tmp/file.$count
       done
fi

len=`ls $wsj/tmp/file.* | wc -l`
if [ ! -s $wsj/tmp/out.1 ]; then
 $decode_cmd JOB=1:$len $wsj/tmp/log.JOB prepare_wsj.py --lexicon $wsj/lexicon_tagged_woov.txt --text $wsj/tmp/file.JOB --out $wsj/tmp/out.JOB
fi
if [ ! -s $wsj/corpus.phonemes ]; then
	for num in `seq 0 $len`; do
         num=$((num+1))
         cat $wsj/tmp/out.$num | sed "s|_| |g" >> $wsj/corpus.phonemes
 	done
fi
#awk '{print tolower($0)}' $data | sed "s|[a-z]| & |g;s|;||g;s|  \+| |g" > $wsj/corpus.graphemes

fi

#cp $wsj/corpus.graphemes $wsj/corpus.gr
#cp $wsj/corpus.phonemes $wsj/corpus.ph 
if [ ! -s $wsj/tmp/linenos ]; then
grep -in "[A-Z][A-Z][A-Z]" ${wsj}/corpus.ph | cut -f 1 -d ":" > ${wsj}/tmp/linenos # | awk '{printf $0 ","}'` # | sed "s|$|d|g"
for inp in gr ph; do
python remove_lines.py --line $wsj/tmp/linenos --input $wsj/corpus.$inp --output $wsj/corpus_nooov.$inp  &> $wsj/tmp/log
done
fi
over

for inp in mult gr; do
<<"over"
sed -n '1,100000p' $wsj/corpus_nooov.${inp} > $wsj/train.small.${inp}
sed -n '100001,105000p' $wsj/corpus_nooov.${inp} > $wsj/valid.${inp}
sed -n '105001,110000p' $wsj/corpus_nooov.${inp} > $wsj/test.${inp}
sed -n '110001,1626991p' ${wsj}/corpus_nooov.${inp} > $wsj/train_unpaired.${inp}
sed -n '1,1000p' $wsj/train.small.${inp} > $wsj/train.small1k.${inp}
sed -n '1,10000p' $wsj/train.small.${inp} > $wsj/train.small10k.${inp}
sed -n '1,50000p' $wsj/train.small.${inp} > $wsj/train.small50k.${inp}
over
mkdir -p $wsj/data_${inp}
cp $wsj/train_unpaired.${inp} $wsj/data_${inp}/train.txt
cp $wsj/valid.${inp} $wsj/data_${inp}/valid.txt
cp $wsj/test.${inp} $wsj/data_${inp}/test.txt
done

# cleaning the tmp
# rm -r $wsj/tmp
