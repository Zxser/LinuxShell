#!/usr/bin/gawk 
#
# 
# 接口地址：http://api.avatardata.cn/Weather/Query
# 返回格式：JSON/XML
# 请求方式：GET/POST
# 请求示例： http://api.avatardata.cn/Weather/Query?key=[您申请的APPKEY]&cityname=武汉
# 接口备注：全国天气预报，预报7天天气，以及当天的生活指数、实况、PM2.5等信息
# 请求参数：
# 	名称	类型	必填	说明
# 	key	String	是	应用APPKEY
# 	cityname	String	是	要查询的城市，如：温州、上海、北京
# 	dtype	String	否	返回结果格式：可选JSON/XML，默认为JSON
# 	format	Boolean	否	当返回结果格式为JSON时，是否对其进行格式化，为了节省流量默认为false，测试时您可以传入true来熟悉返回内容
#
#


BEGIN{
  key = "4f0b90a529934e65a05cdf32b2d7800a"
  weather_url = "https://api.heweather.com/x3/weather?cityid=cityname&key=" key
  city_url = "https://api.heweather.com/x3/citylist?search=allchina&key=" key
  
  city_content = getHtml(city_url)
  city_content_array_build(city_content)

  print "请输入城市名字："
  getline cityname <"/dev/tty"

  weather_info = getHtml(gensub(/cityname/,city_arr[cityname],1,weather_url))
  if(weather_info ~ /"status":"ok"/){
    wearther_parser(weather_info)
  }else{
    print "仅支持中国部分市级城市!"
  }
  #print weather_info
}

function getHtml(url){
    host=gensub("^https?://|/.*","","g",url);
    path=gensub("^https?://[^/]*/?","/","g",url);
    socket="/inet/tcp/0/"host"/80";
    print "GET "path" HTTP/1.0\r\nHost: "host"\r\n\r" |& socket;
    html="";
	#close(socket,"to")
    while((socket |& getline) > 0){
            html=html$0"\n";
    }
    close(socket);
    return html;
}

function city_content_array_build(txt){
   L=split(txt,a,"\n")
   j=split(a[L-1],json,",")
   for(i=1;i<=j;i++){
     if(json[i] ~ /"city":/){
        s=gensub(/.*:|"/,"","g",json[i])
	  }
	  if(json[i] ~ /"id":/){
	    city_arr[s] = gensub(/.*:|"/,"","g",json[i])
	  }
   }
}

function color_print(x,y){
   printf ("\033[35m%s\033[0m\033[33m%s\033[0m\n",x,y)
}

function wearther_parser(txt){
  print "Wearther Info:"
  # 10 days = 864000 seconds
  color_print("Today: ",strftime("%F",systime()))
  nextday = strftime("%F",systime()+86400)
  L=split(txt,a,"\n")
  j=split(a[L-1],json,",")
  for(i=1;i<=j;i++){
     if(json[i] ~ nextday){
	   i=j+1
	   continue
	 }
     if(json[i] ~ /"pm25":/){
        color_print( "pm25:",gensub(/.*:| /,"","g",json[i]))
	  }
     if(json[i] ~ /"qlty":/){
        color_print( "空气质量:",gensub(/.*:| /,"","g",json[i]))
	  }	  
     if(json[i] ~ /"hum":/){
        color_print( "湿度:",gensub(/.*:| /,"","g",json[i]))
	  }	 
     if(json[i] ~ /"txt_d":/ && !n){
        color_print( "天气状况:",gensub(/.*:| /,"","g",json[i]))
		n=1
	  }	 
	 if(json[i] ~ /"max":/){
        color_print( "最高温度:",gensub(/.*:|\}| /,"","g",json[i]))
	  }
	 if(json[i] ~ /"min":/){
        color_print( "最低温度:",gensub(/.*:|\}| /,"","g",json[i]))
	  }
   }
}

