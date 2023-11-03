# 3장 문자열을 찾을 수 있는 grep

```
grep 명령어는 특정 디렉터리나 로그, 환경 설정 파일 등에서 특정 문자열을 찾을 수 있음.
제공된 파일이나 선행 명령어의 결과에서 입력한 패턴과 일치하는 라인이 있는지 검색하여 해당 라인을 출력함.
```



## 1. grep 사용법



##### 사용법 1

```
grep [옵션] 패턴 [파일]

grep을 사용할 때는 옵션, 검색할 문자열의 패턴, 검색 대상이 되는 파일명이 필요함.
옵션 -i는 대소문자를 구분하지 않고 패턴을 검색하라는 의미
```

```sh
grep -i 'uuid' /etc/fstab
# device; this may be used with UUID= as a more robust way to name devices
UUID=3ac3a255-4d79-4619-9863-29b1be0745b8 /               ext4    errors=remount-ro 0       1
UUID=4AFB-6089  /boot/efi       vfat    umask=0077      0       1
```



##### 사용법 2

```
grep [옵션] [-e 패턴 | -f 파일] [파일]

-e 옵션은 검색하고자 하는 패턴이 하나 이상일 경우 사용되는 옵션.
-f 옵션은 -e 옵션과 동일하게 여러 개의 패턴을 검색할 경우 패턴이 저장된 파일을 이용하여 검색할 수 있음.
자주 사용되거나, 정규 표현식으로 만들어진 복잡한 패턴일 경우 파일로 저장하여 사용하면
다음 검색 시 다시 사용할 수 있어 매우 효율적임.
```

```sh
# 대괄호[]가 앞뒤에 있는 문자열 검색
grep -i -e "^\[[[:alnum:]]*\]" /etc/nova/nova.conf
[DEFAULT]
[api]
[barbican]
...

# 대괄호[]가 앞뒤에 있는 문자열이나 virt_type으로 시작하는 문자열 검색
grep -i -e "^\[[[:alnum:]]*\]" -e "^virt_type" /etc/nova/nova.conf
[DEFAULT]
[api]
[barbican]
...
[libvirt]
virt_type = kvm

# 패턴이 저장되어 있는 파일을 이용한 검색
echo "^\[[[:alnum:]]*\]" > pattern1.txt
grep -i -f pattern1.txt /etc/nova/nova.conf
[DEFAULT]
[api]
[barbican]
...

# 패턴이 저장되어 있는 여러 파일의 검색도 가능함
echo "^virt_type" > pattern2.txt
grep -i -f pattern1.txt -f pattern2.txt /etc/nova/nova.conf
[DEFAULT]
[api]
[barbican]
...
[libvirt]
virt_type = kvm
```



##### 사용법 3

```
명령어 | grep [옵션] [ 패턴 | -e 패턴 ]
```

```sh
cat /etc/nova/nova.conf | grep -i '^\[Default'
[DEFAULT]
```

---



## 2. grep의 다양한 옵션들 

### 1) 패턴 문법 관련 옵션

| 옵션                  | 설명                                                         |
| --------------------- | ------------------------------------------------------------ |
| -E, --extended-regexp | 확장 정규 표현식에 해당하는 패턴을 검색할 경우 사용          |
| -F, --fixed-strings   | 여러 줄로 되어 있는 문자열을 검색할 경우 사용됨              |
| -G, --basic-regexp    | 기본 정규 표현식에 해당하는 패턴을 검색할 때 사용되는 옵션으로<br>기본으로 적용됨. 옵션을 생략하면 -G 옵션 |
| -P, --perl-regexp     | Perl 방식의 정규 표현식에 해당하는 패턴을 검색할 때 사용되는 옵션으로<br>다른 옵션에 비해 잘 사용되지는 않음 |



##### 예제에 사용될 expression.txt

