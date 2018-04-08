#!/bin/bash
direc=`dirname $0`
portal_war=/war/portal.war
cas_war=/war/cas.war
message_war=/war/message.war
data_wat=/war/data.war
jiaoyan_war=/war/jiaoyan.war
peixun_war=/war/peixun.war
score_war=/war/score.war
jiaokeyan_war=/war/jiaokeyan.war
app_war=/war/app.war

if [ -e $portal_war ] ; then
sh $direc/deploy_script/portal.sh
wait 
rm -rf /war/bak/portal*.war
mv /war/portal.war /war/bak/`portal +%Y%m%d_%H%M%S`.war

elif [ -e $cas_war ] ; then   
sh $direc/deploy_script/cas.sh
wait 
rm -rf /war/bak/cas*.war
mv /war/cas.war /war/bak/`cas +%Y%m%d_%H%M%S`.war

elif [ -e $data_war ] ; then 
sh $direc/deploy_script/data.sh
wait 
rm -rf /war/bak/data*.war
mv /war/data.war /war/bak/`data +%Y%m%d_%H%M%S`.war

elif [ -e $message_war ] ; then
sh $direc/deploy_script/message.sh
wait 
rm -rf /war/bak/message*.war
mv /war/message.war /war/bak/`message +%Y%m%d_%H%M%S`.war

elif [ -e $jiaoyan ] ; then
sh $direc/deploy_script/jiaoyan.sh
wait 
rm -rf /war/bak/jiaoyan*.war
mv /war/jiaoyan.war /war/bak/`jiaoyan +%Y%m%d_%H%M%S`.war

elif [ -e $jiaokeyan ] ; then
sh $direc/deploy_script/jiaokeyan.sh
wait 
rm -rf /war/bak/jiaokeyan*.war
mv /war/jiaokeyan.war /war/bak/`jiaokeyan +%Y%m%d_%H%M%S`.war

elif [ -e $peixun ] ; then
sh $direc/deploy_script/peixun.sh
wait 
rm -rf /war/bak/peixun*.war
mv /war/peixun.war /war/bak/`peixun +%Y%m%d_%H%M%S`.war

elif [ -e $score ] ; then
sh $direc/deploy_script/score.sh
wait 
rm -rf /war/bak/score*.war
mv /war/score.war /war/bak/`score +%Y%m%d_%H%M%S`.war

elif [ -e $app ] ; then
sh $direc/deploy_script/app.sh
wait 
rm -rf /war/bak/app*.war
mv /war/app.war /war/bak/`app +%Y%m%d_%H%M%S`.war
else
echo "There is no war package" 
fi


