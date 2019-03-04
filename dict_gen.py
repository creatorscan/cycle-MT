import os
import pickle
import data
import argparse

parser = argparse.ArgumentParser(description='Pytorch data generator')
parser.add_argument('--data', type=str, default='data_en',
        help='location of the data corpus')
parser.add_argument('--out', type=str, default='dict.pkl',
        help='pickle file output path')

args = parser.parse_args()
corpus = data.Corpus(args.data)
ntokens, dicti = corpus.tokenize(os.path.join(args.data, 'train.txt'))

with open(args.out, 'wb') as out:
    pickle.dump(dicti, out)
