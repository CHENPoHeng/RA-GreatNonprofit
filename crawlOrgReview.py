import os
import urllib
import re
from bs4 import BeautifulSoup as bs


# default setting 
url_base = 'http://greatnonprofits.org'

# walk through orgList folder
dir_base = 'orgList/'
files = os.listdir(dir_base)

# iterate through each file
for file_dir in files[-3:]:
    # read each file and go through data 
    with open(dir_base + file_dir, 'rb') as tsv:
        file = tsv.read()

    # write reviews in a new file
    path = 'orgReview/'
    file_name = path + file_dir
    with open(file_name, 'wb') as writer:
        header = ['org','id', 'likes','reviewer_url','reviewer','type','rating','date','review']
        writer.write('\t'.join(header) + '\n')

        # get organization list
        org_list = file.split('\n')
        for org in org_list:
            if org == '':
                print 'This is skipped because it is empty item.'
                continue
            org_name, org_url = org.split('\t')
            if org_name == 'org_name':
                print 'This is skipped because it is the header.'
                continue

            page = urllib.urlopen(url_base + org_url)
            soup = bs(page) 
            print 'Start parsing the org: %s' % org_name

            # get the total number of pages
            if soup.find('div', {'class': 'np-pag'}):
                num_pages = soup.find('div', {'class': 'np-pag'}).p.text.split()[-1]
            else:
                num_pages = 1
            # revise url
            org_url = org_url.split('/')[-1]
            review_url = '/organizations/view/' + org_url + '/page:'
            # iterate each page of a organization
            for i in xrange(1, int(num_pages) + 1):

                page = urllib.urlopen(url_base + review_url + str(i))
                soup = bs(page) 
                # get all reviews
                reviews = soup.find_all('div', {'itemprop': 'review'})
                # iterate all review and parse 
                for review in reviews:
                    # parse review data
                    if review.find('a', {'class': 'review-yes'}) is None:
                        continue
                    tmp = review.find('a', {'class': 'review-yes'})
                    review_id = tmp['review_id']
                    review_likes = tmp.text
                    tmp = review.find('p', {'class': 'author'})
                    reviewer_url = tmp.a['href']
                    reviewer_name = tmp.a.text.replace('\n','').strip()
                    if tmp.span.text[0].isdigit():
                        reviewer_type = tmp.contents[-3].replace('\n','').strip()
                    else: 
                        reviewer_type = tmp.span.text

                    reviewer_rating = review.find('span', {'itemprop': 'ratingValue'}).text
                    review_date = review.find('span', {'itemprop': 'datePublished'}).text
                    tmp = review.find('div', {'itemprop': 'reviewBody'})
                    review_body = tmp.text.replace('\n','')

                    # write them line by line
                    to_be_write = '\t'.join([org_name, review_id, review_likes, reviewer_url,
                        reviewer_name, reviewer_type, reviewer_rating, review_date, review_body]).encode('ascii', 'ignore')
                    writer.write(to_be_write + '\n')
                print 'Org: %s, page %s out of %s is done!' % (org_name, i, num_pages) 
