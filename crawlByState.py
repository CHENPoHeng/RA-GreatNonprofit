import urllib
from bs4 import BeautifulSoup as bs

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
        

#