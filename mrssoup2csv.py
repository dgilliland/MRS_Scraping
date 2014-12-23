import requests
import json
import csv
import rauth
import time
import re
import pandas as pd
import os
from bs4 import BeautifulSoup
from bs4 import NavigableString, Tag


#os.chdir("~/Desktop/MRS")

websites=(#"http://www.mrs.org/f95-program/","http://www.mrs.org/f96-program/",
          "http://www.mrs.org/s97-abstracts/", "http://www.mrs.org/f97-abstracts/",
          "http://www.mrs.org/spring-1998-abstracts/", "http://www.mrs.org/fall-1998-abstracts/",
          "http://www.mrs.org/spring-1999-abstracts/", # "http://www.mrs.org/fall-1999-abstracts/",
          #"http://www.mrs.org/spring-2000-abstracts/", "http://www.mrs.org/fall-2000-abstracts/",
          #"http://www.mrs.org/s01-abstracts/", "http://www.mrs.org/f01-abstracts/",
          #"http://www.mrs.org/s02-abstracts/", "http://www.mrs.org/f02-abstracts/",
          #"http://www.mrs.org/s03-abstracts/", "http://www.mrs.org/f03-abstracts/",
          #"http://www.mrs.org/s04-abstracts/", "http://www.mrs.org/f04-abstracts/",
          #"http://www.mrs.org/s05-abstracts/", "http://www.mrs.org/f05-abstracts/",
          #"http://www.mrs.org/s06-abstract/", "http://www.mrs.org/f06-abstracts/",
          "http://www.mrs.org/s07-abstracts/", "http://www.mrs.org/f07-abstracts/",
          "http://www.mrs.org/s08-abstracts/", "http://www.mrs.org/f08-abstracts/",
          "http://www.mrs.org/s09-abstracts/", "http://www.mrs.org/f09-abstracts/",
          "http://www.mrs.org/s10-abstracts/", "http://www.mrs.org/f10-abstract/",
          "http://www.mrs.org/s11-abstracts/", "http://www.mrs.org/f11-abstracts/")
          #"http://www.mrs.org/s12-technical-sessions/", "http://www.mrs.org/f12-technical-sessions/",
          #"http://www.mrs.org/s13-technical-sessions/", "http://www.mrs.org/f13-technical-sessions/",
          #"http://www.mrs.org/spring-2014-technical-sessions/", "http://www.mrs.org/fall-2014-technical-sessions/")

count=0
for seed in websites:
    count=count+1
    g = open('MRS'+str(count)+'.csv','wb')
          #print(seed)
    seedx = requests.get(seed)
    seedsoup = BeautifulSoup(seedx.content)
    symposiumlinks=seedsoup.find(id="contentCol").find_all("a")
    for j in symposiumlinks:
        symplink=j.get('href')
        if re.search("abstract-",symplink)!=None:
            if re.search("http:",symplink)==None:
                symplink = "http://www.mrs.org" + symplink
            sympget = requests.get(symplink)
          #print(symplink)
            symp = sympget.content
            sympsoup = BeautifulSoup(symp)
            title=sympsoup.title
            s=sympsoup.find(id="contentCol")
            chunks=[]
            if s!=None:
                for br in s.findAll(re.compile(r"(br|strong)")):
                    if br.name=="strong":
                        if len(br.get_text().split())>9:
                            chunks.append(br.get_text())
                    if br.name=="br":
                        next = br.nextSibling
                        if not (next and isinstance(next,NavigableString)):
                            continue
                        next2 = next.nextSibling
                        if next2 and isinstance(next2,Tag) and next2.name == 'br':
                            next = re.sub(r'(\n|\r|\W+)',' ',next)
                            text = str(next).strip()
                            if text:
                                chunks.append(next)
                len(chunks)
                title2=re.sub("\r\n\t","",title.get_text())
                title2=re.sub("\r\n","",title2)
          #print(title2)
                for iii in range(0,len(chunks)):
                    #if seed=="http://www.mrs.org/s97-abstracts/" | seed== "http://www.mrs.org/f97-abstracts/" | seed=="http://www.mrs.org/spring-1998-abstracts/" | seed=="http://www.mrs.org/fall-1998-abstracts/" | seed=="http://www.mrs.org/spring-1999-abstracts/":
                    #    if sum(1 for c in chunks[iii][:10] if c.isupper())>7:
                    #        g.write(seed + '\t')
                    #        g.write(title2.encode('utf-8')+'\t')
                    #        g.write(chunks[iii] + '\t')
                    #        print(chunks[iii])
                    #        g.write(chunks[iii+1] + '\t')
                    #        g.write('\n')
                    #if seed=="http://www.mrs.org/s07-abstracts/" | seed=="http://www.mrs.org/f07-abstracts/":
                    if len(chunks[iii].split())>50:
                        if len(chunks[iii-1].split())<40:
                            g.write(seed + '\t')
                            g.write(title2.encode('utf-8')+'\t')
                            g.write(title2.encode('utf-8')+'\t')
                            g.write(' '.join(re.sub('\r\n\t',"",chunks[iii-1]).encode('utf-8').split()) + '\t')
          #print(chunks[iii-1])
                            g.write(' '.join(re.sub('\r\n\t',"",chunks[iii]).encode('utf-8').split()) + '\t')
                            g.write('\n')

    g.close()