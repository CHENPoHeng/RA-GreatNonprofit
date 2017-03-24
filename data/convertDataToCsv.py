# import csv
import os
import json
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
    state = file_dir[:-4]
    d = [row.replace('\n','').split('\t') for row in file]
    d = pd.DataFrame(d[1: ], columns = d[0])
    # to combine multiple columns 
    d['description'] = d[d.columns[9:]].apply(lambda x: ' '.join(x), axis=1)
    d['state'] = state
    d = d[['name', 'url', 'telephone', 'tax_num', 'street', 'locality', 'state', 'region', 'postcode', 'country', 'description']]
    org_data = org_data.append(d, ignore_index=True)
    print '%s is done.' % state

org_data['orgData_id'] = org_data.index.values + 1
org_data.to_csv('orgData.csv', index = False)



###### organization reviews
# read in all organization reviews
dir_base = 'orgReview/'
files = os.listdir(dir_base)

org_review = pd.DataFrame()
for file_dir in files:
    # read each file and go through data 
    with open(dir_base + file_dir, 'rb') as tsv:
        file = tsv.readlines()
    state = file_dir[:-4]
    d = [row.replace('\n','').split('\t') for row in file]
    d = pd.DataFrame(d[1: ], columns = d[0])
    d['state'] = state
    org_review = org_review.append(d, ignore_index=True)
    print '%s is done.' % state

org_review['orgReview_id'] = org_review.index.values + 1
org_review.to_csv('orgReview.csv', index = False)

## export as json file to avoid strange case
res = {}
for key, df_gb in org_review.groupby('orgReview_id'):
    res[str(key)] = df_gb.to_dict('records')

with open('orgReview.json', 'w') as writer:
    json.dump(res, writer)
