#!/usr/bin/python
# -*- coding: utf-8 -*-

import urllib2
from lxml import etree
import json
import random
from email import encoders
from email.header import Header
from email.mime.text import MIMEText
from email.utils import parseaddr, formataddr
import smtplib
import sys
reload(sys)
sys.setdefaultencoding('utf8')

from_addr = "****@126.com" #raw_input('From: ')
password = "******" #raw_input('Password: ')
to_addr = "********@qq.com" #raw_input('To: ')
smtp_server = "smtp.126.com"#raw_input('SMTP server: ')

def _format_addr(s):
    name, addr = parseaddr(s)
    return formataddr(( \
        Header(name, 'utf-8').encode(), \
        addr.encode('utf-8') if isinstance(addr, unicode) else addr))

def get_json2(date,rk,CK,r):
    '''根据构造出的url获取到航班数据'''
    url= "http://flights.ctrip.com/domesticsearch/search/SearchFirstRouteFlights?DCity1=SHA&ACity1=SIA&SearchType=S&DDate1=%s&IsNearAirportRecommond=0&rk=%s&CK=%s&r=%s"%(date,rk,CK,r)
    headers={'Host':"flights.ctrip.com",'User-Agent':"Mozilla/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0",'Referer':"http://flights.ctrip.com/booking/hrb-sha-day-1.html?ddate1=2017-04-29"}
    headers['Referer']="http://flights.ctrip.com/booking/hrb-sha-day-1.html?ddate1=%s"%date
    req=urllib2.Request(url,headers=headers)
    res=urllib2.urlopen(req)
    content=res.read()
    dict_content=json.loads(content,encoding="gb2312")
    length = len(dict_content['fis']) 
    # print length
    i = 0
    for i in range(length):
        if ((dict_content['fis'][i][u'lp']) < 600 ):
            print (dict_content['fis'][i][u'lp']),
            print (dict_content['fis'][i][u'dt']),
            print (dict_content['fis'][i][u'at']),
            print (dict_content['fis'][i][u'dpbn'])  
            if ((dict_content['fis'][i][u'lp']) <= 450 ):
                msg = MIMEText(('%r at %s in %s'% ((dict_content['fis'][i][u'lp']),(dict_content['fis'][i][u'dt']),(dict_content['fis'][i][u'dpbn']))),'plain', 'utf-8')
                msg['From'] = _format_addr(u'Air <%s>' % from_addr)
                msg['To'] = _format_addr(u'126.Air <%s>' % to_addr)
                msg['Subject'] = Header(u'flight…%r '%(dict_content['fis'][i][u'lp']), 'utf-8').encode()
                server = smtplib.SMTP(smtp_server, 25)
                server.set_debuglevel(0)
                server.login(from_addr, password)
                server.sendmail(from_addr, [to_addr], msg.as_string())
                server.quit()




def get_parameter(date):
    '''获取重要的参数
    date:日期，格式示例：2017-07-13
    '''
    url='http://flights.ctrip.com/booking/hrb-sha-day-1.html?ddate1=%s'%date
    res=urllib2.urlopen(url).read()
    tree=etree.HTML(res)
    pp=tree.xpath('''//body/script[1]/text()''')[0].split()
    CK_original=pp[3][-34:-2]
    CK=CK_original[0:5]+CK_original[13]+CK_original[5:13]+CK_original[14:]

    rk=pp[-1][18:24]
    num=random.random()*10
    num_str="%.15f"%num
    rk=num_str+rk
    r=pp[-1][27:len(pp[-1])-3]

    return rk,CK,r

if __name__=='__main__':
    dates=['2017-04-29','2017-04-30','2017-05-01']

    for date in dates:
        rk,CK,r=get_parameter(date)
        get_json2(date,rk,CK,r)
        print "-----"
