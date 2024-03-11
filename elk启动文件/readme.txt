修改文件权限；

chmod 755 elasticsearch
五：添加和删除服务并设置启动方式；

chkconfig --add elasticsearch　　　　【添加系统服务】
chkconfig --del elasticsearch　　　　【删除系统服务】
六：关闭和启动服务；

service elasticsearch start　　　　　【启动】
service elasticsearch stop　　　　　 【停止】
service elasticsearch restart　　   【重启】
七：设置服务是否开机启动；

chkconfig elasticsearch on　　　　　　【开启】
chkconfig elasticsearch off　　   　 【关闭】