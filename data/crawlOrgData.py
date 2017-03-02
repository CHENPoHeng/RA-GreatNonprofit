import os
import urllib
import re
from bs4 import BeautifulSoup as bs

# default setting 
url_base = 'http://greatnonprofits.org'

# walk through orgList folder
dir_base = 'orgList/'
files = os.listdir(dir_base)

for file_dir in files[12:]:
    # read each file and go through data 
    with open(dir_base + file_dir, 'rb') as tsv:
        file = tsv.read()

    # initialize organization data list 
    org_data = {}
    overview_items = ['url','telephone','tax_num','street','locality','region',
        'postcode','country']

    # read in organization list and iterate through
    org_list = file.split('\n')
    for org in org_list:
        if org == '':
            print 'This is skipped because it is empty item.'
            continue
        org_name, org_url = org.split('\t')
        if org_name == 'org_name':
            print 'This is skipped because it is the header.'
            continue
        # iterate through organization list
        print 'Start parsing the org: %s' % org_name
        page = urllib.urlopen(url_base + org_url)
        soup = bs(page)
        ## get organization info
        np_info = soup.find('ul', {'id' : 'np-info-details'})
        if np_info is None:
            continue
        # get tax number
        np_tax = np_info.li.find_all('span')
        for i in np_tax:
            if i.text.isupper():
                np_tax = i.text
                break
        np_tel = np_info.find('span', {'class': 'telephone'}).text
        np_street = np_info.find('span', {'itemprop': 'streetAddress'}).text.strip()
        np_locality = np_info.find('span', {'itemprop': 'addressLocality'}).text.strip()
        np_region = np_info.find('span', {'itemprop': 'addressRegion'}).text.strip()
        np_postcode = np_info.find('span', {'itemprop': 'postalCode'}).text.strip()
        np_country = np_info.find('span', {'itemprop': 'addressCountry'}).text.strip()
        np_url = np_info.find('a', {'class': 'link-fa-desktop'})['href']
        # store data into dictionary
        org_data[org_name] = {}
        org_data[org_name]['url'] = np_url 
        org_data[org_name]['telephone'] = np_tel
        org_data[org_name]['tax_num'] = np_tax
        org_data[org_name]['street'] = np_street
        org_data[org_name]['locality'] = np_locality
        org_data[org_name]['region'] = np_region
        org_data[org_name]['postcode'] = np_postcode
        org_data[org_name]['country'] = np_country
        ## get organization overview
        np_overview = soup.find('div', {'class' : 'np-overview'})
        np_overview = np_overview.find_all('p')
        # iterate through np_overview
        for item in np_overview:
            # create a list to store all kinds of overview items
            # for later data frame building
            if item.strong is not None and len(item.strong.text) < 50:
                if item.strong.text not in overview_items:
                    overview_items.append(item.strong.text.encode('ascii','ignore'))
            else:
                continue
            # parse content
            item_content= item.text.replace('\r','').replace('\n',' ')
            pattern = item.strong.text + '(.*)'
            # pattern = item.strong.text + '\:\s(.*)'
            if re.match(pattern,item_content):
                item_content = re.findall(pattern,item_content)[0].strip()
            else:
                continue
            if item_content == '':
                continue    
            if item_content[0] == ':':
                item_content = item_content[1:].strip()
            
            org_data[org_name][item.strong.text.encode('ascii','ignore')] = item_content

    ## after data are saved, 
    file_name = 'orgData/' + file_dir
    print 'Now it is working on State: %s' % file_dir
    with open(file_name, "wb") as writer:
        header = 'name\t' + '\t'.join(overview_items) + '\n'
        writer.write(header)
        for org_name in org_data:
            print 'Start writing data of org: %s' % org_name
            tmp = [org_name]
            for item in overview_items:
                if item not in org_data[org_name]:
                    tmp.append('')
                else:
                    tmp.append(org_data[org_name][item])
            tmp = '\t'.join(tmp).encode('ascii', 'ignore') + '\n'
            writer.write(tmp)


