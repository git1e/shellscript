shell - $() �� ${}

##### 1���� bash shell �У�$()�ǽ������������ִ�н����ֵ��������



```kotlin
(base) zeng@zeng-X11DAi-N:~/workspace$ ls
a.sh  data.sh  results.txt
#������ ls ��ֵ������ a
(base) zeng@zeng-X11DAi-N:~/workspace$ a=$(ls)
(base) zeng@zeng-X11DAi-N:~/workspace$ echo $a
a.sh data.sh results.txt
```

##### 2��${} �������������滻��һ������£�$var �� ${var} ��û��ɶ��һ���������� ${ } ��ȽϾ�ȷ�Ľ綨�������Ƶķ�Χ��



```bash
(base) zeng@zeng-X11DAi-N:~/workspace$ A=B
#Ŀ�����ӡ����A��Ȼ���ټ���һ��B����������ޡ�
(base) zeng@zeng-X11DAi-N:~/workspace$ echo $AB
#��ʱ��${ }���Խ�Ϊ��ȷ��ȷ�������ķ�Χ
(base) zeng@zeng-X11DAi-N:~/workspace$ echo ${A}B
BB
(base) zeng@zeng-X11DAi-N:~/workspace$
```

##### 3��${ } ��һЩ���⹦�ܣ�

�������Ƕ�����һ������Ϊ��file=/dir1/dir2/dir3/my.file.txt



```ruby
${file#*/}���õ���һ�� / ������ߵ��ַ�����dir1/dir2/dir3/my.file.txt
${file##*/}���õ����һ�� / ������ߵ��ַ�����my.file.txt
${file#*.}���õ���һ�� . ������ߵ��ַ�����file.txt
${file##*.}���õ����һ�� . ������ߵ��ַ�����txt
${file%/*}���õ������ / �����ұߵ��ַ�����/dir1/dir2/dir3
${file%%/*}���õ���һ�� / �����ұߵ��ַ�����(��ֵ)
${file%.*}���õ����һ�� . �����ұߵ��ַ�����/dir1/dir2/dir3/my.file
${file%%.*}���õ���һ�� . �����ұߵ��ַ�����/dir1/dir2/dir3/my

����ķ���Ϊ��
# ��ȥ�����(�ڼ����� # �� $ ֮���)
% ��ȥ���ұ�(�ڼ����� % �� $ ֮�ұ�)
��һ��������Сƥ��r�������������ƥ�䡣
${file#/}������*�ţ���ʾֻȥ������ߵ�/
```