```
====================
 Regular Expression
====================
  
#===========================================#
# Date: 2020-05-05
# Author: NaleeJang
# Description: regular expression test file
#===========================================#


Today is 05-May-2020.
Current time is 6:04PM.
This is an example file for testing regular expressions.	This example file includes control characters.

# System Information
CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
Memory size is 32GiB
Disk is 512 GB
IP Address is 192.168.35.7

# Help
Do you have any questions? or Do you need any help?
If you have any questions, Please send a mail to the email below.

# Contacts
e-mail: nalee999@gmail.com
phone: 010-2222-5668
```



##### -E 옵션을 사용할 경우

```sh
# -E 옵션 없이 정규 표현식을 사용하여 검색한 경우
grep 'q[[:lower:]]*\??' expression.txt
Do you have any questions? or Do you need any help?

# -E 옵션과 함께 정규 표현식을 사용하여 검색한 경우
grep -E 'q[[:lower:]]*\??' expression.txt
Do you have any questions? or Do you need any help?
If you have any questions, Please send a mail to the email below.
```

```
정규 표현식 ?는 앞에서 검색한 단어 하나가 일치하거나, 일치하지 않을 경우에도 검색이 되도록 해주는 확장 정규 표현식에 해당함.
```



##### -F 옵션을 사용할 경우

```sh
grep -F '# Date
# Author
# Description' expression.txt

# Date: 2020-05-05
# Author: NaleeJang
# Description: regular expression test file
```



##### -G 옵션을 사용할 경우

```sh
# 옵션 없이 정규 표현식을 사용하여 검색한 경우
grep 'q[[:lower:]]*\??' expression.txt
Do you have any questions? or Do you need any help?

# -G 옵션과 함께 정규 표현식을 사용하여 검색한 경우
grep -G 'q[[:lower:]]*\??' expression.txt
Do you have any questions? or Do you need any help?
```



##### -P 옵션을 사용할 경우

```sh
# 옵션 없이 정규 표현식을 사용하여 검색한 경우
grep "(?<=\[')[^,]*" /etc/nova/nova.conf

# -P 옵션과 함께 정규 표현식을 사용하여 검색한 경우
grep -P "(?<=\[')[^,]*" /etc/nova/nova.conf
# "['-v', '-R', '500']"
#	Where '[' indicates zero or one occurrences, '{' indicates zero or multiple
```

---



### 2) 매칭 제어 관련 옵션

| 옵션                   | 설명                                                         |
| ---------------------- | ------------------------------------------------------------ |
| -e 패턴, --regexp=패턴 | 여러 개의 패턴을 검색할 때 사용되며, OR 조건으로 검색이 이루어짐 |
| -f 파일, --file=파일   | 패턴이 포함된 파일을 이용하여 검색할 때 사용됨               |
| -i, --ignore-case      | 패턴 검색 시 대소문자 구분을 무시할 경우 사용됨              |
| -v, --invert-match     | 해당 패턴을 제외하고 검색할 경우 사용됨<br>주석을 제거한 파일 내용만 볼 경우 주로 사용 |
| -w, --word-regexp      | 검색하고자 하는 단어가 정확하게 있는 라인만 검색할 경우 사용 |
| -x, --line-regexp      | 검색하고자 하는 패턴과 정확하게 일치하는 라인만 검색할 경우 사용 |
| -y                     | -i 옵션과 동일한 기능을 제공                                 |



##### -e 패턴, --regexp=패턴 옵션을 사용할 경우

```sh
# mail과 phone이라는 단어가 포함된 라인 검색
grep -e 'mail' --regexp='phone' expression.txt
If you have any questions, Please send a mail to the email below.
e-mail: nalee999@gmail.com
phone: 010-2222-5668
```



##### -f 파일, --file=파일 옵션을 사용할 경우

