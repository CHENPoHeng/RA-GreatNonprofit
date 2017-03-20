import os
import csv
import pandas as pd
import func.liwcExtractor as lw

###################################
##### orgReview LIWC analysis #####
###################################
# read in all organization reviews
dir_base = 'data/orgReview/'
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

# create ID for each organization
d = org_review

# create LIWC dictionary
liwcPath = 'dict/LIWC2015_English_new.dic'
liwc = lw.liwcExtractor(liwcPath = 'dict/LIWC2015_English_new.dic')

with open('data/orgReview_LIWC.csv', 'w') as w:
    writer = csv.writer(w)
    header = ['reviewer_url'] + liwc.getCategoryIndeces()
    writer.writerow(header)
    for i, row in d.iterrows():
        features = liwc.extractFromDoc(row['review'])
        to_write = [row['reviewer_url']] + features
        writer.writerow(to_write)
        print 'Finished %s out of %s' % (i, d.shape[0])
    

     