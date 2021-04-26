'''
from redminelib import Redmine


url = 'https://redmine.bitech-auto.com/redmine'
key = "1c159c411c8ed320899935a55779f8c22b2a0f13"
redmine = Redmine(url=url, key=key)
# project = redmine.project.get("gmw_p03")
user = redmine.user.get(188)
mail =user.mail
print(mail)
'''
import time
import sys
def datetrans(tdate):
    spdate = tdate.replace("/","-")
    try:
        datesec = time.strptime(spdate,'%Y-%m-%d')
    except ValueError:
        print("%s is not a rightful date!!" % tdate)
        sys.exit(1)
    return time.mktime(datesec)
def daysdiff(d1,d2):
    daysec = 24 * 60 * 60
    print(d1,d2)
    return int(( d1 - d2 )/daysec)
date1 = "2022-05-1"
date2 = time.strftime("%Y-%m-%d")
date1sec = datetrans(date1)
date2sec = datetrans(date2)
print("The number of days between two dates is: ",daysdiff(date1sec,date2sec))