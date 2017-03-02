# import csv
import os
import pandas as pd

# read in all organization data
dir_base = 'data/orgData/'
files = os.listdir(dir_base)

org_data = pd.DataFrame()
for file_dir in files:
    # read each file and go through data 
    with open(dir_base + file_dir, 'rb') as tsv:
        file = tsv.readlines()
    d = [row.replace('\n','').split('\t') for row in file]
    d = pd.DataFrame(d[1: ], columns = d[0])
    d = d[['name', 'url', 'telephone', 'tax_num', 'street', 'locality', 'region', 'postcode', 'country']]
    org_data = org_data.append(d, ignore_index=True)

org_data.to_csv('data/orgData.csv', index = False)