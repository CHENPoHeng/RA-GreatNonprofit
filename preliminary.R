library(dplyr)
library(data.table)
library(ggplot2)
# # revise python state_kind_summary
# d = read.csv('state_kind_summary.csv')
# d$percent_review = NULL
# tmp = d %>% group_by(state) %>% mutate(total_review = sum(num_review),
#                                  percent_review = num_review / total_review)
# write.csv(tmp, file = 'state_kind_summary.csv')
# 
############################################# plot 
# 2) Per org: 
# - how many reviews does an org have? We can create PDF and CDF plots 
#   (x axis: number of reviews, y axis: number of charities that have that many reviews) 
#   in linear and log-scale


# - what fraction of reviews come from a certain kind (e.g.  "General Member of the Public").
#   Again a CDF (x axis: fraction of reviews from  "General Member of the Public", 
#   y-axis: fraction of orgs that have that fraction for that type). We can have a curve per type.
d = read.csv('data/orgReview.csv', as.is = T)
d = data.table(d)

d = d %>% select(type, org) %>% group_by(type) %>% mutate(total_review = n()) %>% 
    group_by(type, org, total_review) %>% summarize(num_review = n()) %>% 
    mutate(fraction_review = num_review / total_review)


for(t in unique(tmp$type)){
    tmp = d[which(d$type == t),]
    tmp = data.frame(table(tmp$fraction_review), stringsAsFactors =  F)
    tmp$Var1 = as.numeric(as.character(tmp$Var1))
    tmp$Freq = cumsum(tmp$Freq) 
    plot(tmp$Var1, tmp$Freq, 'l')
}
    
# den = density(tmp$fraction_review)
# p = data.frame(x = den$x, pdf = den$y)
# p$cdf = cumsum(p$pdf)

# basic CDF
ggplot(p, aes(x)) + 
    geom_line(aes(y = pdf), col = 'red') + 
    geom_line(aes(y = cdf), col = 'blue') +
    scale_x_continuous('fraction of review')

# 3) Per user:
# - how many reviews do a user write? We can create PDF and CDF plots (x axis: number of reviews,
#   y axis: number of reviewers that write that many reviews) in linear and log-scale
# - what fraction of reviews written by an individual are in a certain role (e.g. "General Member
#   of the Public") Again a CDF (x axis: fraction of reviews written as a  "General Member of the 
#   Public", y-axis: fraction of users that have written at least that fraction of their reviews in
#   that role). We can have a curve per type again.


