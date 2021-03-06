#!/usr/bin/env python3

import argparse,time

parser = argparse.ArgumentParser()
parser.add_argument("--hlatype_files", default="${hlatype_files}", help="Comma separated list of hlatypes")
parser.add_argument("--hlatypes_out", default="${hlatypes_out}", help="")

args = parser.parse_args()

def combine_hlatype(hlatype_files, hlatypes_out):
    """
    """
    hlatype_files = hlatype_files.split(',')
    outfile = open(hlatypes_out, 'w')
    zeros = ['0'] * 10
    for hla_file in hlatype_files:
        nline = 1
        data = []
        sample = hla_file.split('/')[-1].split('_')[0]
        for line in open(hla_file):
            if nline > 1:
                line = line.strip().split('\\t')
                hla = []
                for it in line[1:7]:
                    it = it.replace('*','').replace(':','')[1:]
                    if it == '':
                        it = '0'
                    hla.append(it)
                # hla = [ it.replace('*','').replace(':','')[1:] for it in line[1:7] ]
                data = [ '0', sample, '0', '0', '0', '0' ] + hla + zeros
                outfile.writelines('\\t'.join(data)+'\\n')
            nline += 1
    outfile.close()
    
if __name__ == '__main__':
    combine_hlatype(args.hlatype_files, args.hlatypes_out)