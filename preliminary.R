setwd('~/Documents/umsi/Ceren/greatNonprofits/')
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

# basic CCDF
tmp <- ggplot_build(cdf)$data[[1]]
ggplot(tmp, aes(x = x, y = 1-y )) + 
    geom_step(col = 'blue') +
    guides(fill = F, col = F) + # to remove legend
    ggtitle('Organization CCDF') +
    xlab('number of review') +
    ylab('CCDF') +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/organization_ccdf.png")

# - what fraction of reviews come from a certain kind (e.g.  "General Member of the Public").
#   Again a CDF (x axis: fraction of reviews from  "General Member of the Public", 
#   y-axis: fraction of orgs that have that fraction for that type). We can have a curve per type.

d = data
d = d %>% select(org, type) %>% group_by(org) %>% mutate(total_review = n()) %>%
    group_by(org, type, total_review) %>% summarize(num_review = n()) %>%
    mutate(fraction_review = num_review / total_review)

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
d = d %>% group_by(reviewer) %>% summarize(num_review = n())
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


# basic CCDF
tmp <- ggplot_build(cdf)$data[[1]]
ggplot(tmp, aes(x = x, y = 1-y )) + 
    geom_step(col = 'blue') +
    guides(fill = F, col = F) + # to remove legend
    ggtitle('Reviewer CCDF') +
    xlab('number of review') +
    ylab('CCDF') +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/reviewer_ccdf.png")


# - what fraction of reviews written by an individual are in a certain role (e.g. "General Member
#   of the Public") Again a CDF (x axis: fraction of reviews written as a  "General Member of the 
#   Public", y-axis: fraction of users that have written at least that fraction of their reviews in
#   that role). We can have a curve per type again.


d = data
d = d %>% select(reviewer, type) %>% group_by(reviewer) %>% mutate(total_review = n()) %>% 
    group_by(reviewer, type, total_review) %>% summarize(num_review = n()) %>% 
    mutate(fraction_review = num_review / total_review)

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


