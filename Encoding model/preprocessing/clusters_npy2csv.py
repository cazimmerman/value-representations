# coding: utf-8
import numpy as np
import sys

def convert_file(filename, path):
	clusters = np.load(path + filename, allow_pickle=True)
	with open(path.replace('Z:\\Alex', 'Z:\\Chris\\data\\ibl_da_neuropixels') + filename.replace('npy', 'csv'), 'w') as f:
    		for ii in range(len(clusters)):
        		f.write(clusters[ii] + '\n')

if __name__ == '__main__':
	path = sys.argv[1]
	filename = 'channels.locations.npy'
	convert_file(filename, path)
