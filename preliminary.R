setwd('~/Documents/umsi/Ceren/greatNonprofits/')
len = length
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
data = read.csv('data/orgReview.csv', as.is = T)
data = data.table(data)

## remove those reviewer_url are empty
i = which(data$reviewer_url == '')
if(len(i)) data = data[-i, ]
i = which(data$type == '')
if(len(i)) data = data[-i, ]


d = data
d = d %>% group_by(org) %>% summarize(num_review = n())
p = data.table(table(d$num_review))
names(p) = c('num_review', 'num_org')
p$num_review = as.numeric(as.character(p$num_review))
p$num_org_CDF = cumsum(p$num_org)

# basic scatter plot of distribution
ggplot() +
    geom_point(data = p, aes(x = num_review, y = num_org), col = 'red', size = 0.5) +
    scale_x_continuous('number of review') + 
    scale_y_continuous('number of organization') +  
    ggtitle("Organization Distribution") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/organization.png")

# basic scatter plot of distribution in log
ggplot() +
    geom_point(data = p, aes(x = num_review, y = num_org), col = 'red', size = 0.5)+
    scale_x_log10('number of review') + 
    scale_y_log10('number of organization')+  
    ggtitle("Organization Distribution (log)") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/organization_log.png")

# basic PDF density
ggplot(p, aes(num_review) ) + 
    geom_density(alpha = 0.1, col = 'red', fill = 'red') + 
    guides(fill = F, col = F) + # to remove legend
    ggtitle('Organization PDF') +
    xlab('number of review') +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/organization_pdf.png")

# basic CDF 
cdf = ggplot(p, aes(num_review)) + 
    stat_ecdf(geom = "step", col = 'blue') + 
    guides(fill = F, col = F) + # to remove legend
    ggtitle('Organization CDF') +
    xlab('number of review') +
    ylab('CDF') +
    theme(plot.title = element_text(hjust = 0.5))
cdf
ggsave(file="plot/organization_cdf.png")

# CDF in logx
cdf + scale_x_log10() +
    ggtitle('Organization CDF (log)') 
ggsave(file="plot/organization_cdf_logx.png")

# basic CCDF
tmp <- ggplot_build(cdf)$data[[1]]
ccdf = ggplot(tmp, aes(x = x, y = 1-y )) + 
    geom_step(col = 'blue') +
    guides(fill = F, col = F) + # to remove legend
    ggtitle('Organization CCDF') +
    xlab('number of review') +
    ylab('CCDF') +
    theme(plot.title = element_text(hjust = 0.5))
ccdf
ggsave(file="plot/organization_ccdf.png")

# CDF in logx
ccdf + scale_x_log10() +
    ggtitle('Organization CCDF (log)') 
ggsave(file="plot/organization_ccdf_logx.png")


# - what fraction of reviews come from a certain kind (e.g.  "General Member of the Public").
#   Again a CDF (x axis: fraction of reviews from  "General Member of the Public", 
#   y-axis: fraction of orgs that have that fraction for that type). We can have a curve per type.

d = data
d = d %>% select(org, type) %>% group_by(org) %>% mutate(total_review = n()) %>%
    group_by(org, type, total_review) %>% summarize(num_review = n()) %>%
    mutate(fraction_review = num_review / total_review)

tmp = data.table(org = rep(unique(d$org), each = len(unique(d$type))),
                 type = rep(unique(d$type),len(unique(d$org))))

d = merge(tmp, d, by = c('org','type'), all.x = T)
d[is.na(d)] = 0

p = list()
for(t in unique(d$type)){
    tmp = d[which(d$type == t),]
    tmp = data.table(table(tmp$fraction_review))
    names(tmp) = c('fraction_review', 'num_org')
    tmp$fraction_review = as.numeric(tmp$fraction_review)
    tmp$fraction_org = tmp$num_org / sum(tmp$num_org)
    tmp$cum_fraction_org = cumsum(tmp$fraction_org) 
    if (t == '') {
        tmp$type = 'NA'
    } else {
        tmp$type = t
    }
    p[[t]] = tmp
}
p = do.call(rbind, p)

## reference:
## http://stackoverflow.com/questions/11344561/controlling-line-color-and-line-type-in-ggplot-legend

# basic Cumulative distribution
ggplot(data = p, aes(x = fraction_review, y = cum_fraction_org, group = type)) +
    geom_line(aes(col = type, linetype = type)) + 
    scale_linetype_manual(values = rep(c('solid', 'dashed'), 5)) + 
    scale_color_manual(values = sort(rep(c(1:4,'grey50'), 2))) + 
    scale_x_continuous('fraction of review') + 
    scale_y_continuous('fraction of orgnization') +  
    ggtitle("Cummulative Organization Distribution in given types") 
    # theme(plot.title = element_text(hjust = 0.5))
    # theme_bw() # remove grey background
ggsave(file="plot/organization_type.png")