```sh
# mail과 phone을 파일로 저장
echo 'mail' > file1.txt
echo 'phone' > file2.txt

# 저장한 파일을 이용해 expression.txt에서 mail과 phone이 포함된 문자열 검색
grep -f file1.txt --file=file2.txt expression.txt
If you have any questions, Please send a mail to the email below.
e-mail: nalee999@gmail.com
phone: 010-2222-5668
```



##### -i, --ignore-case 옵션을 사용할 경우

```sh
# 대소문자 구분없이 expression 검색
grep -i 'expression' expression.txt
 Regular Expression
# Description: regular expression test file
This is an example file for testing regular expressions.	This example file includes control characters.
```



##### -v, --invert-match 옵션을 사용할 경우

```sh
# 주석과 공백을 제외한 파일 내용 확인
cat expression.txt | grep -v '^#' | grep -v '^$'
====================
 Regular Expression
====================
  
Today is 05-May-2020.
Current time is 6:04PM.
This is an example file for testing regular expressions.	This example file includes control characters.
CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
Memory size is 32GiB
Disk is 512 GB
IP Address is 192.168.35.7
Do you have any questions? or Do you need any help?
If you have any questions, Please send a mail to the email below.
e-mail: nalee999@gmail.com
phone: 010-2222-5668
```



##### -w, --word-regexp 옵션을 사용할 경우

```sh
# -w 옵션없이 검색했을 경우
grep 'expression' expression.txt
# Description: regular expression test file
This is an example file for testing regular expressions.	This example file includes control characters.

# -w 옵션을 사용했을 경우 일치하는 단어가 있는 라인만 출력
grep -w 'expression' expression.txt
# Description: regular expression test file
```



##### -x, --line-regexp 옵션을 사용할 경우

```sh
# 일부만 일치할 경우 결과 없음
grep -x 'Help' expression.txt


# 라인 전체가 일치할 경우에만 결과를 보여줌
grep -x '# Help' expression.txt
# Help
```



##### -y 옵션을 사용할 경우

```sh
# 대소문자 구분없이 검색
grep -y 'expression' expression.txt
 Regular Expression
# Description: regular expression test file
This is an example file for testing regular expressions.	This example file includes control characters.
```

---



### 3) 출력 제어 관련 옵션

| 옵션                            | 설명                                                         |
| ------------------------------- | ------------------------------------------------------------ |
| -c, --count                     | 패턴과 일ㄹ치하는 단어의 개수를 보여줌                       |
| --color                         | GREP_COLORS 환경변수에 의해 정의된 컬러에 맞게<br>검색한 패턴과 동일한 문자열의 색을 바꿔서 보여줌 |
| -L, --files-without-match       | 검색 대상이 되는 파일 중 패턴과 일치하는 단어가 없는 파일명을 보여줌 |
| -l, --files-with-matches        | 검색 대상이 되는 파일 중 패턴과 일치하는 단어가 있는 파일명을 보여줌 |
| -m 라인 수, --max-count=라인 수 | 패턴과 일치하는 단어가 포함된 라인을 해당 라인 수만큼 보여줌 |
| -o, --only-matching             | 패턴과 일치하는 단어만 보여줌                                |
| -q, --quiet, --silent           | 패턴과 일치하는 단어가 있든 없든 아무것도 안 보여줌          |
| -s, --no-messages               | 존재하지 않거나 읽을 수 없는 파일에 대한 오류 메시지 안 보여줌 |



##### -c, --count 옵션을 사용하는 경우

```sh
# expression과 일치하는 문자열 개수 출력
grep -c 'expression' expression.txt
2
```



##### --color 옵션을 사용하는 경우

```sh
# 검색한 문자열을 연두색으로 보여주도록 설정
GREP_COLOR="1;32" grep --color 'expression' expression.txt
# Description: regular expression test file
This is an example file for testing regular expressions.	This example file includes control characters.
```



##### -L, --files-witout-match 옵션을 사용하는 경우

