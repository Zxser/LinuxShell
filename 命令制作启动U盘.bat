win+R
cmd
　　C:\>diskpart

　　DISKPART> list disk
如果你的机器只有一块硬盘，那么U盘应该显示为Disk 1

　　DISKPART> select disk 1
选择U盘为当前磁盘

　　DISKPART> clean
清空磁盘

　　DISKPART> create partition primary
创建主分区

　　DISKPART> select partition 1
选择分区

　　DISKPART> active
激活分区（一定要做，不然不能启动）

　　DISKPART> format fs=ntfs quick
快速格式化为NTFS文件系统

　　DISKPART> assign letter=[ ]
指定卷标，［］能不可与现存盘符重复，也可不加参数使用默认。

　　DISKPART> exit
退出Diskpart命令模式。

把ISO解压到U盘