# basic Cumulative distribution logx
ggplot(data = p, aes(x = fraction_review, y = cum_fraction_org, group = type)) +
    geom_line(aes(col = type, linetype = type)) + 
    scale_linetype_manual(values = rep(c('solid', 'dashed'), 5)) + 
    scale_color_manual(values = sort(rep(c(1:4,'grey50'), 2))) + 
    scale_x_log10('fraction of review') + 
    scale_y_continuous('fraction of orgnization') +  
    ggtitle("Cummulative Organization Distribution given Types (logx)") 
    # theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/organization_type_logx.png")

# basic Cumulative distribution logxy
ggplot(data = p, aes(x = fraction_review, y = cum_fraction_org, group = type)) +
    geom_line(aes(col = type, linetype = type)) + 
    scale_linetype_manual(values = rep(c('solid', 'dashed'), 5)) + 
    scale_color_manual(values = sort(rep(c(1:4,'grey50'), 2))) + 
    scale_x_log10('fraction of review') + 
    scale_y_log10('fraction of orgnization') +  
    ggtitle("Cummulative Organization Distribution given Types (logxy)") 
# theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/organization_type_logxy.png")


# 3) Per user:
# - how many reviews do a user write? We can create PDF and CDF plots (x axis: number of reviews,
#   y axis: number of reviewers that write that many reviews) in linear and log-scale

d = data
d = d %>% group_by(reviewer_url) %>% summarize(num_review = n())
p = data.table(table(d$num_review))
names(p) = c('num_review', 'num_reviewer')
p$num_review = as.numeric(p$num_review)

# basic scatter plot of distribution
ggplot() +
    geom_point(data = p, aes(x = num_review, y = num_reviewer), col = 'red', size = 0.5) +
    scale_x_continuous('number of review') + 
    scale_y_continuous('number of reviewer') + 
    ggtitle("Reviewer Distribution") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/reviewer.png")


# basic scatter plot of distribution in log
ggplot() +
    geom_point(data = p, aes(x = num_review, y = num_reviewer), col = 'red', size = 0.5) +
    scale_x_log10('number of review') + 
    scale_y_log10('number of reviewer') +
    ggtitle("Reviewer Distribution (log)") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/reviewer_log.png")


# basic PDF density
ggplot(p, aes(num_review) ) + 
    geom_density(alpha = 0.1, col = 'red', fill = 'red') + 
    guides(fill = F, col = F) + # to remove legend
    ggtitle('Reviewer PDF') +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/reviewer_pdf.png")

# basic CDF 
cdf <- ggplot(p, aes(num_review)) + 
    stat_ecdf(geom = "step", col = 'blue') + 
    guides(fill = F, col = F) + # to remove legend
    ggtitle('Reviewer CDF') +
    xlab('number of review') +
    ylab('CDF') +
    theme(plot.title = element_text(hjust = 0.5))
cdf
ggsave(file="plot/reviewer_cdf.png")

# CDF in logx
cdf + scale_x_log10() +
    ggtitle('Reviewer CDF (log)')
ggsave(file="plot/reviewer_cdf_logx.png")

# basic CCDF
tmp <- ggplot_build(cdf)$data[[1]]
ccdf = ggplot(tmp, aes(x = x, y = 1-y )) + 
    geom_step(col = 'blue') +
    guides(fill = F, col = F) + # to remove legend
    ggtitle('Reviewer CCDF') +
    xlab('number of review') +
    ylab('CCDF') +
    theme(plot.title = element_text(hjust = 0.5))
ccdf
ggsave(file="plot/reviewer_ccdf.png")

# CCDF in log
ccdf + scale_x_log10() +
    ggtitle('Reviewer CCDF (log)')
ggsave(file="plot/reviewer_ccdf_logx.png")


# - what fraction of reviews written by an individual are in a certain role (e.g. "General Member
#   of the Public") Again a CDF (x axis: fraction of reviews written as a  "General Member of the 
#   Public", y-axis: fraction of users that have written at least that fraction of their reviews in
#   that role). We can have a curve per type again.

d = data
d = d %>% select(reviewer_url, type) %>% group_by(reviewer_url) %>% mutate(total_review = n()) %>% 
    group_by(reviewer_url, type, total_review) %>% summarize(num_review = n()) %>% 
    mutate(fraction_review = num_review / total_review)# %>% 
    #filter(total_review > 1)

# create a comprehensive data frame
tmp = data.table(reviewer_url = rep(unique(d$reviewer_url), each = len(unique(d$type))),
                 type = rep(unique(d$type),len(unique(d$reviewer_url))))

d = merge(tmp, d, by = c('reviewer_url','type'), all.x = T)
d[is.na(d)] = 0

p = list()
for(t in unique(d$type)){
    tmp = d[which(d$type == t),]
    tmp = data.table(table(tmp$fraction_review))
    names(tmp) = c('fraction_review', 'num_reviewer')
    tmp$fraction_review = as.numeric(tmp$fraction_review)
    tmp$fraction_reviewer = tmp$num_reviewer / sum(tmp$num_reviewer)
    tmp$cum_fraction_reviewer = cumsum(tmp$fraction_reviewer) 
    if (t == '') {
        tmp$type = 'NA'
    } else {
        tmp$type = t
    }
    p[[t]] = tmp
}
p = do.call(rbind, p)


