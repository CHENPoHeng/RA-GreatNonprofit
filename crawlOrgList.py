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
state_list[0][1]
url_page = '/sort:review_count/direction:desc/page:'

page = urllib.urlopen(url_base + state_list[0][1] + url_page)
soup = bs(page)

# get organization list
org_list = []
ol = soup.find('ol', {'class', 'gnp-searchResults'})
ol = ol.find_all('div', {'class', 'gnp-searchResult-infoMajor'})
for i in ol:
    org_name = re.sub('\n','',tmp.text).strip()
    org_url = i['href']
    org_list.append((org_name, org_url))
    