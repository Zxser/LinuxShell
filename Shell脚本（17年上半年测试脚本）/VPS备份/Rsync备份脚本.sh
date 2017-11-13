#!/bin/bash
export PATH=/bin:/usr/bin:/usr/local/bin
SRC=COMMON
DEST=/data
Server=192.168.0.254
User=tom
#password file must not be other-accessible
Passfile=/root/rsync.pass
#If the  DEST directory not found.then create one.
[ ! -d $DEST ]  && mkdir $DEST
[!  -e $Passfile] && exit 2
rsync -az --delete --password-file=$Passfile ${user}@${Server}::$SRC $DEST/$(date +%Y%m%d)