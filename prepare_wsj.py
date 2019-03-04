#!/export/a08/obask/tools/anaconda3/envs/py37/bin/python

import os
import argparse
import re
import codecs
import json
from flashtext import KeywordProcessor

parser = argparse.ArgumentParser(description="Word to phoneme converter")
parser.add_argument('--lexicon', type=str, default='lexicon.txt',
        help='file containining word to phoneme mapping')
parser.add_argument('--text', type=str, default='train.words',
        help='Input word sequence file')
parser.add_argument('--out', type=str, default='train.phones',
        help='Input phoneme sequence file')

args = parser.parse_args()
fmt='utf-8'

def word_in(word, phrase, sp):
        return word in phrase.split(sp)

def replace_all(text, dic):
    for key, val in dic.iteritems():
        print(key)
        print(val)
        text = re.sub(r"\b%s\b" % key, val, text)
    return text

# convert the lexicon to a dictionary
lex = args.lexicon
lex_dict = {}
with codecs.open(lex, 'r', fmt) as lexF:
    for line in lexF:
        words = line.split(' ', 1)
        lex_dict[words[0]] = words[1]
print("Finished converting lexicon to dict")

# replace words in text with phonemes
word_seq = args.text
new_file = []
count = 0

keyword_processor = KeywordProcessor(case_sensitive=True)
keyword_processor.add_keyword('New Delhi', 'NCR region')
new_sentence = keyword_processor.replace_keywords('I love Big Apple and new delhi.')
for key, val in lex_dict.items():
    val = val.split('\n')
    val = val[0]
    keyword_processor.add_keyword(key, val)

out = open(args.out, 'w')
with codecs.open(word_seq, 'rb', fmt) as word_seqF:
    for line in word_seqF:
        print('reading %d' % count)
        for key in lex_dict.keys():
            #if re.search((r'\b%s\b' % key), line):
            #if (r'\b%s\b' % key) in line:
            #if word_in(key, line, ';'):
            if (" %s " % key) in line:
                #print("key %s in line %s" % (key, line))
                line = keyword_processor.replace_keywords(line)
                #line = re.sub(r" %s " % key, r" %s " % val, line)
            #elif "%s " % key in line:
            #    line = re.sub(r"^%s " % key, r"%s " % val, line)
        count += 1
        out.write(''.join(line))
        #new_file.append(line)

#with open(args.out, 'w') as out:
#    json.dump(new_file, out)