```sh
# 패턴이 포함되어 있지 않은 파일 목록 검색
grep -L 'express' ./*
./2022-08-24-16-44-05.088-VBoxSVC-3192.log
./2022-08-24-16-44-06.002-VBoxHeadless-3761.log
./2022-08-24-16-44-06.005-VBoxHeadless-3796.log
./2022-08-24-16-44-06.010-VBoxHeadless-3726.log
./2022-08-24-16-44-06.018-VBoxHeadless-3320.log
./2022-08-29-03-53-10.021-VBoxSVC-42465.log
```



##### -l, --files-with-matchs 옵션을 사용하는 경우

```sh
# 패턴이 포함된 파일 목록 검색
grep -l 'express' ./*
./expression.txt
```



##### -m 라인 수, --max_count=라인 수 옵션을 사용하는 경우

```sh
# 검색 라인을 5줄만 출력
grep -m 5 "^\[[[:lower:]]*\]" /etc/nova/nova.conf
[api]
[barbican]
[cache]
[cells]
[cinder]
```



##### -o, --only-matching 옵션을 사용하는 경우

```sh
# express로 시작하고 영문소문자로 끝나는 단어 검색
grep -o 'express[[:lower:]]*' expression.txt
expression
expressions
```



##### -q, --quiet, --silent 옵션을 사용하는 경우

```sh
# -q를 사용하지 않고 검색하면 검색 결과를 보여줌
grep 'help' expression.txt
Do you have any questions? or Do you need any help?

# -q를 사용하면 검색 결과를 보여주지 않음
grep -q 'help' expression.txt

```



##### -s, --no-messages 옵션을 사용하는 경우

```sh
# -s 옵션없이 존재하지 않는 파일명에서 패턴을 검색한 경우 에러 메시지 보여줌
grep 'help' express.txt
grep: express.txt: No such file or directory

# -s 옵션 사용 시 에러 메시지 보여주지 않음
grep -s 'help' express.txt

```

```
셸 스크립트에서 결과를 변수로 저장해 처리할 경우 유용하며, 일반적인 상황에서는 사용하지 않는 것이 좋음
```

---



### 4) 출력라인 제어 관련 옵션

| 옵션                    | 설명                                                         |
| ----------------------- | ------------------------------------------------------------ |
| -b, --byte-offset       | 패턴이 포함된 출력라인의 바이트 수를 라인 제일 앞부분에 보여줌 |
| -H, --with-filename     | 패턴이 포함된 출력라인의 파일명을 라인 제일 앞부분에 보여줌  |
| -h, --no-filename       | -H 옵션과 반대로 패턴이 포함된 출력라인의 파일명을 보여주지 않음 |
| --label=LABEL           | 파일 목록에서 특정 파일을 검색할 경우<br>검색라인 제일 앞부분에 라벨을 함께 보여줌 -H와 함께 사용해야 함 |
| -n, --line-number       | 패턴이 포함된 출력라인 제일 앞부분에 라인 번호를 함께 보여줌 |
| -T, --initial-tab       | 라인 번호나 파일명이 함께 출력될 경우 탭과 함께 간격을 조정하여 보여줌 |
| -u, --unix-byte-offsets | 패턴이 포함된 출력라인의 바이트 수를 유닉스 스타일로 보여줌<br>-b 옵션과 함께 사용해야 함 |
| -Z, --null              | 패턴이 포함된 파일명 출력 시 뉴라인 없이 한 줄로 보여줌<br>-l 옵션과 함께 사용해야 함 |



##### -b, --byte-offset 옵션을 사용하는 경우

```sh
# 각 라인 앞에 바이트 수를 함께 보여줌
grep -b 'express' expression.txt
150:# Description: regular expression test file
288:This is an example file for testing regular expressions.	This example file includes control characters.
```



##### -H, --with-filename 옵션을 사용하는 경우

