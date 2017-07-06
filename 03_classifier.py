# approach:
# lasso
# x = w beta + lamda beta 1 norm
# 
# sparse representation
# 
# logistic regression + l1 penalty
# random forest + regularization


# data manipulation
import pandas as pd 
import numpy as np
# cv
from sklearn.cross_validation import train_test_split
from sklearn.grid_search import GridSearchCV
# model
from lightning.classification import CDClassifier
from sklearn.linear_model import Lasso




# read in LIWC data
d = pd.read_csv('data/orgReview_LIWC_new.csv')

##########################
#### Classification 1 ####
##########################
# One idea is to maybe pose this as a multi-class classification problem and 
# use liwc features as features to our classifier.  Use regularization 
# (learning the right regularization term in cross validation) and then 
# analyzing the feature weights and their impact in information gain to 
# determine what type of liwc measures are more commonly used by different 
# types of reviews (volunteer, donor etc.)

#####################
### 9 group lasso ###
#####################
# prepare data
y_type = d['type']
X = d.drop(['type', 'rating'], axis = 1)

# split data
X_train, X_test, y_train, y_test = train_test_split(X, y_type, test_size=0.1, random_state=42)

# build model 
# prepare parameters
params = dict(
    alpha = [0.001],
    C = [0.0001]
    )

# create and fit a ridge regression model, testing each alpha
clf = CDClassifier(penalty="l1/l2",
                   loss="log",
                   multiclass=True,
                   max_iter=20,
                   alpha=1e-4,
                   verbose=1,
                   C=1.0,
                   tol=1e-3)

grid = GridSearchCV(estimator=clf, param_grid=params)
grid.fit(X_train, y_train)
print(grid)
# summarize the results of the grid search
print(grid.best_score_)
print(grid.best_estimator_)

bst = grid.best_estimator_
bst.predict(X_test)
bst.score(X_test, y_test)

# Percentage of selected features
print(bst.n_nonzero(percentage=True))

np.savetxt('output/type_9_groups_weights.txt', bst.coef_)

# from sklearn.externals import joblib
# joblib.dump(grid.best_estimator_, 'best_gridSearch.pkl', compress = 1)

#####################
### 4 group lasso ###
#####################
to_compare = ['Volunteer', 'Donor', 'Client Served', 'Board Member']
tmp = d[d.type.isin(to_compare)]

y_type = tmp['type']
X = tmp.drop(['type', 'rating'], axis = 1)

# split data
X_train, X_test, y_train, y_test = train_test_split(X, y_type, test_size=0.1, random_state=42)

# build model 
# prepare parameters
params = dict(
    alpha = [0.001],
    C = [0.0001]
    )

# create and fit a ridge regression model, testing each alpha
clf = CDClassifier(penalty="l1/l2",
                   loss="log",
                   multiclass=True,
                   max_iter=20,
                   alpha=1e-4,
                   verbose=1,
                   C=1.0,
                   tol=1e-3)

grid = GridSearchCV(estimator=clf, param_grid=params)
grid.fit(X_train, y_train)
print(grid)
# summarize the results of the grid search
print(grid.best_score_)
print(grid.best_estimator_)

bst = grid.best_estimator_
bst.predict(X_test)
bst.score(X_test, y_test)

# Percentage of selected features
print(bst.n_nonzero(percentage=True))

######################
### pairwise lasso ###
######################




##########################
#### Classification 2 ####
##########################
# Repeat the same above but this time lasso and dependent variable is rating, 
# we can again get a sense of features that are associated with the most 
# negative or positive reviews

# prepare data
y_rating = d['rating']
X = d.drop(['type', 'rating'], axis = 1)

# split data
X_train, X_test, y_train, y_test = train_test_split(X, y_rating, test_size=0.1, random_state=42)

# prepare parameters
params = dict(
    alpha = [1,0.1,0.01,0.001,0.0001,0],
    C = [1,0.1,0.01,0.001,0.0001]
    )

# model building
clf = CDClassifier(penalty="l1/l2",
                   loss="log",
                   multiclass=True,
                   max_iter=20,
                   alpha=1e-4,
                   verbose=1,
                   C=1.0,
                   tol=1e-3)

grid = GridSearchCV(estimator=clf, param_grid=params)
grid.fit(X_train, y_train)
print(grid)
# summarize the results of the grid search
print(grid.best_score_)
print(grid.best_estimator_)



##########################
#### Classification 3 ####
##########################
# Repeat the lasso analysis but instead of using liwc vectors, use the actual 
# reviews (identify words in all reviews, remove stop words) and identify words
# associated with good and bad reviews. Try different versions, one where you 
# only have the words, another where you have fixed effects for charity type, 
# location and reviewer type (basically adding controls).






##########################
#### Classification 4 ####
##########################
# We want to understand if there is any relationship between matching of 
# reviews and mission statements and review rating. For two texts, lets 
# define their similarity (simplest is cosine similarity with tf-idf). 
# Next compute the similarity between the mission statement and reviews 
# of each charity (if a charity has k reviews, that would mean there will 
# be k rows for this charity). Next plot simlarity vs. rating of the review. 
# What kind of pattern do we see?

# text mining
import nltk
from nltk.corpus import stopwords 
from sklearn.feature_extraction.text import CountVectorizer
# similarity
from sklearn.metrics.pairwise import cosine_similarity
# to plot
import matplotlib.pyplot as plt
# to save
import pickle
################

# read in orgReview data for the reivews 
rvw = pd.read_csv(open('data/orgReview.csv','rU'), encoding='utf-8')
# remove those orgReview_id are empty
rvw = rvw.dropna(subset = ['orgReview_id','review'])
# select what need
rvw = rvw[['org', 'state', 'rating', 'review']]

# read in orgData for the organization mission statement
org = pd.read_csv(open('data/orgData.csv', 'rU'), encoding='utf-8', engine='c')
org = org.dropna(subset = ['description'])
org = org[['name', 'state', 'description', 'orgData_id']]

# create word vector
vectorizer = CountVectorizer(min_df=1, stop_words='english')
rvw_m = vectorizer.fit_transform(rvw['review'])
org_m = vectorizer.transform(org['description'])

# create matching id
rvw_org = pd.merge(rvw, org, how='left', left_on=['org','state'], right_on = ['name','state'])
rvw_org = rvw_org.drop(['name', 'review', 'description'], 1)

# reset index
org = org.reset_index(drop=True)
rvw = rvw.reset_index(drop=True)

# calculate similarity 
cos = []
for i, row in rvw_org.iterrows():
  tmp = org.loc[org['orgData_id'] == row['orgData_id']].index
  cos.append(cosine_similarity(rvw_m[i, ], org_m[tmp, ])[0][0])
  if i % 5000 == 0:
    print '%s out of %s' % (i, len(rvw_org))

# save the similarity result
with open('output/similarity.txt', 'w') as file:
    for i in cos:
      file.write('%s\n' % i)


rating = rvw['rating'].values.astype(int)
# scatter plot for similarity vs. rating
plt.scatter(cos, rating)
plt.title('Correlation Coefficient: %s' % round(np.corrcoef(cos, rating)[1,0], 3))
plt.xlabel('Cosine Similarity')
plt.ylabel('Review\'s Rating (1-5)')
plt.savefig('plot/similarity_rating.png')
