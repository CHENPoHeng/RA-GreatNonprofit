import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
# to create PDF
from scipy.stats import gaussian_kde


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

###### organization summary
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
print 'original dimension: %s' % str(org_review.shape)

# remove duplicate
org_review = org_review.drop_duplicates()
print 'after-removal dimension: %s' % str(org_review.shape)

d = org_review
num_review = d.groupby('state').size()
num_review = pd.DataFrame({'num_review': num_review}).reset_index()
num_review['percent_review'] = num_review['num_review'] / (sum(num_review['num_review']*1.0))

# combine two data frame
state = num_org.join(num_review.set_index('state'), on='state')
# export to csv
state.to_csv('state_summary.csv')

###### fraction of reviews given a certain kind in a state
tmp = d.groupby(['state', 'type']).size()
num_review = pd.DataFrame({'num_review': tmp}).reset_index()
num_review['percent_review'] = num_review['num_review'] / (sum(num_review['num_review']*1.0))
num_review.to_csv('state_kind_summary.csv')


# 2) Per org: 
# - how many reviews does an org have? We can create PDF and CDF plots 
#   (x axis: number of reviews, y axis: number of charities that have that many reviews) 
#   in linear and log-scale
# - what fraction of reviews come from a certain kind (e.g.  "General Member of the Public").
#   Again a CDF (x axis: fraction of reviews from  "General Member of the Public", 
#   y-axis: fraction of orgs that have that fraction for that type). We can have a curve per type.
d = org_review
d = d.groupby('org').size()
d = pd.DataFrame({'num_review': d}).reset_index()
d['num_review_log'] = np.log(d['num_review'])

###### PDF, CDF of review distribution
# plot PDF & CDF ---------- basic 
# set up PDF
d.num_review.plot.density(bw_method=0.25)
ax = plt.gca()
line = ax.lines[0]
x1 = line.get_xdata()
y1 = line.get_ydata()
x2 = np.sort(d.num_review)
y2 = np.arange(len(x2))/float(len(x2)-1)


fig, ax1 = plt.subplots()
ax2 = ax1.twinx()
ax1.plot(x1, y1, 'g-')
ax2.plot(x2, y2, 'b-')
plt.title('Organization Review PDF, CDF (bw=0.25)')
ax1.set_xlabel('number of reviews')
ax1.set_ylabel('PDF', color='g')
ax2.set_ylabel('CDF', color='b')
ax1.set_xlim(-500, 2500)
plt.savefig('plot/PDF_CDF_org_review.png')


# plot PDF & CDF ---------- log scale 
# set up PDF
d.num_review_log.plot.density(bw_method=0.25)
ax = plt.gca()
line = ax.lines[0]
x1 = line.get_xdata()
y1 = line.get_ydata()
x2 = np.sort(d.num_review_log)
y2 = np.arange(len(x2))/float(len(x2)-1)


fig, ax1 = plt.subplots()
ax2 = ax1.twinx()
ax1.plot(x1, y1, 'g-')
ax2.plot(x2, y2, 'b-')
plt.title('Organization Review PDF, CDF (bw=0.25)')
ax1.set_xlabel('number of reviews (log2)')
ax1.set_ylabel('PDF', color='g')
ax2.set_ylabel('CDF', color='b')
# ax1.set_xlim(-500, 2500)
plt.savefig('plot/PDF_CDF_org_review_log.png')

