import pickle
import os
import argparse

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('--input', type=str, help='sum the integers (default: find the max)')
parser.add_argument('--output', type=str, help='sum the integers (default: find the max)')

args = parser.parse_args()
input = args.input
output = args.output

train_batch = open(input, 'r').read()
                    
with open(output, 'wb') as _output:
    pickle.dump(train_batch, _output, pickle.HIGHEST_PROTOCOL)
