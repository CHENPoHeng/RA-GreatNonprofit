import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# 1) Per state: 
# - what is the fraction of charity organizations that reside in a given state 
#   (if there were 1000 orgs in total and 13 of them were in Alabama, 
#   the number of Alabama would be 1.3%)
# - what is the fraction of reviews come from an org in a given state (if there
#   were 1000 reviews in total and 13 of them were from an org in Alabama, 
#   the number of Alabama would be 1.3%)
# - what is the fraction of reviews are of a certain kind in a given state (if 
#   there were 1000 reviews for orgs in Alabama and 13 of them came from 
#   "General Member of the Public" , the number for "General Member of the Public" 
#    for Alabama would be 1.3%) - we would a column per type.
# I think we can have these in table format, having a row per state for each question.

## organization summary
###### fraction of charity in a given state
d = pd.read_csv('data/orgData.csv')
print 'original dimension: %s' % str(d.shape)

# remove duplicate
d = d.drop_duplicates()
print 'after-removal dimension: %s' % str(d.shape)

# count number of organization in a given state
##########################
##### reference: http://stackoverflow.com/questions/10373660/converting-a-pandas-groupby-object-to-dataframe
##########################
num_org = d.groupby(['state']).size()
num_org = pd.DataFrame({'num_org': num_org}).reset_index()
num_org['percent_org'] = num_org['num_org']/(sum(num_org['num_org'])*1.0)

###### fraction of charity in a given state
d = org_review
print 'original dimension: %s' % str(d.shape)

# remove duplicate
d = d.drop_duplicates()
print 'after-removal dimension: %s' % str(d.shape)
num_review = d.groupby('state').size()

###### fraction of reviews given a certain kind in a state
tmp = d.groupby(['state', 'type']).size()
num_review = pd.DataFrame({'num_review': tmp}).reset_index()


# 2) Per org: 
# - how many reviews does an org have? We can create PDF and CDF plots 
#   (x axis: number of reviews, y axis: number of charities that have that many reviews) 
#   in linear and log-scale
# - what fraction of reviews come from a certain kind (e.g.  "General Member of the Public").
#   Again a CDF (x axis: fraction of reviews from  "General Member of the Public", 
#   y-axis: fraction of orgs that have that fraction for that type). We can have a curve per type.
d = org_review
tmp = d.groupby('org').size()
tmp = pd.DataFrame({'num_review': tmp}).reset_index()
tmp = tmp.groupby('num_review').size()
review_pdf = pd.Data

# plot CDF
sorted_data = np.sort(tmp.num_review)
yvals=np.arange(len(sorted_data))/float(len(sorted_data)-1)
plt.plot(sorted_data,yvals)
plt.xlabel('number of reviews')
plt.ylabel('CDF')
plt.show()









# 3) Per user:
# - how many reviews do a user write? We can create PDF and CDF plots (x axis: number of reviews,
#   y axis: number of reviewers that write that many reviews) in linear and log-scale
# - what fraction of reviews written by an individual are in a certain role (e.g. "General Member
#   of the Public") Again a CDF (x axis: fraction of reviews written as a  "General Member of the 
#   Public", y-axis: fraction of users that have written at least that fraction of their reviews in
#   that role). We can have a curve per type again.