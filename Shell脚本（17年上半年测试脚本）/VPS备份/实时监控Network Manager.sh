#!/bin/bash
while inotifywait -e modify /var/log/messages
do
if tail -n1 /var/log/messages | grep NetworkManager 
then
        echo Love
fi
done