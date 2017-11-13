#coding=UTF-8
import threading
import socket
import random
import re
import requests
import urllib2
from BeautifulSoup import BeautifulSoup
from time import ctime
import argparse
import ctypes
import sys

'''

Author : bsdr
QQ : 1340447902
Email : 1340447902@qq.com
2015.9.10

'''

user_agents = ['Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20130406 Firefox/23.0',
        'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:18.0) Gecko/20100101 Firefox/18.0',
        'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/533+ (KHTML, like Gecko) Element Browser 5.0',
        'IBM WebExplorer /v0.94', 'Galaxy/1.0 [en] (Mac OS X 10.5.6; U; en)',
        'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)',
        'Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14',
        'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25',
        'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36',
        'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0; TheWorld)']

timeout = 10

class BSDR_scan():

    def __init__(self, ip_list, port_list, h):
        self.ip_list = ip_list
        self.port_list = port_list
        self.p = True
        self.h = h

    # set output color
    def set_color(self, mess, color):
        STD_INPUT_HANDLE = -10
        STD_OUTPUT_HANDLE = -11
        STD_ERROR_HANDLE = -12
        FOREGROUND_BLACK = 0x00 # black.
        FOREGROUND_DARKBLUE = 0x01 # dark blue.
        FOREGROUND_DARKGREEN = 0x02 # dark green.
        FOREGROUND_DARKSKYBLUE = 0x03 # dark skyblue.
        FOREGROUND_DARKRED = 0x04 # dark red.
        FOREGROUND_DARKPINK = 0x05 # dark pink.
        FOREGROUND_DARKYELLOW = 0x06 # dark yellow.
        FOREGROUND_DARKWHITE = 0x07 # dark white.
        FOREGROUND_DARKGRAY = 0x08 # dark gray.
        FOREGROUND_BLUE = 0x09 # blue.
        FOREGROUND_GREEN = 0x0a # green.
        FOREGROUND_SKYBLUE = 0x0b # skyblue.
        FOREGROUND_RED = 0x0c # red.
        FOREGROUND_PINK = 0x0d # pink.
        FOREGROUND_YELLOW = 0x0e # yellow.
        FOREGROUND_WHITE = 0x0f # white.
        std_out_handle = ctypes.windll.kernel32.GetStdHandle(STD_OUTPUT_HANDLE)

        def set_cmd_text_color(color, handle=std_out_handle):
            Bool = ctypes.windll.kernel32.SetConsoleTextAttribute(handle, color)
            return Bool

        def resetColor():
            set_cmd_text_color(FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE)

        set_cmd_text_color(color)
        sys.stdout.write(mess)
        resetColor()



    def get_headers(self, ip, h):
        if h:
            n = False
            socket.setdefaulttimeout(timeout)
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            try:
                # create connection to 80 port

                sock.connect((ip, 80))
                n = True
                #self.set_color("[*][%s] %s :start to get headers!\n" % (ctime(), ip), 0x04)
            except socket.error:
                #self.set_color("[*][%s] %s : 80 is closed!\n" % (ctime(),ip), 0x0e)
                pass

            if n:
                headers = {'User-Agent':random.choice(user_agents)}
                s = requests.session()
                try:
                    #content_response = requests.get('http://'+str(ip), headers=headers)
                    content_response = urllib2.urlopen('http://'+str(ip))
                    html = content_response.read()
                    soup = BeautifulSoup(html)
                    titles = soup.findAll('title')
                    if titles:
                        title = titles[0]
                        self.set_color("[*][%s] %s :Website Title: %s \n" % (ctime(), ip, title.text), 0x0e)
                        # check h3c switch
                        if title.text == 'Web user login':
                            self.set_color("[*][%s] %s : Found H3C Switch! \n" % (ctime(), ip), 0x0e)
                except:
                     #self.set_color("[*][%s] %s :failed to get title!\n" % (ctime(), ip), 0x04)
                    pass
                try:
                    head_response = requests.head('http://'+str(ip), headers=headers, timeout=2)
                    header = head_response.headers
                    #self.set_color("[*][%s] %s :successful to get headers!\n " % (ctime(), ip), 0x0e)
                    #for line in header:
                    #    self.set_color("[*][%s] %s : %s:\n " % (ctime(), line, header[line]), 0x0b)
                    self.set_color("[*][%s] %s : Server:%s \n" % (ctime(), ip, header['Server']), 0x0b)
                    try:
                        self.set_color("[*][%s] %s : X-Powered-By:%s \n" % (ctime(), ip, header['X-Powered-By']), 0x0b)
                    except:
                        pass
                except:
                    #self.set_color("[*][%s] %s :failed to get Server!\n" % (ctime(), ip), 0x04)
                    pass


    # scan open port
    def port_scan(self, ip, p):
        if p:
            socket.setdefaulttimeout(timeout)
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            n = 0
            for port in self.port_list:
                try:
                    sock.connect((ip, port))
                    mess1 =  "[*][%s] %s : %s =====>> open!\n" % (ctime(), ip, port)
                    self.set_color(mess1, 0x0a)
                    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    n += 1
                except socket.error:
                    #self.set_color( "[*][%s] %s : %s =====>> close!\n" % (ctime(), ip, port), 0x01)
                    pass
            mess2 =  "[*][%s] %s open %s ports!\n" % (ctime(), ip, n)
            #self.set_color(mess2, 0x03)


    # chose scan module
    def load_payload(self, ip):
        mess3 =  "[*][%s] %s scan start!\n" % (ctime(), ip)
        #self.set_color(mess3, 0x04)
        self.port_scan(ip, self.p)
        self.get_headers(ip, self.h)
        mess4 =  "[*][%s] %s scan end!\n" % (ctime(), ip)
        #self.set_color(mess4, 0x04)


    def start_scan(self):
        #print "start"
        ip_list = self.ip_list
        threads = []

        for ip in ip_list:
            scan = threading.Thread(target=self.load_payload, args=(ip,))
            threads.append(scan)

        for scan in threads:
            scan.start()
        for scan in threads:
            scan.join()


