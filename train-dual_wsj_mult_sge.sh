#!/bin/bash
. cmd.sh

set -e

nmtdir=/export/a08/obask/pytorch-dual-learning/nmt
lmdir=/export/a08/obask/examples/word_language_model
srcdir=/export/a08/obask/pytorch-dual-learning/data_mult_wsj
lmdict=/export/a08/obask/pytorch-dual-learning/data_mult_wsj
nmtA=$nmtdir/model.wmt16-ende.bin
nmtB=$nmtdir/model.wmt16-deen.bin
lmA=$lmdir/model_en
lmB=$lmdir/model_de
lmA_dict=${lmdict}/data_en/dict_en_new.pkl
lmB_dict=${lmdict}/data_de/dict_de_new.pkl
srcA=$srcdir/train_unpaired.mult
srcB=$srcdir/train_unpaired.gr
dir=save_wsj_dir_mult
saveA="${dir}_nmt/modelA.mult.small.wsj"
saveB="${dir}_nmt/modelB.mult.small.wsj"

# build language models
mkdir -p ${dir}_lm
# prepare data for each lang
for lang in mult gr; do
	mkdir -p ${dir}_lm/data_$lang
	if [ ! -s ${dir}_lm/data_$lang/dict_$lang.pkl ]; then python dict_gen.py --data $lmdict/data_$lang/ --out ${dir}_lm/data_$lang/dict_$lang.pkl; fi
	if [ ! -s ${dir}_lm/model_$lang.pt ]; then 
		CUDA_VISIBLE_DEVICES=`/usr/local/bin/free-gpu` python lm/main.py --cuda --dropout 0.65 \
		--tied --nlayers 2 \
		--data $lmdict/data_$lang \
		--save ${dir}_lm/model_$lang.pt &> ${dir}_lm/log_$lang
	fi
done
lmA_dict=${dir}_lm/data_mult/dict_mult.pkl
lmB_dict=${dir}_lm/data_gr/dict_gr.pkl

# built nmt models
# prepare vocab_binary
mkdir -p ${dir}_nmt
for nmt in mult_gr gr_mult; do
	if [ $nmt == 'mult_gr' ]; then
		src='mult'
		tgt='gr'
	else
		src='gr'
		tgt='mult'
	fi

	if [ ! -s ${dir}_nmt/vocab_$nmt ]; then python nmt/vocab.py --train_src $lmdict/data_$src/train.txt --train_tgt $lmdict/data_$tgt/train.txt --output ${dir}_nmt/vocab_$nmt; fi

	if [ ! -s ${dir}_nmt/model.mult.small.wsj-${nmt}.bin ]; then
	echo "python nmt/nmt.py --cuda --mode train \
		--vocab ${dir}_nmt/vocab_$nmt \
		--save_to ${dir}_nmt/model.mult.small.wsj-$nmt --train_src $srcdir/train.$src \
		--train_tgt $srcdir/train.$tgt \
		--dev_src $srcdir/valid.$src \
		--dev_tgt $srcdir/valid.$tgt \
		--test_src $srcdir/test.$src \
		--test_tgt $srcdir/test.$tgt" > ${dir}_nmt/$nmt.sge
	chmod +x ${dir}_nmt/$nmt.sge
	$cuda_cmd ${dir}_nmt/$nmt.log ${dir}_nmt/$nmt.sge 
	fi
done

nmtA=${dir}_nmt/model.mult.small.wsj-mult_gr.bin
nmtB=${dir}_nmt/model.mult.small.wsj-gr_mult.bin
lmA=${dir}_lm/model_mult.pt
lmB=${dir}_lm/model_gr.pt

if [ ! -s $saveA ]; then
echo "python dual.py \
    --nmt $nmtA $nmtB \
    --lm $lmA $lmB \
    --dict $lmA_dict $lmB_dict \
    --src $srcA $srcB \
    --log_every 5 \
    --save_n_iter 400 \
    --alpha 0.01 \
    --model $saveA $saveB" > ${dir}_nmt/dual_mult.sge
chmod +x ${dir}_nmt/dual_mult.sge
$cuda_cmd  ${dir}_nmt/dual_mult.log ${dir}_nmt/dual_mult.sge
fi