```sh
# -H 옵션없이 검색했을 경우 파일명을 보여주지 않음
grep 'express' expression.txt
# Description: regular expression test file
This is an example file for testing regular expressions.	This example file includes control characters

# -H 옵션으로 검색했을 경우 각 라인 앞에 파일명을 함께 보여줌
grep -H 'express' expression.txt
expression.txt:# Description: regular expression test file
expression.txt:This is an example file for testing regular expressions.	This example file includes control characters.
```



##### -h, --no-filename 옵션을 사용하는 경우

```sh
# 디렉터리 내 모든 파일에서 패턴을 검색할 경우 파일명을 함께 보여줌
grep 'express' ./*
./expression.txt:# Description: regular expression test file
./expression.txt:This is an example file for testing regular expressions.	This example file includes control characters.

# -h 옵션을 사용해 파일명을 제거하고, 검색 결과만 보여줌
grep -h 'express' ./*
# Description: regular expression test file
This is an example file for testing regular expressions.	This example file includes control characters.
```



##### --label=LABEL 옵션을 사용하는 경우

```sh
# 검색된 파일 정보 앞에 file이라는 라벨을 붙여줌
ls -l | grep --label=file -H express
file:-rw-rw-r--  1 jngmk jngmk  717 Sep 13 08:27 expression.txt
```



##### -n, --line-number 옵션을 사용하는 경우

```sh
# -n 옵션을 이용하여 라인 번호 출력
grep -n 'question' expression.txt
23:Do you have any questions? or Do you need any help?
24:If you have any questions, Please send a mail to the email below.
```



##### -T, --initial-tab 옵션을 사용하는 경우

```sh
# -T 옵션을 이용하여 라인 번호 간격을 주므로 가독성을 높임
grep -T -n 'question' expression.txt
 23:	Do you have any questions? or Do you need any help?
 24:	If you have any questions, Please send a mail to the email below.
```



##### -u, --unix-byte-offsets 옵션을 사용하는 경우

```sh
# 라인 앞에 바이트 수를 보여줌
grep -u -b 'question' expression.txt 
539:Do you have any questions? or Do you need any help?
591:If you have any questions, Please send a mail to the email below.
```



##### -Z, --null 옵션을 사용하는 경우

```sh
# 테스트를 위한 expression.txt를 test.txt로 복사
cp expression.txt test.txt

# express라는 패턴을 현재 디렉터리에서 -Z -l 옵션과 함께 검색하면 파일명을 한줄로 보여줌
grep -Z -l 'express' ./*
./expression.txt./test.txt
```

```
검색된 파일명을 for문과 같은 제어문의 인자값으로 사용하기 좋음.
```

---



### 5) 컨텍스트 라인 제어 관련 옵션

| 옵션                                        | 설명                                                         |
| ------------------------------------------- | ------------------------------------------------------------ |
| -A 라인 수<br>--after-context=라인 수       | 패턴이 포함된 라인 후에 선언한 라인 수에 해당하는 라인만큼<br>뒤로 라인을 추가하여 보여줌 |
| -B 라인 수<br>--before-context=라인 수      | 패턴이 포함된 라인 전에 선언한 라인 수에 해당하는 라인만큼<br>앞에 라인을 추가하여 보여줌 |
| -C 라인 수<br>-라인 수<br>--context=라인 수 | 패턴이 포함된 라인 전, 후에 선언한 라인 수에 해당하는 라인만큼<br>앞, 뒤로 라인을 추가하여 보여줌 |
| --group-separator=그룹구분 기호             | 옵션 -A, -B, -C와 함께 사용할 때 패턴을 기준으로 그룹핑을 해주며<br>설정한 그룹구분 기호와 함께 그룹핑을 해 줌 |
| --no-group-separator                        | 옵션 -A, -B, -C와 함께 사용할 때 패턴을 기준으로 그룹핑 해주지만<br>해당 옵션을 사용하면 그룹핑을 하지 않음 |



##### -A 라인 수, --after-context=라인 수 옵션을 사용하는 경우

