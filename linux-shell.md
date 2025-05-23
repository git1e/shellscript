shell - $() 和 ${}

##### 1、在 bash shell 中，$()是将括号内命令的执行结果赋值给变量：



```kotlin
(base) zeng@zeng-X11DAi-N:~/workspace$ ls
a.sh  data.sh  results.txt
#将命令 ls 赋值给变量 a
(base) zeng@zeng-X11DAi-N:~/workspace$ a=$(ls)
(base) zeng@zeng-X11DAi-N:~/workspace$ echo $a
a.sh data.sh results.txt
```

##### 2、${} 是用来作变量替换。一般情况下，$var 与 ${var} 并没有啥不一样。但是用 ${ } 会比较精确的界定变量名称的范围：



```bash
(base) zeng@zeng-X11DAi-N:~/workspace$ A=B
#目的想打印变量A，然后再加上一个B，结果返回无。
(base) zeng@zeng-X11DAi-N:~/workspace$ echo $AB
#此时，${ }可以较为精确的确定变量的范围
(base) zeng@zeng-X11DAi-N:~/workspace$ echo ${A}B
BB
(base) zeng@zeng-X11DAi-N:~/workspace$
```

##### 3、${ } 的一些特殊功能：

假设我们定义了一个变量为：file=/dir1/dir2/dir3/my.file.txt



```ruby
${file#*/}：拿掉第一条 / 及其左边的字符串：dir1/dir2/dir3/my.file.txt
${file##*/}：拿掉最后一条 / 及其左边的字符串：my.file.txt
${file#*.}：拿掉第一个 . 及其左边的字符串：file.txt
${file##*.}：拿掉最后一个 . 及其左边的字符串：txt
${file%/*}：拿掉最后条 / 及其右边的字符串：/dir1/dir2/dir3
${file%%/*}：拿掉第一条 / 及其右边的字符串：(空值)
${file%.*}：拿掉最后一个 . 及其右边的字符串：/dir1/dir2/dir3/my.file
${file%%.*}：拿掉第一个 . 及其右边的字符串：/dir1/dir2/dir3/my

记忆的方法为：
# 是去掉左边(在鉴盘上 # 在 $ 之左边)
% 是去掉右边(在鉴盘上 % 在 $ 之右边)
单一符号是最小匹配﹔两个符号是最大匹配。
${file#/}（不加*号）表示只去掉最左边的/
```