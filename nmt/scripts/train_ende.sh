#!/bin/sh

data_dir="/export/a08/obask/pytorch-dual-learning/nmt"
vocab_bin="$data_dir/vocab_ende"
data_dir="/export/a08/obask/fairseq/examples/adi_MT/data/tiny"
train_src="$data_dir/train.en"
train_tgt="$data_dir/train.de"
dev_src="$data_dir/valid.en"
dev_tgt="$data_dir/valid.de"
test_src="$data_dir/test.en"
test_tgt="$data_dir/test.de"

job_name="wmt16-ende"
model_name="model.${job_name}"

CUDA_VISIBLE_DEVICES=`/usr/local/bin/free-gpu`  python nmt.py \
    --cuda \
    --mode train \
    --vocab ${vocab_bin} \
    --save_to ${model_name} \
    --log_every 100 \
    --valid_niter 5000 \
    --valid_metric ppl \
    --save_model_after 1 \
    --beam_size 5 \
    --batch_size 64 \
    --hidden_size 256 \
    --embed_size 256 \
    --uniform_init 0.1 \
    --dropout 0.2 \
    --clip_grad 5.0 \
    --lr_decay 0.5 \
    --train_src ${train_src} \
    --train_tgt ${train_tgt} \
    --dev_src ${dev_src} \
    --dev_tgt ${dev_tgt} \
    --load_model "$1"

