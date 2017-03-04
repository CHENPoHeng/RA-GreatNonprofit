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
d$total_review = sum(d$num_review)
d$percent = d$num_review / d$total_review
p = data.frame(table(d$num_review))
p$Var1 = as.numeric(as.character(p$Var1))
p$CDF = cumsum(p$Freq)

# basic PDF, CDF 
ggplot() +
    geom_line(data = p, aes(x = Var1, y = Freq, col = 'PDF')) +
    geom_line(data = p, aes(x = Var1, y = CDF, col = 'CDF')) +
    scale_x_continuous('number of review') + 
    scale_y_continuous('number of organization') +  
    ggtitle("Organization") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/organization.png")

# PDF, CDF in log
ggplot() +
    geom_line(data = p, aes(x = Var1, y = Freq, col = 'PDF')) +
    geom_line(data = p, aes(x = Var1, y = CDF, col = 'CDF')) +
    scale_x_log10('number of review') + 
    scale_y_log10('number of organization')+  
    ggtitle("Organization (log)") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/organization_log.png")


# - what fraction of reviews come from a certain kind (e.g.  "General Member of the Public").
#   Again a CDF (x axis: fraction of reviews from  "General Member of the Public", 
#   y-axis: fraction of orgs that have that fraction for that type). We can have a curve per type.

d = data
d = d %>% select(type, org) %>% group_by(type) %>% mutate(total_review = n()) %>% 
    group_by(type, org, total_review) %>% summarize(num_review = n()) %>% 
    mutate(fraction_review = num_review / total_review)

p = list()
for(t in unique(d$type)){
    tmp = d[which(d$type == t),]
    tmp = data.frame(table(tmp$fraction_review), stringsAsFactors =  F)
    tmp$Var1 = as.numeric(as.character(tmp$Var1))
    tmp$Freq = cumsum(tmp$Freq) 
    tmp$Percent = tmp$Freq / max(tmp$Freq)
    if (t == '') {
        tmp$type = 'NA'
    } else {
        tmp$type = t
    }
    p[[t]] = tmp
}
p = do.call(rbind, p)

# basic CDF
ggplot() +
    geom_line(data = p, aes(x = Var1, y = Freq, group = type, col = type)) + 
    scale_x_continuous('fraction of review') + 
    scale_y_continuous('number of orgnization') +  
    ggtitle("CDF of Organization in given types") +
    ggtitle("CDF of Organization in given types") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/organization_type.png")

# basic CDF long
ggplot() +
    geom_line(data = p, aes(x = Var1, y = Freq, group = type, col = type)) + 
    scale_x_log10('fraction of review') + 
    scale_y_log10('number of orgnization') +  
    ggtitle("CDF of Organization in given types (log)") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/organization_type_log.png")


# # Normalized CDF
# ggplot() +
#     geom_line(data = p, aes(x = Var1, y = Percent, group = type, col = type)) + 
#     scale_x_continuous('fraction of review') + 
#     scale_y_continuous('percentage') +   
#     ggtitle("Organization in given types (normalized)") +
#     theme(plot.title = element_text(hjust = 0.5))
# ggsave(file="plot/organization_type_percent.png")
# 
# # Normalized CDF in log
# ggplot() +
#     geom_line(data = p, aes(x = Var1, y = Percent, group = type, col = type)) + 
#     scale_x_log10('fraction of review') + 
#     scale_y_continuous('percentage') +   
#     ggtitle("Organization in given types (normalized, log)") +
#     theme(plot.title = element_text(hjust = 0.5))
# ggsave(file="plot/organization_type_percent_log.png")
# 

# 3) Per user:
# - how many reviews do a user write? We can create PDF and CDF plots (x axis: number of reviews,
#   y axis: number of reviewers that write that many reviews) in linear and log-scale

d = data
d = d %>% group_by(reviewer) %>% summarize(num_review = n())
d$total_review = sum(d$num_review)
d$percent = d$num_review / d$total_review
p = data.frame(table(d$num_review))
p$Var1 = as.numeric(as.character(p$Var1))
p$CDF = cumsum(p$Freq)

# basic PDF, CDF 
ggplot() +
    geom_line(data = p, aes(x = Var1, y = Freq, col = 'PDF')) +
    geom_line(data = p, aes(x = Var1, y = CDF, col = 'CDF')) +
    scale_x_continuous('number of review') + 
    scale_y_continuous('number of reviewer') + 
    ggtitle("Reviewer") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/reviewer.png")

# PDF, CDF in log
ggplot() +
    geom_line(data = p, aes(x = Var1, y = Freq, col = 'PDF')) +
    geom_line(data = p, aes(x = Var1, y = CDF, col = 'CDF')) +
    scale_x_log10('number of review') + 
    scale_y_log10('number of reviewer') +
    ggtitle("Reviewer (log)") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/reviewer_log.png")

# - what fraction of reviews written by an individual are in a certain role (e.g. "General Member
#   of the Public") Again a CDF (x axis: fraction of reviews written as a  "General Member of the 
#   Public", y-axis: fraction of users that have written at least that fraction of their reviews in
#   that role). We can have a curve per type again.

d = data

d = d %>% select(type, reviewer) %>% group_by(type) %>% mutate(total_review = n()) %>% 
    group_by(type, reviewer, total_review) %>% summarize(num_review = n()) %>% 
    mutate(fraction_review = num_review / total_review)

p = list()
for(t in unique(d$type)){
    tmp = d[which(d$type == t),]
    tmp = data.frame(table(tmp$fraction_review), stringsAsFactors =  F)
    tmp$Var1 = as.numeric(as.character(tmp$Var1))
    tmp$Freq = cumsum(tmp$Freq) 
    tmp$Percent = tmp$Freq / max(tmp$Freq)
    if (t == '') {
        tmp$type = 'NA'
    } else {
        tmp$type = t
    }
    p[[t]] = tmp
}
p = do.call(rbind, p)

# basic CDF
ggplot() +
    geom_line(data = p, aes(x = Var1, y = Freq, group = type, col = type)) + 
    scale_x_continuous('fraction of review') + 
    scale_y_continuous('number of reviewer')+
    ggtitle("CDF of Reviewer in given types") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/reviewer_type.png")

# basic CDF in log
ggplot() +
    geom_line(data = p, aes(x = Var1, y = Freq, group = type, col = type)) + 
    scale_x_log10('fraction of review') + 
    scale_y_log10('number of reviewer')+
    ggtitle("CDF of Reviewer in given types (log)") +
    theme(plot.title = element_text(hjust = 0.5))
ggsave(file="plot/reviewer_type_log.png")

# # Normalized CDF
# ggplot() +
#     geom_line(data = p, aes(x = Var1, y = Percent, group = type, col = type)) + 
#     scale_x_continuous('fraction of review') + 
#     scale_y_continuous('percentage') + 
#     ggtitle("Reviewer in given types (normalized)") +
#     theme(plot.title = element_text(hjust = 0.5))
# ggsave(file="plot/reviewer_type_percent.png")
# 
# # Normalized CDF in log
# ggplot() +
#     geom_line(data = p, aes(x = Var1, y = Percent, group = type, col = type)) + 
#     scale_x_log10('fraction of review') + 
#     scale_y_continuous('percentage') +
#     ggtitle("Reviewer in given types (normalized, log)") +
#     theme(plot.title = element_text(hjust = 0.5))
# ggsave(file="plot/reviewer_type_percent_log.png")
