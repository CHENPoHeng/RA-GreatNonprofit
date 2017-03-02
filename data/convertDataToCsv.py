# import csv
import os
import pandas as pd

###### organization data
# read in all organization data
dir_base = 'orgData/'
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

org_data.to_csv('orgData.csv', index = False)



###### organization reviews
# read in all organization reviews
dir_base = 'data/orgReview/'
files = os.listdir(dir_base)

org_review = pd.DataFrame()
for file_dir in files:
    # read each file and go through data 
    with open(dir_base + file_dir, 'rb') as tsv:
        file = tsv.readlines()
    d = [row.replace('\n','').split('\t') for row in file]
    d = pd.DataFrame(d[1: ], columns = d[0])
    org_review = org_review.append(d, ignore_index=True)

org_review.to_csv('orgReview.csv', index = False)