###### PDF, CDF of review distribution given a certain type
d = org_review
# get subset by 'type'
for t in d.type.unique():
    if t == '':
        continue
    tmp = d[d.type == t]
    tmp = tmp.groupby('org').size()
    tmp = pd.DataFrame({'num_review': tmp}).reset_index()
    tmp['num_review_log'] = np.log(tmp['num_review'])
    # plot PDF & CDF ---------- basic 
    # set up PDF
    file_name = 'plot/PDF_CDF_%s_review.png' % t
    title = '%s PDF, CDF (bw=0.25)' % t
    tmp.num_review.plot.density(bw_method=0.25)
    ax = plt.gca()
    line = ax.lines[0]
    x1 = line.get_xdata()
    y1 = line.get_ydata()
    x2 = np.sort(tmp.num_review)
    y2 = np.arange(len(x2))/float(len(x2)-1)
    fig, ax1 = plt.subplots()
    ax2 = ax1.twinx()
    ax1.plot(x1, y1, 'g-')
    ax2.plot(x2, y2, 'b-')
    plt.title(title)
    ax1.set_xlabel('number of reviews')
    ax1.set_ylabel('PDF', color='g')
    ax2.set_ylabel('CDF', color='b')
    ax1.set_xlim(x1[0], x1[-1])
    plt.savefig(file_name)
    plt.show()
    # plot PDF & CDF ---------- log scale 
    # set up PDF
    file_name = 'plot/PDF_CDF_%s_review_log.png' % t
    tmp.num_review_log.plot.density(bw_method=0.25)
    ax = plt.gca()
    line = ax.lines[0]
    x1 = line.get_xdata()
    y1 = line.get_ydata()
    x2 = np.sort(tmp.num_review_log)
    y2 = np.arange(len(x2))/float(len(x2)-1)
    fig, ax1 = plt.subplots()
    ax2 = ax1.twinx()
    ax1.plot(x1, y1, 'g-')
    ax2.plot(x2, y2, 'b-')
    plt.title(title)
    ax1.set_xlabel('number of reviews (log2)')
    ax1.set_ylabel('PDF', color='g')
    ax2.set_ylabel('CDF', color='b')
    # ax1.set_xlim(-500, 2500)
    plt.savefig(file_name)
    plt.show()

# 3) Per user:
# - how many reviews do a user write? We can create PDF and CDF plots (x axis: number of reviews,
#   y axis: number of reviewers that write that many reviews) in linear and log-scale
# - what fraction of reviews written by an individual are in a certain role (e.g. "General Member
#   of the Public") Again a CDF (x axis: fraction of reviews written as a  "General Member of the 
#   Public", y-axis: fraction of users that have written at least that fraction of their reviews in
#   that role). We can have a curve per type again.

tmp = d.groupby('reviewer').size()
tmp = pd.DataFrame({'num_review': tmp}).reset_index()
tmp['num_review_log'] = np.log(tmp['num_review'])
# plot PDF & CDF ---------- basic 
# set up PDF
file_name = 'plot/PDF_CDF_reviewer.png' 
title = 'Reviewer PDF, CDF (bw=0.25)'
tmp.num_review.plot.density(bw_method=0.25)
ax = plt.gca()
line = ax.lines[0]
x1 = line.get_xdata()
y1 = line.get_ydata()
x2 = np.sort(tmp.num_review)
y2 = np.arange(len(x2))/float(len(x2)-1)
fig, ax1 = plt.subplots()
ax2 = ax1.twinx()
ax1.plot(x1, y1, 'g-')
ax2.plot(x2, y2, 'b-')
plt.title(title)
ax1.set_xlabel('number of reviews')
ax1.set_ylabel('PDF', color='g')
ax2.set_ylabel('CDF', color='b')
ax1.set_xlim(np.percentilex1[0], x1[-1])
plt.savefig(file_name)
# plot PDF & CDF ---------- log scale 
# set up PDF
file_name = 'plot/PDF_CDF_reviewer_log.png'
tmp.num_review_log.plot.density(bw_method=0.25)
ax = plt.gca()
line = ax.lines[0]
x1 = line.get_xdata()
y1 = line.get_ydata()
x2 = np.sort(tmp.num_review_log)
y2 = np.arange(len(x2))/float(len(x2)-1)
fig, ax1 = plt.subplots()
ax2 = ax1.twinx()
ax1.plot(x1, y1, 'g-')
ax2.plot(x2, y2, 'b-')
plt.title(title)
ax1.set_xlabel('number of reviews (log2)')
ax1.set_ylabel('PDF', color='g')
ax2.set_ylabel('CDF', color='b')
# ax1.set_xlim(-500, 2500)
plt.savefig(file_name)