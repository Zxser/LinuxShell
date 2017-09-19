#!/bin/bash
#By Backspace
ps -ef|grep simdht_worker.py|grep -v grep|awk '{print $2}'|xargs kill -9
ps -ef|grep index_worker.py|grep -v grep|awk '{print $2}'|xargs kill -9
cd /root/ssbc-master/workers
nohup python simdht_worker.py >/dev/zero 2>&1&
nohup python index_worker.py >/dev/zero 2>&1&
exit