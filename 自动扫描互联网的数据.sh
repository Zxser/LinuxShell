rm delegated-apnic-latest
if type wget
then wget http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
else fetch http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
fi
grep 'apnic|CN|ipv4' delegated-apnic-latest | cut -f 4,5 -d '|' | tr '|' ' ' | while read ip cnt
do
mask=$(bc <<END | tail -1
pow=32;
define log2(x) {
if (x<=1) return (pow);
pow--;
return(log2(x/2));
}
log2($cnt);
END
)
echo $ip/$mask';'>>cnnet
resultext=`whois $ip@whois.apnic.net | grep -e ^netname -e ^descr -e ^role -e ^mnt-by | cut -f 2 -d ':' | sed 's/ *//'`
if echo $resultext | grep -i -e 'railcom' -e 'crtc' -e 'railway'
then echo $ip/$mask';' >> crc
elif echo $resultext | grep -i -e 'cncgroup' -e 'netcom'
then echo $ip/$mask';' >> cnc
elif echo $resultext | grep -i -e 'chinanet' -e 'chinatel'
then echo $ip/$mask';' >> telcom_acl
elif echo $resultext | grep -i -e 'unicom'
then echo $ip/$mask';' >> unicom
elif echo $resultext | grep -i -e 'cmnet'
then echo $ip/$mask';' >> cmnet
else
echo $ip/$mask';' >> other_acl
fi
done
