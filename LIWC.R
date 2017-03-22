setwd('~/Documents/umsi/Ceren/greatNonprofits/')
len = length
library(data.table)
library(jsonlite)


###################################
##### orgReview LIWC analysis #####
###################################

## change back to json later
# data = fromJSON('data/orgReview.json')
# 
# tmp = do.call(rbind, data)


data = read.csv('data/orgReview.csv')


## remove those reviewer_url are empty
i = which(is.na(data$orgReview_id))
i = which(data$reviewer_url == '')
if(len(i)) data = data[-i, ]
i = which(data$type == '')
if(len(i)) data = data[-i, ]

d = data
liwc = read.csv('data/orgReview_LIWC.csv', as.is = T)


#################################
##### orgData LIWC analysis #####
#################################
# read in orgData
data = read.csv('data/orgData.csv', as.is = T)
data = data.table(data)

liwc = read.csv('data/orgData_LIWC.csv', as.is = T)
liwc$org_id = liwc$org_id + 1

d[liwc$org_id,]
# create id
d$id = 1:nrow(d)