```sh
# 검색된 라인 아래 2줄을 더 보여줌
grep -A 2 'question' expression.txt
Do you have any questions? or Do you need any help?
If you have any questions, Please send a mail to the email below.

# Contacts
```



##### -B 라인 수, --before-context=라인 수 옵션을 사용하는 경우

```sh
# 검색된 라인 위 2줄을 더 보여줌
grep -B 2 'question' expression.txt

# Help
Do you have any questions? or Do you need any help?
If you have any questions, Please send a mail to the email below.
```



##### -C 라인 수, -라인 수, --context=라인 수 옵션을 사용하는 경우

```sh
# 검색된 라인 위, 아래 2줄을 더 보여줌
grep -C 2 'question' expression.txt

# Help
Do you have any questions? or Do you need any help?
If you have any questions, Please send a mail to the email below.

# Contacts
```



##### --group-separator=그룹구분 기호 옵션을 사용하는 경우

```sh
# 검색된 패턴 라인 위에 그룹구분 기호를 함께 보여줌
grep -A 1 --group-separator='======' '# [[:alpha:]]' expression.txt
# Date: 2020-05-05
# Author: NaleeJang
# Description: regular expression test file
#===========================================#
======
# System Information
CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
======
# Help
Do you have any questions? or Do you need any help?
======
# Contacts
e-mail: nalee999@gmail.com
```



##### --no-group-separator 옵션을 사용하는 경우

```sh
# 기본 그룹구분 기호인 '--'를 함께 보여줌
grep -A 1 '# [[:alpha:]]' expression.txt
# Date: 2020-05-05
# Author: NaleeJang
# Description: regular expression test file
#===========================================#
--
# System Information
CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
--
# Help
Do you have any questions? or Do you need any help?
--
# Contacts
e-mail: nalee999@gmail.com

# 그룹구분 기호없이 검색 결과를 보여줌
grep -A 1 --no-group-separator '# [[:alpha:]]' expression.txt
# Date: 2020-05-05
# Author: NaleeJang
# Description: regular expression test file
#===========================================#
# System Information
CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
# Help
Do you have any questions? or Do you need any help?
# Contacts
e-mail: nalee999@gmail.com
```

---



### 6) 파일 및 디렉터리 관련 옵션

| 옵션                              | 설명                                                         |
| --------------------------------- | ------------------------------------------------------------ |
| -a<br>--text                      | 바이너리 파일에서 해당 패턴을 검색할 수 있음                 |
| --binary-files=TYPE               | TYPE은 기본적으로 binary이며<br>text를 사용할 경우 -a 옵션과 동일한 기능을 가짐 |
| -D ACTION<br>--devices=ACTION     | ACTION은 read와 skip이 있으며<br>read일 경우 디바이스에서 패턴을 검색하고<br>skip일 경우 디바이스를 검색하지 않음 |
| -d ACTION<br>--directories=ACTION | read일 경우 디렉터리에서 패턴을 검색하고<br>skip일 경우 디렉터리는 검색하지 않음 |
| --exclude=GLOB                    | GLOB은 검색 대상에서 제외하고자 하는 파일명을 의미하며<br>파일명은 *, ?, /를 사용할 수 있음 |
| --exclude-from=FILE               | 검색 대상에서 제외할 파일이 명확할 경우 사용할 수 있음       |
| --exclude-dir=DIR                 | 재귀 검색에서 패턴 DIR과 일치하지 않는 디렉터리 제외         |
| -I (대문자 i)                     | 일치하는 데이터를 포함하지 않은 것처럼 이진 파일을 처리함<br>--binary-files=without-match 옵션과 동일 |
| --include=GLOB                    | --exclude 옵션과 반대로 파일명에 해당하는 파일에서만 검색 가능 |
| -r<br>--recursive                 | 검색하고자 하는 디렉터리의 하위 디렉터리 파일도 검색 가능    |
| -R<br>--dereference-recursive     | 검색하고자 하는 디렉터리의 하위 디렉터리 파일 및 심볼릭 파일까지 검색 가능 |



