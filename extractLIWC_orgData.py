import os
import csv
import numpy as np
import pandas as pd
import func.liwcExtractor as lw

     
##################################
###### orgData LIWC extract ######
##################################
# read in all organization data
d = pd.read_csv('data/orgData.csv')

# create LIWC dictionary
liwcPath = 'dict/LIWC2015_English_new.dic'
liwc = lw.liwcExtractor(liwcPath = 'dict/LIWC2015_English_new.dic')

with open('data/orgData_LIWC.csv', 'w') as w:
    writer = csv.writer(w)
    header = ['orgData_id'] + liwc.getCategoryIndeces()
    writer.writerow(header)
    for i, row in d.iterrows():
        if type(row['description']) is not str: 
            continue
        features = liwc.extractFromDoc(row['description'])
        to_write = [row['orgData_id']] + features
        writer.writerow(to_write)
        print 'Finished %s out of %s' % (row['orgData_id'], d.shape[0])


