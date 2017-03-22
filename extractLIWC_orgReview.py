import os
import csv
import pandas as pd
import func.liwcExtractor as lw

##################################
##### orgReview LIWC extract #####
##################################
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
org_review['orgReview_id'] = org_review.index.values + 1
d = org_review

# create LIWC dictionary
liwcPath = 'dict/LIWC2015_English_new.dic'
liwc = lw.liwcExtractor(liwcPath = 'dict/LIWC2015_English_new.dic')

# manually do multi-processing
r = 4
times = 53000
start = times * r
end =  times * (r+1) + 5
file_range = '%s_%s' % (start, end)

with open('data/orgReview_LIWC_' + file_range + '.csv', 'w') as w:
    writer = csv.writer(w)
    header = ['orgReview_id','reviewer_url'] + liwc.getCategoryIndeces()
    writer.writerow(header)
    for i, row in d[start:end].iterrows():
        features = liwc.extractFromDoc(row['review'])
        to_write = [row['orgReview_id'], row['reviewer_url']] + features
        writer.writerow(to_write)
        print 'Finished %s out of %s' % (row['orgReview_id'], end)
    
