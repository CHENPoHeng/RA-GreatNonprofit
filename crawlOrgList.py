import urllib
from bs4 import BeautifulSoup as bs
import re

# find all states
url_base = 'http://greatnonprofits.org'
port = '/navigation/state'
page = urllib.urlopen(url_base + port)
soup = bs(page)

# get lists of ul tags
uls = soup.find_all('ul', {'class', 'state-list'})
# iterate through uls to get state urls and names
state_list = []
for ul in uls:
    lis = ul.find_all('li')
    for li in lis:
        tmp = li.find('a')
        state_list.append((tmp.text, tmp['href']))
        
# walking through each state
for state in state_list:
    state_name = state[0]
    state_url = state[1]
    print 'Start walking through: %s' % state_name 

    # walking through each page:
    org_list = []
    for i in xrange(1,51):
        url_page = '/sort:review_count/direction:desc/page:'
        page = urllib.urlopen(url_base + state_url + url_page + str(i))
        soup = bs(page)

        # get organization list
        ol = soup.find('ol', {'class', 'gnp-searchResults'})
        ol = ol.find_all('div', {'class', 'gnp-searchResult-infoMajor'})
        for org in ol:
            org = org.a
            org_name = re.sub('\n','',org.text).strip()
            org_url = org['href']
            org_list.append((state_name, state_url, org_name, org_url))
        print '%s: Page %s of 50 is done!' % (state_name, i) 

    # write down data by state
    file_name = state_name + '.tsv'
    print 'Start writing %s' % state_name
    with open(file_name, "wb") as writer:
        writer.write('state_name\tstate_url\torg_name\torg_url\n')
        for state_name, state_url, org_name, org_url in org_list:
            writer.write('{0}\t{1}\t{2}\t{3}\n'.format(state_name, state_url, org_name, org_url))
    print '%s is done!' % state_name

