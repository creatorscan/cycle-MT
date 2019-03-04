for data in ""; do
	for nmt in gr_ph ph_gr; do
	if [ $nmt == 'gr_ph' ]; then
		src='gr'
		tgt='ph'
		label=A
	else
		src='ph'
		tgt='gr'
		label=B
	fi
	<<"over"
	if [ ! -f save_wsj_dir_nmt/model.small1k$data.wsj-$nmt.bin ]; then
	CUDA_VISIBLE_DEVICES=`/usr/local/bin/free-gpu` python nmt/nmt.py --cuda --mode train --vocab save_wsj_dir_nmt/vocab_$nmt \
		--save_to save_wsj_dir_nmt/model.small1k$data.wsj-$nmt \
		--train_src /export/a08/obask/pytorch-dual-learning/data_wsj/train.small1k$data.$src \
		--train_tgt /export/a08/obask/pytorch-dual-learning/data_wsj/train.small1k$data.$tgt \
	       	--dev_src /export/a08/obask/pytorch-dual-learning/data_wsj/valid.$src \
	       	--dev_tgt /export/a08/obask/pytorch-dual-learning/data_wsj/valid.$tgt \
	       	--test_src /export/a08/obask/pytorch-dual-learning/data_wsj/test.$src \
		--test_tgt /export/a08/obask/pytorch-dual-learning/data_wsj/test.$tgt \
	       	--batch_size 20 &> save_wsj_dir_nmt/model.small1k$data.wsj.test-$nmt.log
	fi
over

	if [ ! -f save_wsj_dir_nmt/model${label}.small1k.wsj-$nmt.test.bleu ]; then
 	CUDA_VISIBLE_DEVICES=`/usr/local/bin/free-gpu` python nmt/nmt.py --mode test --test_src data_wsj/test.$src --test_tgt data_wsj/test.$tgt \
	       	--load_model save_wsj_dir_nmt/model${label}.small1k.wsj-$nmt.bin --save_to_file save_wsj_dir_nmt/model${label}.small1k.wsj-$nmt.test \
		--cuda; perl nmt/scripts/multi-bleu.perl -lc data_wsj/test.$tgt < save_wsj_dir_nmt/model${label}.small1k.wsj-$nmt.test &> save_wsj_dir_nmt/model${label}.small1k.wsj-$nmt.test.bleu
	fi
	done
done