# basic Cumulative distribution
ggplot(data = p, aes(x = fraction_review, y = cum_fraction_reviewer, group = type)) +
    geom_line(aes(col = type, linetype = type)) + 
    scale_linetype_manual(values = rep(c('solid', 'dashed'), 5)) + 
    scale_color_manual(values = sort(rep(c(1:4,'grey50'), 2))) + 
    scale_x_continuous('fraction of review') + 
    scale_y_continuous('fraction of reviewer') +  
    ggtitle("Cummulative Reviewer Distribution in given types") 
ggsave(file="plot/reviewer_type.png")

# basic Cumulative distribution logy
ggplot(data = p, aes(x = fraction_review, y = cum_fraction_reviewer, group = type)) +
    geom_line(aes(col = type, linetype = type)) + 
    scale_linetype_manual(values = rep(c('solid', 'dashed'), 5)) + 
    scale_color_manual(values = sort(rep(c(1:4,'grey50'), 2))) + 
    scale_x_continuous('fraction of review') + 
    scale_y_log10('fraction of reviewer') +  
    ggtitle("Cummulative Reviewer Distribution given Types (logy)") 
ggsave(file="plot/reviewer_type_logy.png")

## To create facets
# It would be based on the total number of reviews by reviewer. 
# Imagine creating buckets [2,4),[4,8),[8,16), etc. 
# You will create facets for review count per reviewer to fall into these categories, 
# and create the per type ratio per reviewer accordingly. 
# So now, you wont have reviewers with 1 or 2 reviews dominating the results for the 
# facets with larger number of reviews since they wont be in that facet 
# (the groups i listed dont even include reviewers with 1 review. 
# so we can keep the current plot and create the one with facets for completeness).

# create facet_group
d = data
facet_group = d %>% group_by(reviewer_url) %>% 
    summarize(num_review = n()) %>% 
    filter(num_review > 1)

# to create group
x = sort(unique(facet_group$num_review))
from = seq(1, len(x), 4)
to = seq(4, len(x), 4)
facet_group$group = NA_character_
for(i in 1:len(x[from])) {
    tmp = which(facet_group$num_review >= x[from][i] & facet_group$num_review <= x[to][i])
    g = paste0('[',x[from][i],',', x[to][i],']')
    facet_group[tmp,]$group = g
}

# calculate reviewer fraction of review in given type
d = d %>% select(reviewer_url, type) %>% group_by(reviewer_url) %>% mutate(total_review = n()) %>% 
    group_by(reviewer_url, type, total_review) %>% summarize(num_review = n()) %>% 
    mutate(fraction_review = num_review / total_review) %>% filter(total_review > 1)

# create a comprehensive data frame
tmp = data.table(reviewer_url = rep(unique(d$reviewer_url), each = len(unique(d$type))),
                 type = rep(unique(d$type),len(unique(d$reviewer_url))))
d = merge(tmp, d, by = c('reviewer_url','type'), all.x = T)
d[is.na(d)] = 0
d$group = facet_group[match(d$reviewer_url, facet_group$reviewer_url),]$group

# create dataframe for plotting
p = list()
for(g in unique(d$group)){
    tmp = d[which(d$group == g), ]
    for(t in unique(d$type)){
        tmp1 = tmp[which(tmp$type == t),]
        tmp1 = data.table(table(tmp1$fraction_review))
        names(tmp1) = c('fraction_review', 'num_reviewer')
        tmp1$fraction_review = as.numeric(tmp1$fraction_review)
        tmp1$fraction_reviewer = tmp1$num_reviewer / sum(tmp1$num_reviewer)
        tmp1$cum_fraction_reviewer = cumsum(tmp1$fraction_reviewer) 
        tmp1$type = t
        tmp1$group = g
        p[[paste(g,t)]] = tmp1
    }
    
}
p = do.call(rbind, p)

# basic Cumulative distribution
for(g in unique(d$group)) {
    tmp = p[group == g,]
    ggplot(data = tmp, aes(x = fraction_review, y = cum_fraction_reviewer, group = type)) +
        geom_line(aes(col = type, linetype = type)) + 
        scale_linetype_manual(values = rep(c('solid', 'dashed'), 5)) + 
        scale_color_manual(values = sort(rep(c(1:4,'grey50'), 2))) + 
        scale_x_continuous('fraction of review') + 
        scale_y_continuous('fraction of reviewer') +  
        ggtitle(paste0(g,": Cummulative Reviewer Distribution in given types"))
    filename = sprintf('plot/reviewer_type_%s.png', g) 
    ggsave(file=filename)
}

## To plot violin plot
# Create a plots that: for each group (e.g. volunteer) of reviews, 
# has a violin plot (geom_violin) for stars in the review. Here x
# axis will be reviewer type, y axis is going to give the distribution
# of reviews according to the stars given.
d = data
ggplot(d, aes(x = type, y = rating, col = type, fill = type)) + 
    geom_violin(alpha = 0.5) + 
    guides(fill = F, col = F) +
    labs(x = 'Type', y = 'Rating') +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file = 'plot/reviewer_type_violin.png')
