#!/bin/bash
arr_number=(1 2 3 4 5);
arr_string=("abc" "edf" "sss");
#arr_string=('abc' 'edf' 'sss');

#获取数组长度
arr_length=${#arr_number[*]} #arr_length=${#arr_number[@]}
echo arr_length=$arr_length


#读取某个下标的值
arr_number_index2=${arr_number[2]}
arr__strint_index1=${arr_string[1]}
echo "arr_number_index2=$arr_number_index2 ,arr__strint_index1=$arr__strint_index1"

#赋值
#如果该下标元素已经存在,会修改该下标的值为新的指定值。
arr_number[2]=100 #arr_number数组会被修改成(1 2 100 4 5)
#如果指定的下标已经超过当前数组的大小，如上述的arr_number的大小为5，指定下标为10或者11或者大于5的任意值
arr_number[13]=13 #数组被修改为(1 2 100 4 5 13)
#删除操作
    #清除某个元素：这里清除下标为1的数组
    unset arr_number[1]
    #清空整个数组：
    unset arr_number;


#分片访问
    #分片访问形式为：${数组名[@或*]:开始下标:结束下标}，注意，不包括结束下标元素的值。
    #这里分片访问从下标为1开始，元素个数为4。
    ${arr_number[@]:1:4}

#模式替换
    #形式为：${数组名[@或*]/模式/新值}
    ${arr_number[@]/2/98}

#数组的遍历
for v in ${arr_number[@]}; 
do
  echo $v;
done
