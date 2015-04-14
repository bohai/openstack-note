..  
声明：   
本博客欢迎转发，但请保留原作者信息!   
博客地址：http://blog.csdn.net/halcyonbaby   
新浪微博：寻觅神迹

内容系本人学习、研究和总结，如有雷同，实属荣幸！   

==================
防火墙环境下使用Devstack安装Magnum
==================

1. 安装fedora21环境
2. 配置fedora、epel repo源使用国内的源，比如163、aliyun
3. 配置pip源，比如163、aliyun
4. 设置env GIT_SSL_NO_VERIFY=true
5. 设置stackrc中git头为http
6. 配置proxy参数
重要：no_proxy中一定要包含本机IP、proxy机IP。
7. 创建stack用户，并设置可以sudo
8. 切换成stack用户，下载devstack
9. 生成local.conf，增加“enable_plugin magnum https://github.com/openstack/magnum"
10. 运行stack.sh
