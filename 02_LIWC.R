setwd('~/Documents/umsi/Ceren/greatNonprofits/')
len = length
library(dplyr)
library(data.table)
library(caret)
library(glmnet)
# library(jsonlite)


###################################
##### orgReview LIWC analysis #####
###################################

## change back to json later
# data = fromJSON('data/orgReview.json')
# 
# tmp = do.call(rbind, data)

data = read.csv('data/orgReview.csv', as.is = T)
data = data.table(data)

## remove those orgReview_id are empty
i = which(is.na(data$orgReview_id))
if(len(i)) data = data[-i, ]
i = which(data$type == '')
if(len(i)) data = data[-i, ]

# read in liwc data
liwc = read.csv('data/orgReview_LIWC.csv', as.is = T)
liwc = data.table(liwc)
# rename liwc
tmp = strsplit(names(liwc)[3:len(names(liwc))], '\\.\\.')
tmp = data.table(do.call(rbind, tmp))
names(tmp) = c('short', 'full')
tmp$full = substr(tmp$full, 1, nchar(tmp$full)-1)
tmp$full = gsub('\\.', '_', tmp$full)
liwc.title = tmp 
names(liwc) = c(names(liwc)[1:2], liwc.title$short)

# combine these two
d = data
d = merge(d, liwc, by = c('orgReview_id', 'reviewer_url'), all.x = T)
# get only what we really need
i = which(names(d) %in% c('date', 'id', 'org', 'review', 'reviewer', 'orgReview_id',
                          'reviewer_url', 'likes', 'rating', 'state'))
if(len(i)) d = d[, -i, with = F]

# write.csv(d, 'data/orgReview_LIWC_new.csv')


## start analysis
# Let's start with simple summaries. For each group (e.g. volunteer reviews), 
# compute the mean and standard deviation for each LIWC measure. 
tmp = d[, lapply(.SD, mean), by = type]
names(tmp) = c(names(tmp)[1], paste0(names(tmp)[-1],'.m'))
d.typeSummary = tmp
tmp = d[, lapply(.SD, sd), by = type]
names(tmp) = c(names(tmp)[1], paste0(names(tmp)[-1],'.sd'))
d.typeSummary = merge(d.typeSummary, tmp, by = 'type')


# Next identify measures which vary significantly across different groups.
# For that for each pair of groups (e.g. volunteer and donor), 
# apply a ttest for each measure (e.g. negative emotion) to idnetify whether 
# the measures are significantly different between the two groups and if so 
# what the difference in means is. List reviewer-group-1, reviewer-group-2, 
# measure triplets where the mean is significantly different, with the returned 
# values from t.test (R function for running ttests).
res = list()
# iterate through each type
flag = 1
for(m in unique(d$type)) {
    # iterate through another type
    cat(sprintf('Start the group 1 type of %s \n', m))
    for(n in unique(d$type)){
        # skip when they are the same types
        cat(sprintf('Start the group 2 type of %s \n', n))
        if(m == n) next
        # iterate through each LIWC columns
        for(c in names(d)[-1]){
            cat(sprintf('Start the feature of %s \n', c))
            t = t.test(d[type == m, get(c)], d[type == n, get(c)])
            tmp = data.table(group1 = m, group2 = n, group1.mean = t$estimate[1], 
                             group2.mean = t$estimate[2],
                             liwc = c, p.value = t$p.value)
            res[[flag]] = tmp
            flag = flag + 1
        }
    }
}
res = do.call(rbind, res)

# save the result
write.csv(res, file = 'reviewer_pairwise_ttest.csv')


##########################
##### classification #####
##########################
# One idea is to maybe pose this as a multi-class classification problem 
# and use liwc features as features to our classifier.  
# Use regularization (learning the right regularization term in cross 
# validation) and then analyzing the feature weights and their impact in 
# information gain to determine what type of liwc measures are more commonly
# used by different types of reviews (volunteer, donor etc.)
data = d
y = as.factor(d$type)
x = data.matrix(d[, -1, with = F])

model_cvfit = cv.glmnet(x , y , alpha = 1, family="multinomial")
coef(model_cvfit, s = "lambda.1se")


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