##### -a, --text 옵션을 사용하는 경우

```sh
# 테스트를 위한 grep 명령어 파일 복사
cp /bin/grep ./grep_binary_test

# 복사한 바이너리 파일인 grep_binary_test에서 Context라는 단어 검색
grep -a '^Context' grep_binary_test
Context control:
```



##### --binary-files=TYPE 옵션을 사용하는 경우

```sh
# 바이너리 파일 타입이 bianry일 때는 파일에 매칭되는 패턴이 있다는 메시지를 보여줌
grep --binary-files=binary '^Context' grep_binary_test
Binary file grep_binary_test matches

# 바이너리 파일 타입이 text일 때는 패턴이 포함된 라인을 보여줌
grep --binary-files=text '^Context' grep_binary_test
Context control:
```

```
TYPE에는 binary, text, without-match가 있음.
text 같은 경우에는 바이너리 파일의 이진 문자가 그대로 출력될 수 있으며,
이는 터미널 프롬프트에 영향을 줄 수 있음.
```



##### -D ACTION, --devices=ACTION 옵션을 사용하는 경우

```sh
# 디바이스 파일을 검색하려고 시도하다가 권한 에러 발생
sudo grep -D read 'loop' /dev/mem
grep: /dev/mem: Operation not permitted

# 디바이스 파일을 검색하지 않음
sudo grep -D skip 'loop' /dev/mem

```



##### -d ACTION, --directories=ACTION 옵션을 사용하는 경우

```sh
# 테스트를 위한 디렉터리 생성
mkdir test-dir

# 현재 경로의 모든 파일 및 디렉터리에서 CPU라는 단어 검색
grep -d read 'CPU' ./*
./expression.txt:CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
grep: ./test-dir: Is a directory
./test.txt:CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz

# 현재 경로의 디렉터리는 제외하고 CPU라는 단어 검색
grep -d skip 'CPU' ./*
./expression.txt:CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
./test.txt:CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
```



##### --exclude=GLOB 옵션을 사용하는 경우

```sh
# express로 시작하는 파일을 제외하고 검색
grep --exclude=express* 'CPU' ./*
./test.txt:CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
```



##### --exclude-dir=DIR 옵션을 사용하는 경우

```sh
# 테스트를 위해 파일 이동
mv test.txt test-dir

# -r 옵션만 사용하여 검색하면 test-dir 내의 test.txt 파일도 함께 검색
grep -r 'mail' ./*
./expression.txt: ~
./expression.txt: ~
./test-dir/test.txt: ~
./test-dir/test.txt: ~

# 제외대상 디렉터리로 test-dir을 선언하면 해당 디렉터리는 검색 대상에서 제외
grep -r --exclude-dir=test-dir 'mail' ./*
./expression.txt: ~
./expression.txt: ~
```



##### -I 옵션을 사용하는 경우

```sh
# 바이너리 파일에 일치하는 단어가 있어도 없는 것처럼 보여줌
grep -I '^Context' grep_binary_test

```



##### --include=GLOB 옵션을 사용하는 경우

```sh
# express로 시작하는 파일에서 CPU라는 단어 검색
grep --include=express* 'CPU' ./*
./expression.txt:CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
```



##### -r, --recursive 옵션을 사용하는 경우

```sh
# -r 옵션을 이용하여 하위 디렉터리까지 검색
grep -r --include=expression* 'CPU' ./*
./anaconda3/lib/python3.9/site-packages/tables/expression.py:    required to perform them (basically main memory and CPU cache memory).
./expression.txt:CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
```



##### -R, --dereference-recursive 옵션을 사용하는 경우

