
Android/Linux Shell 脚本：自动获取Wlan/EtherNet DHCP分配的动态IP，然后配置为静态IP并添加默认网关, 最后测试两个网络的联网状态



详细解析见博客：Shell脚本实现动态配置IP与路由：解决嵌入式Android/Linux有线和无线网卡双网共存问题  https://blog.csdn.net/HowieXue/article/details/75937972 


#Function: Auto set static IP for wlan/ethernet, which dynamically assigned from dhcp,and add default gateway

#Param in: default gateway that can access internet, if not enter, this value will be *.*.*.1 of wlan ip 

#Notice: make sure that wlan has not reonnect, we recommend that script is only execute 1 time when network environment changed.



