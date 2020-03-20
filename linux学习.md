- cd命令
  功能说明：切换目录。
  举 例：cd /usr/local/；cd ..；cd -
- ls命令
  功能说明：列出目录内容。
  举 例：ls -ltr ；ls -lrt /home/
- pwd命令
  功能说明：查询所在目录。
  举 例： pwd
- cat命令
  功能说明：查看小文件内容。
  举 例：cat -n 123.txt
- more命令
	空格下翻，b上翻 h帮助
  功能说明：查看大文件内容
  举 例：more System.map-3.10.0-123.el7.x86_64
- head命令
  功能说明：查看文件的前面N行。
  举 例：head -20 System.map-3.10.0-123.el7.x86_64
- tail命令
  功能说明：查看文件的后面N行。
  举 例：tail -f access.log ；tail -20 access.log
- touch命令
  功能说明：创建一个空文件。
  举 例：touch 123.txt
  mkdir命令
- 功能说明：创建目录。
  举 例：mkdir -p /tmp/XD/XD/class
- rmdir命令
  功能说明：删除目录。
  举 例：rmdir /tmp/XD/XD/class
- cp命令
  功能说明：拷贝文件。
  举 例：cp 123.txt class/ ； cp -a 123.txt class/789.tx
- mv命令
  功能说明：移动或更名现有的文件或目录。
  举 例：mv 123.txt 345.php ；mv 789.txt /home/987.php
- rm命令
  功能说明：删除文件或目录。
  举 例：rm 987.php ；rm -rf 456.txt
- diff命令
  功能说明：对比文件差异。
  举 例：diff 123.txt 456.txt
- ssh命令
  功能说明：远程安全登录方式。
  举 例：ssh 192.168.226.131
- exit命令
  功能说明：退出命令。
  举 例：
- id命令
  功能说明：查看用户。
  举 例：id root
- uname命令
  功能说明：查询主机信息。
  举 例：uname -a
- ping命令
  功能说明：查看网络是否通。
  举 例：ping 192.168.226.131

- echo命令   

  功能说明：标准输出命令。
  举 例：echo "this is echo 命令"

- man命令(ls --help)

  功能说明：查看帮助文档
  举 例：man ls

- help命令
功能说明：查看内部命令帮助
举 例:help if

- clear命令
功能说明：清屏。
举 例：clear ; ctrl + l

- who命令
功能说明：当前在本地系统上的所有用户的信息
举 例：whoami ; who

- uptime命令
功能说明：查询系统信息
举 例：
load average: 0.00, 0.01, 0.05 1分钟的负载，5分钟的负载，15分钟的负载

- w命令
功能说明：查询系统信息
举 例：w

- free命令
功能说明：查看系统内存
举 例：free -h ; free -m

- wc命令
功能说明：统计行。
举 例：wc -l 123.txt

- grep命令
功能说明：查找文件里符合条件的字符串。
举 例：grep '119.4.253.206' 123.txt | wc -l
-n:输出行数 grep -n '80.82.70.187' 123.txt
-w:精确匹配 grep -w '113.66.107.198' 123.txt
-i:忽略大小写 grep -i 'IP:113.66.107.198' 123.txt
-v:反向选择 grep -v '113.66.107.198' 123.txt

- find命令
功能说明：查询文件。
举 例：find / -name -type f 123.txt

- uniq命令
功能说明：对排序好的内容进行统计
举 例：uniq -c 123.txt | sort -n

- sort命令
功能说明：对内容进行排序
举 例：uniq -c 123.txt | sort -n

- df命令
功能说明：文件系统的磁盘使用情况统计。
举 例：df -h

- netstat
功能说明：查看网络端口的使用情况
举 例：netstat -tunlp | grep nginx
-t ：显示tcp端口
-u ：显示UDP端口
-n ：指明拒绝显示别名
-l ：指明listen的
-p ：指明显示建立相关连接的程序名
安装netstat命令：yum -y install net-tools

- hostname命令
功能说明：查看主机名
举 例：hostname

- ps命令
功能说明：显示所有进程信息。 ps 与grep 常用组合用法，查找特定进程
举 例：ps -ef | grep nginx
ps -aux | grep nginx

- kill命令
功能说明：杀进程
举 例： kill -9 top

- top命令
功能说明：监控Linux系统状况，比如cpu、内存的使用
举 例：按住键盘q退出

- du命令
功能说明：统计大小
举 例：du -sh ； du -sm 

- firewall-cmd命令
功能说明：查看防火墙的状态
举 例：firewall-cmd --state
centos 7 关闭防火墙：systemctl stop firewalld.service

- echo命令
功能说明：判断上一条命令是否正确
举 例：echo $?

- cal命令
功能说明：查看日历
举 例：cal 2008