```sh
# 테스트를 위한 expression.txt를 바라보는 express.txt 심볼릭 링크 생성
cd test-dir
ln -s ../expression.txt express.txt
ls -l express.txt
lrwxrwxrwx 1 jngmk jngmk 17 Sep 13 09:53 express.txt -> ../expression.txt
cd ..

# -r 옵션을 사용했을 경우에는 express.txt 파일은 검색 대상에서 제외
grep -r 'nalee999' ./*
./expression.txt:e-mail: nalee999@gmail.com

# -R 옵션을 사용했을 경우에는 express.txt 파일도 검색되었음
grep -R 'nalee999' ./*
./expression.txt:e-mail: nalee999@gmail.com
./test-dir/express.txt:e-mail: nalee999@gmail.com
```

---



### 7) 기타 옵션

| 옵션              | 설명                                                         |
| ----------------- | ------------------------------------------------------------ |
| --line-buffered   | grep의 경우 패턴에 일치하는 모든 라인 검색이 완료된 후 화면에 보여주지만<br>--line-buffered 옵션을 사용하면 검색된 라인별로 바로 보여줌<br>많은 양의 로그 검색 시 유용하나 많이 사용하면 성능에 영향을 줄 수 있음 |
| -U<br>--binary    | 검색 대상 파일을 바이너리로 취급하여<br>캐리지 리턴(CR)이나 라인피드(LF) 같은 문자를 제거하여 검색함 |
| -z<br>--null-data | 패턴이 포함된 파일의 전체 내용을 출력함                      |



##### --line-buffered 옵션을 사용하는 경우

```sh
# --line-buffered 옵션은 일반적으로 양이 많은 로그 파일 등을 검색할 때 사용함
sudo grep --line-buffered -i -r 'error' /var/log/*
/var/log/vbox-setup.log.1:make[1]: *** [Makefile:1881: /tmp/vbox.0] Error 2
/var/log/vbox-setup.log.1:make: *** [/tmp/vbox.0/Makefile-footer.gmk:117: vboxdrv] Error 2
...
```

```
많은 양의 로그를 검색한다던가, 사이즈가 매우 큰 파일을 검색할 경우
파일을 전부 검색한 후 해당 결과를 출력해 주는 grep의 특성을 조정해 주는 옵션.
매우 큰 사이즈의 파일을 검색할 경우에는 검색 결과를 메모리에 저장하는 시간이 걸리는데,
--line-buffered 옵션을 사용하면 검색한 결과를 라인별로 바로바로 결과로 보여줌.
메모리에 무리를 줄 수 있으므로 주의해서 사용해야 함.
```



##### -U, --binary 옵션을 사용하는 경우

```sh
# -U 옵션을 사용하여 검색
grep -U 'CPU' expression.txt
CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
```

```
옵션 -U는 일반 텍스트 파일을 바이너리 파일로 취급하여 캐리지 리턴이나 라인피드와 같은 문자를 제거하고 검색을 진행.
일반적인 경우에는 옵션을 사용했을 때와 사용하지 않을 때의 차이는 없음.
```



##### -z, --null-data 옵션을 사용하는 경우

```sh
# 파일 내용 안에서 특정 문자열 검색
grep -z 'CPU' ./*.txt
====================
 Regular Expression
====================
  
#===========================================#
# Date: 2020-05-05
# Author: NaleeJang
# Description: regular expression test file
#===========================================#


Today is 05-May-2020.
Current time is 6:04PM.
This is an example file for testing regular expressions.	This example file includes control characters.

# System Information
CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
Memory size is 32GiB
Disk is 512 GB
IP Address is 192.168.35.7

# Help
Do you have any questions? or Do you need any help?
If you have any questions, Please send a mail to the email below.

# Contacts
e-mail: nalee999@gmail.com
phone: 010-2222-5668
```

```
옵션 -z는 파일 내용을 그대로 보여주는 옵션.
보통 grep은 해당 패턴이 있는 라인만 검색 결과로 출력하는 반면 -z 옵션을 사용하면 파일 전체를 보여주고
패턴에 해당하는 단어만 하이라이팅하여 보여줌
```