def run():
    parser = argparse.ArgumentParser(prog='BSDR_SCAN', description='BSDR_SCAN Scan for open ports,http headers and title.',
                                     usage='%(prog)s -t target [-p port] [-b(null or any value)]', add_help=True)

    parser.add_argument('-t', action='store', dest='target', help='scan target\n(example:127.0.0.1 or 192.168.1.1-192.168.1.255 or 192.168.1.1,192.168.1.2)', type=str)
    parser.add_argument('-p', action='store', dest='port', help='scan ports\n(example:80 or 1-1000 or 22,80,443)')
    parser.add_argument('-b', dest='banners',default=False, required=False, help='get http headers and website title')
    parser.print_help()
    args = parser.parse_args()
    ip_list = []
    port_list = []
    if args.target:
        list = re.findall(r'(\d+).(\d+).(\d+).(\d+)-(\d+).(\d+).(\d+).(\d+)', args.target)
        if list:
            list = list[0]
            int_list = []
            for i in list:
                i = int(i)
                int_list.append(i)
            list = int_list
            try:
                for a in range(list[0], list[4]+1):
                    for b in range(list[1], list[5]+1):
                        for c in range(list[2], list[6]+1):
                            for d in range(list[3], list[7]+1):
                                ip = str(a)+'.'+str(b)+'.'+str(c)+'.'+str(d)
                                ip_list.append(ip)
            except:
                print "enter error(target error)\n"
        else:
            list = re.findall(r'(\d+).(\d+).(\d+).(\d+)', args.target)
            if list:
                for ip in list:
                    re_ip = str(ip[0])+'.'+str(ip[1])+'.'+str(ip[2])+'.'+str(ip[3])
                    ip_list.append(re_ip)
            else:
                ip_list.append(args.target)
    else:
        print "target error"

    if args.port:
        list = re.findall(r'(\d+)-(\d+)', args.port)
        if list:
            list = list[0]
            int_list = []
            for i in list:
                i = int(i)
                int_list.append(i)
            list = int_list
            try:
                for port in range(list[0], list[1]+1):
                    port_list.append(port)
            except:
                print "port error"
        else:
            list = re.findall(r'(\d+),', args.port)
            if list:
                for port in list:
                    port_list.append(int(port))
                last_port = re.findall(r',(\d+)$', args.port)
                port_list.append(int(last_port[0]))
            else:
                port_list.append(int(args.port))
    else:
        port_list = [80]
    if args.banners == 0:
        banner = False
    else:
        banner = 1


    scan = BSDR_scan(ip_list, port_list, banner)
    scan.start_scan()



if __name__ == '__main__':
    print '\n'
    print '+-------------------------------------------------------------+'
    print '|                                                             |'
    print '|                B      S       D        R                    |'
    print '|                                                             |'
    print '+-------------------------------------------------------------+\n'

    run()









