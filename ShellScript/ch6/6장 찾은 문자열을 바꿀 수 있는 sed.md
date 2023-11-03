# 6장 찾은 문자열을 바꿀 수 있는 sed

## 1. 사용법

```
sed는 스트림 편집기.
스트림 편집기는 입력 스트림에서 텍스트 변환을 수행하는 데 사용됨.
입력 스트림은 텍스트를 변경하고자 하는 대상 파일이며,
스크립트는 어떤 텍스트를 어떻게 변환할지 정의하는 일을 말함.
```



#### 기본 사용법

```
sed의 가장 기본적인 사용법은 옵션, 어떤 텍스트를 어떻게 변경할 것인지를 기술한 스크립트,
대상 파일이 필요함. 그리고 스크립트는 대상 파일의 범위를 지정하는 어드레스와 명령어로 이루어짐.
어드레스가 생략되면 sed는 대상 파일 전체를 대상으로 명령어를 수행함.

sed [옵션] '어드레스 {명령어}' 대상 파일
```



#### 예제 1

```
예를 들어 ssh로 원격 서버를 접근할 때 보안을 위해 root 사용자 계정으로는 접근을 못하게 설정하는 경우가 있음.
이런 경우 sshd_config 파일의 PermitRootLogin이라는 옵션을 yes로 설정하면 root 계정 로그인 차단 가능.
PermitRootLogin은 주석 처리가 되어 있음. 이때 sed를 이용해 주석을 없앨 수 있음.
```

```sh
# grep을 이용해 변경할 대상 문자열 확인
cat /etc/ssh/sshd_config | grep '^#PermitRoot'
#PermitRootLogin yes

# /etc/ssh/sshd_config 파일의 #PermitRoot를 PermitRoot로 변경
sed 's/#PermitRoot/PermitRoot/' /etc/ssh/sshd_config | grep '^PermitRoot'
PermitRootLogin yes
```



#### 예제 2

```
찾을 문자열과 변경하고자 하는 문자열을 스크립트로 작성한 파일을 이용하여 대상 파일의 문자열을 변경하는 방법

sed [옵션] -f 스크립트파일 대상 파일
```

```sh
# 스크립트 내용을 echo를 이용해 sed-script.txt에 저장
echo "s/#PermitRootLogin/PermitRootLogin/" > sed-script.txt

# -f 옵션을 이용하여 저장한 스크립트 파일을 이용하여 sed 수행
sed -f sed-script.txt /etc/ssh/sshd_config | grep '^PermitRoot'
PermitRootLogin yes
```



#### 예제 3

```
리눅스 명령어나 애플리케이션의 명령어를 통해 얻은 결과를 이용해 해당 결과에서 찾은 문자열을 변경할 때 주로 이용.

명령어 | sed [옵션] '{스크립트}'
```

```sh
# cat을 이용해 /etc/ssh/sshd_config 내용을 확인하고, sed는 cat의 결과에서 해당 문자열 변경
cat /etc/ssh/sshd_config | sed -e 's/#PermitRoot/PermitRoot/' | grep '^PermitRoot'
PermitRootLogin yes
```

---



## 2. sed 스크립트

```
sed 스크립트는 어떤 범위의 어떤 문자열이 포함된 라인을 추출하던지
특정 문자열을 원하는 다른 문자열로 변경할 것인지 명시하는 일.
여기서 어떤 범위는 어드레스에 해당하며, 특정 문자열을 추출하거나 변경하는 일은 명령어라고 함.
어드레스는 옵션처럼 생략될 수도 있으며, 어드레스가 생략되면 sed는 대상 파일 전체에서 특정 문자열을 찾고 변경함.
```



### 1) 어드레스

```
어드레스는 대상 파일에서 어떤 범위에 해당함.
어드레스가 정의되지 않았을 경우에는 대상 파일 전체에서 특정 문자열을 찾거나 명령어를 수행함.
어드레스는 특정 라인일 수도 있고, 정규 표현식과 같은 패턴일 수도 있음.
또는 특정 라인부터 특정 패턴이 포함된 라인까지이거나 특정 패턴이 포함된 라인부터 명시한 라인 수까지일 수도 있음.
```

##### 어드레스 종류

| 옵션        | 설명                                                         |
| ----------- | ------------------------------------------------------------ |
| number      | 명시된 숫자에 해당하는 라인 번호일 경우 다음 명령어 수행     |
| number~step | 명시된 숫자에 해당하는 라인부터 명시한 단계만큼 해당 라인을 스킵한 다음<br>라인일 경우 다음 명령어 수행 |
| $           | 파일의 마지막 라인일 경우 다음 명령어를 수행함               |
| /regexp/    | 명시한 정규 표현식과 일치하는 라인일 경우 다음 명령어를 수행함 |
| \cregexpc   | 명시한 정규 표현식과 일치하는 라인일 경우 다음 명령어를 수행함 |
| 0,addr2     | 1번째 라인부터 addr2가 포함된 라인까지가 범위이며, addr2는 정규 표현식이어야 함 |
| addr1,+N    | addr1이 포함된 라인부터 +N라인까지가 범위이며,<br>addr1은 정규표현식이어야 하며 N은 숫자여야 함 |
| addr1,~N    | addr1이 포함된 라인을 기준으로 N라인까지가 범위이며,<br>addr1은 정규 표현식이어야 하며 N은 숫자여야 함 |



##### 예제 파일 hosts

```
# This is Sed Sample File
# We will test to replace from a-text to b-text.
# It was created by NaleeJang.

127.0.0.1   localhost

# Development
192.168.100.250 git.example.com
192.168.100.10  servera.example.com
192.168.100.11  dev.example.com

# Test

172.10.2.12 test1.example.com
172.10.2.13 test2.example.com

# Production
122.10.10.31 service.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com
```



##### number 어드레스를 사용할 경우

```sh
# 5번째 줄을 출력함
sed -n '5 p' hosts
127.0.0.1   localhost
```

```
어드레스 number는 명시한 숫자에 해당하는 라인을 의미.
hosts 파일의 5번째 라인을 출력하라는 명령어로,
-n 옵션은 대상 파일 내용을 출력하지 않겠다는 의미의 옵션이며,
숫자 5는 대상 파일의 5번째 라인을 의미함.
p는 print의 약자로 현재 어드레스에 의해 정의된 범위의 내용을 출력하라는 의미.
숫자 5는 어드레스, p는 명령어에 해당 됨.
```



##### first~step 어드레스를 사용할 경우

```sh
# 1번째 라인부터 시작하여 3라인마다 해당 라인 번호 출력
sed -n '1~3 =' hosts
1
4
7
10
13
16
19
```

```
어드레스 first~step은 모두 숫자로 명시해야 함.
첫 번째로 명시한 숫자는 숫자에 해당하는 라인을 의미하며,
두 번째 명시한 숫자는 첫 번째 명시한 숫자에 해당하는 라인부터 두 번째 명시한 숫자만큼 라인을 건너뛰라는 의미.
= 기호는 현재 읽어들인 라인의 라인 번호를 출력하라는 의미.
```



##### $ 어드레스를 사용할 경우

```sh
# 파일의 마지막 라인 번호 출력
sed -n '$ =' hosts
20

# 파일의 마지막 라인 문자열 출력
sed -n '$ p' hosts
122.10.10.33 service2.example.com
```

```
$ 어드레스는 파일의 마지막 라인을 의미함.
'$ ='는 마지막 라인의 라인 번호를 출력하라는 의미이며
'$ p'는 마지막 라인의 내용을 출력하라는 의미.
```



##### /regexp/ 어드레스를 사용할 경우

```sh
# test와 숫자로 시작하는 문자열이 포함된 라인 출력
sed -n '/test[0-9].*/ p' hosts
172.10.2.12 test1.example.com
172.10.2.13 test2.example.com
```



##### \cregexpc 어드레스를 사용할 경우

```sh
# test와 숫자로 시작하는 문자열이 포함된 라인 출력
sed -n '\ctest[0-9].*c p' hosts
172.10.2.12 test1.example.com
172.10.2.13 test2.example.com
```



##### 0,addr2 어드레스를 사용할 경우

```sh
# 1번째 라인부터 # Devel로 시작하는 문자열이 있는 라인까지 출력
sed -n '0,/^# Devel*/ p' hosts
# This is Sed Sample File
# We will test to replace from a-text to b-text.
# It was created by NaleeJang.

127.0.0.1   localhost

# Development
```



##### addr1,+N 어드레스를 사용할 경우

```sh
# # Devel로 시작하는 라인부터 아래 3줄까지 출력
sed -n '/^# Devel*/,+3 p' hosts
# Development
192.168.100.250 git.example.com
192.168.100.10  servera.example.com
192.168.100.11  dev.example.com
```



##### addr1,~N 어드레스를 사용할 경우

```sh
# # Devel이 포함된 라인을 기준으로 3번째 라인까지 출력
sed -n '/^# Devel*/,~3 p' hosts
# Development
192.168.100.250 git.example.com
192.168.100.10  servera.example.com
```

---



### 2) 명령어

```
sed 명령어에는 어드레스를 필요로 하지 않거나,
숫자나 정규 표현식과 같은 단일 어드레스를 사용할 때 사용할 수 있는 명령어와 어드레스 범위를 허용하는 명령어들이 있음.
어드레스를 필요로 하지 않는 명령어는 라벨, 주석, 블록이 있으며,
단일 어드레스를 사용할 수 있는 명령어와 어드레스 범위를 허용하는 명령어에는
주로 문자열 추가, 삭제, 파일 저장과 같은 명령어들이 있음.
```



#### 0 or 1 어드레스 명령어

```
0 어드레스 명령어에는 라벨, 주석, 블록과 같이 파일 내용에 아무런 영향을 주지 않는 명령어와
문자열 추가, 삽입, 스크립트 종료, 파일 내용 추가와 같은 명령어들로 어드레스가 필요한 명령어가 있음.
```

| 옵션     | 설명                   |
| -------- | ---------------------- |
| :label   | 라벨                   |
| #comment | 주석                   |
| {...}    | 블록                   |
| =        | 현재 라인 번호 출력    |
| a \text  | 문자열 추가            |
| i \text  | 문자열 삽입            |
| q        | sed 스크립트 실행 종료 |
| Q        | sed 스크립트 실행 종료 |
| r 파일명 | 파일 내용 추가         |
| R 파일명 | 파일의 첫 라인 추가    |



##### :label, #comment, {...}, = 명령어를 사용할 경우

```sh
# # Test로 시작하는 라인부터 +3라인까지의 라인 번호 출력
cat sed-script.txt
/# Test/,+3 {
=
# first label
:label1
}

# 파일을 이용하여 sed 실행
sed -n -f sed-script.txt hosts
12
13
14
15
```

```
/# Test/,+3은 어드레스 범위로 # Test가 포함된 라인부터 3번째 라인까지가 대상범위이며,
해당 범위의 명령어들을 중괄호{}로 블록화하였음.
중괄호 안에 오는 명령어들은 현재 라인 번호를 출력하는 = 명령어와 #으로 시작하는 주석,
콜론:으로 시작하는 라벨이 있음.
```



##### a \text 명령어를 사용할 경우

```sh
# 172.10.2.3이 있는 다음 라인에 새 주소 172.10.2.14 추가
sed -n '/172.10.2.13/ { a \
172.10.2.14 test3.example.com
p }' hosts
172.10.2.13 test2.example.com
172.10.2.14 test3.example.com
```

```
172.10.2.13이 있는 라인 다음에 172.10.2.14 test3.example.com을 추가한 후 출력하는 예.
sed에서 사용되는 명령어들은 한 라인에 한 명령어만 사용할 수 있음.
따라서 여러 줄의 명령어를 사용하려면 위와 같이 중괄호{}로 블록을 만들어 주어야 함.
```



##### i \text 명령어를 사용하는 경우

```sh
# 172.10.2.13에 있는 라인 위에 새 주소 172.10.2.14 추가
sed -n '/172.10.2.13/ { i \
172.10.2.14 test3.example.com
p }' hosts
172.10.2.14 test3.example.com
172.10.2.13 test2.example.com
```



##### q 명령어를 사용할 경우

```sh
# test2.example.com을 출력하지 않고 종료
sed -n '/172.10.2.13/ { a \
172.10.2.14 test3.example.com
q
p }' hosts
172.10.2.14 test3.example.com
```

```
q는 수행 중이던 스크립트를 종료할 때 사용하는 명령어.
a 명령어에 의해 추가할 172.10.2.14 test3.example.com을 추가하지 않은 채 추가할 텍스트만 출력하고 sed 실행 종료.
```



##### Q 명령어를 사용할 경우

```sh
# 아무것도 출력하지 않고 종료
sed -n '/127.10.2.13/ { a \
172.10.2.14 test3.example.com
Q
p }' hosts
```



##### r 파일명 명령어를 사용할 경우

```sh
# 새 IP 주소를 sed-read.txt 파일에 저장
cat sed-read.txt
172.10.2.14 test3.example.com
172.10.2.15 test4.example.com

# 172.10.2.13 라인 뒤에 파일의 모든 새 IP 추가
sed -n '/172.10.2.13/ { r sed-read.txt
p }' hosts
172.10.2.13 test2.example.com
172.10.2.14 test3.example.com
172.10.2.15 test4.example.com
```



##### R 파일명 명령어를 사용할 경우

```sh
# 172.10.2.13 라인 뒤에 파일의 첫 번째 새 IP만 추가
sed -n '/172.10.2.13/ { R sed-read.txt
p }' hosts
172.10.2.13 test2.example.com
172.10.2.14 test3.example.com
```

```
R 파일명 명령어는 r 파일명과는 다르게 해당 파일의 첫 번째 라인만 읽어 추가함.
```

---



#### 어드레스 범위 명령어

```
어드레스 범위는 특정 라인부터 특정 라인까지를 의미하며,
이런 어드레스를 허용하는 명령어들에는 문자열 변경, 삭제, 출력, 라벨 분기와 같은 명령어들이 있음.
```

| 옵션                  | 라벨                                                         |
| --------------------- | ------------------------------------------------------------ |
| b label               | 라벨을 호출함                                                |
| c \text               | 앞에서 명시된 패턴이 포함된 라인을 text 문자열로 변경        |
| d, D                  | 앞에서 명시된 패턴 삭제                                      |
| h, H                  | 패턴 공간을 홀드 공간에 복사/추가                            |
| g, G                  | 홀드 공간을 패턴 공간에 복사/추가                            |
| l                     | 입력된 데이터의 현재 라인 출력                               |
| l width               | 명시한 너비에 맞게 입력된 데이터의 현재 라인 출력            |
| n                     | 패턴 공간을 입력의 다음 행으로 대체                          |
| N                     | 줄바꿈문자를 패턴 공간에 더하고 입력의 다음 줄을 읽어 패턴 스페이스에 덧붙입 |
| p                     | 현재 패턴 공간 출력                                          |
| P                     | 패턴 공간을 출력하되, 뉴라인이 있는 라인은 뉴라인까지 출력   |
| s/regexp/replacement/ | 정규 표현식에 해당하는 데이터를 그 다음 오는 데이터로 변경   |
| t label / T label     | 앞에서 선언된 명령어 실행 후 라벨로 분기                     |
| w 파일명 / W 파일명   | 명시한 파일에 현재 패턴 공간을 저장                          |
| x                     | 홀드와 패턴 공간의 컨텐츠를 교환                             |
| y/source/dest/        | 패턴이 포함된 라인의 모든 문자 하나하나를 dest 문자열로 변경 |



##### b label 명령어를 사용할 경우

```sh
# 입력된 해당 라인에 값이 없으면 문자열 변경을 수행하지 않고, 라벨 호출
cat sed-script1.txt
/# Test/,+3 {
# if input line is empty, doesn’t execute replacing
/^$/ b label1
s/[tT]est/dev/
: label1
p
}

# 스크립트 수행 결과 test가 dev로 변경
sed -n -f sed-script1.txt hosts
# dev

172.10.2.12 dev1.example.com
172.10.2.13 dev2.example.com
```



##### c \text 명령어를 사용할 경우

```sh
# service.e가 있는 라인의 값을 변경
sed '/service.e/ c \122.10.10.30 vip.service.example.com' hosts | tail -n 4
# Production
122.10.10.30 vip.service.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com
```



##### d와 D 명령어를 사용할 경우

```sh
# 뉴라인 상관없이 test가 포함된 라인 삭제
sed -n '0,/NaleeJang/ {
s/We will test to replace/We will test to\nreplace/
/test/ d
p }' hosts
# This is Sed Sample File
# It was created by NaleeJang.

# 패턴 공간에 포함된 뉴라인을 인식한 후 text가 포함된 라인 삭제
sed -n '0,/NaleeJang/ {
s/We will test to replace/We will test \nreplace/
/test/ D
p}' hosts
# This is Sed Sample File
replace from a-text to b-text.
# It was created by NaleeJang.
```

```
명령어 d와 D는 앞에서 명시한 어드레스에 해당하는 문자열이 포함된 라인을 삭제함.
이때, d 명령어는 뉴라인과 상관없이 해당 문자열이 포함된 라인을 삭제하며,
D 명령어는 패턴 공간의 뉴라인을 인식하여 해당 뉴라인까지만 삭제함.
```



##### h와 H 명령어를 사용할 경우

```sh
# 홀드 버퍼로 복사
sed -n '/Product/,+3 {
s/Production/Service/
h
p }' hosts
# Service
122.10.10.31 service.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com
```

```
명령어 h 또는 H는 패턴 버퍼를 홀드 버퍼로 복사함.
위의 예제에서 Production을 Service로 변경한 후 패턴 버퍼의 내용을 홀드 버퍼로 복사하고
패턴 버퍼의 내용을 출력한 것.
문자열 변경은 패턴 버퍼에서 수행했고, 그 이후 홀드 버퍼로 복사함.

sed는 명령을 수행할 때 대상 파일의 내용을 한 줄씩 읽어 패턴 버퍼(패턴 공간)에 삽입함.
패턴 버퍼는 현재 정보를 저장하는 버퍼 메모리이며, sed를 통해 출력을 실행하면 패턴 버퍼의 내용이 인쇄됨.
이 외에도 홀드 버퍼라 불리는 임시 버퍼 메모리 공간이 있음.
홀드 버퍼에는 대상 파일의 라인 수만큼의 빈 공간을 가지고 있으며, sed가 다른 라인을 처리할 때 재사용할 수 있음.
```



##### g와 G 명령어를 사용할 경우

```sh
# 패턴 버퍼와 홀드 버퍼 사용 예
sed -n '/Product/,+3 {
s/Production/Service/
h
s/122.10.10/199.9.9/
g
p }' hosts
# Service
122.10.10.31 service.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com

# 대문자 H와 G를 사용할 경우 sed의 문자열 변경과정을 볼 수 있음
sed -n '/Product/,+3 {
s/Production/Service/
H
s/122.10.10/199.9.9/
G
p }' hosts
# Service

# Service
199.9.9.31 service.example.com

# Service
122.10.10.31 service.example.com
199.9.9.32 service1.example.com

# Service
122.10.10.31 service.example.com
122.10.10.32 service1.example.com
199.9.9.33 service2.example.com

# Service
122.10.10.31 service.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com
```



##### l 명령어를 사용할 경우

```sh
# Production이 포함된 라인부터 아래 3라인까지 현재 읽어들인 라인 출력
sed -n '/Product/,+3 l' hosts
# Production$
122.10.10.31 service.example.com$
122.10.10.32 service1.example.com$
122.10.10.33 service2.example.com$
```

```
l 명령어는 패턴 버퍼의 내용을 출력하는 p 명령어와는 다르게 문자의 끝을 알리는 $ 기호와 같은 특수 기회를 함께 출력.
```



##### l width 명령어를 사용할 경우

```sh
# 라인 너비를 20에 맞추어 보여줌
sed -n '/Product/,+3 l 20' hosts
# Production$
122.10.10.31 servic\
e.example.com$
122.10.10.32 servic\
e1.example.com$
122.10.10.33 servic\
e2.example.com$
```



##### n과 N 명령어를 사용할 경우

```sh
sed -n '/Product/,+3 {
n
p }' hosts
122.10.10.31 service.example.com
122.10.10.33 service2.example.com

sed -n '/Product/,+3 {
p
N }' hosts
122.10.10.32 service1.example.com
```



##### p와 P 명령어를 사용할 경우

```sh
# 패턴 공간 내용을 그대로 출력
sed -n '0,/NaleeJang/ {
s/We will test to replace/We will test to\nreplace/
p }' hosts

# 패턴 공간을 출력하되, 뉴라인이 있는 라인은 뉴라인까지 출력
sed -n '0,/NaleeJang/ {
s/We will test to replace/We will test to \nreplace/
P }' hosts
```



##### s/regexp/replacement/ 명령어를 사용할 경우

```sh
# 첫 번째 라인부터 Nalee가 포함된 라인의 #을 공백으로 변경 후 출력
sed -n '0,/Nalee/ {
s/^# //
p }' hosts
This is Sed Sample File
We will test to replace from a-text to b-text.
It was created by NaleeJang.
```



##### t label / T label 명령어를 사용할 경우

```sh
# 해당 범위에 192.20.3이 있든 없든 label2로 분기하여 명령어 수행
sed -n '/# Test/,+3 {
:label2
s/172.10.2/192.20.3/
/192.20.3/ t label2
p }' hosts
# Test

192.20.3.12 test1.example.com
192.20.3.13 test2.example.com

# 해당 범위에 172.10.2가 없기 때문에 label2로 분기됨
sed -n '/# Test/,+3 {
:label2
s/172.10.2/192.20.3/
/172.10.2/ T label2
p }' hosts
# Test

192.20.3.12 test1.example.com
192.20.3.13 test2.example.com
```

```
t 명령어는 앞에 오는 어드레스가 참이든 거짓이든 상관없이 분기된 라벨 다음 명령어를 수행하지만,
T 명령어는 어드레스가 거짓일 경우에만 명시한 라벨 다음 명령어를 수행함.
```



##### w와 W 파일명 명령어를 사용할 경우

```sh
# w 명령어로 변경된 패턴 내용을 sed-w.txt에 저장
sed -n '0,/NaleeJang/ {
s/We will test to replace/We will test to\nreplace/
w sed-w.txt
p }' hosts

# 저장된 파일 내용 확인
cat sed-w.txt
# This is Sed Sample File
# We will test to
replace from a-text to b-text.
# It was created by NaleeJang.

# W 명령어로 변경된 패턴 내용을 sed-w.txt에 저장
sed -n '0,/NaleeJang/ {
s/We will test to replace/We will test to\nreplace/
W sed-W.txt
p }' hosts
# This is Sed Sample File
# We will test to
replace from a-text to b-text.
# It was created by NaleeJang.

# 저장된 파일 내용 확인
cat sed-W.txt
# This is Sed Sample File
# We will test to
# It was created by NaleeJang.
```



##### x 명령어를 사용할 경우

```sh
# 패턴 버퍼와 홀드 버퍼의 내용을 두 번 교환하여 파일이 수정되지 않음
sed -n '/# Test/,+3 {
x
s/172.10.2/192.20.3/
x
p }' hosts
# Test

172.10.2.12 test1.example.com
172.10.2.13 test2.example.com
```



##### y/source/dest/ 명령어를 사용할 경우

```sh
sed -n '/# Test/,+3 {
y/test/TEST/
p }' hosts
# TEST

172.10.2.12 TEST1.ExamplE.com
172.10.2.13 TEST2.ExamplE.com
```

---



## 3. sed 옵션

```
sed는 스트림 에디터로 vi 에디터와 같은 문서 편집기가 나오기 이전에 사용되던 문서 편집기였음.
그래서 문서 편집 시 도움이 되는 옵션들을 많이 가지고 있음.
```

#### sed 옵션

| 옵션                                      | 설명                                                         |
| ----------------------------------------- | ------------------------------------------------------------ |
| -n<br>--quiet<br>--silent                 | 현재 패턴 공간을 출력하지 않음                               |
| -e 스크립트<br>--expression=스크립트      | 여러 개의 스크립트를 실행할 때 사용                          |
| -f 스크립트파일<br>--file=스크립트파일    | 스크립트 파일을 통해 sed를 실행할 때 사용                    |
| --follow-symlinks                         | -i 옵션과 함께 사용할 경우 스크립트 실행 결과를<br>심볼릭 링크 자체가 아닌 심볼릭 링크와 연결된 원본 파일에 적용 |
| -i[파일확장자]<br>--in-place[=파일확장자] | 스크립트 실행 결과를 파일에 바로 적용함<br>파일 확장자를 명시하면 변경 전 명시한 확장자를 가진 백업 파일을 생성 |
| -c<br>--copy                              | -i 옵션과 함께 사용할 수 있으며, 파일명 뒤에 c가 붙은 백업 파일을 생성 |
| -l N<br>--line-length=N                   | l 명령어와 함께 사용할 수 있으며<br>긴 문자열을 포함하는 파일의 내용을 확인할 경우 N만큼 라인 넓이를 설정 |
| --posix                                   | POSIX 확장 기능을 끔<br>POSIX 확장을 지원하지 않는 시스템에서 sed를 실행해야 할 경우<br>POSIX 확장 기능을 끄고, 스크립트를 검증할 수 있음 |
| -r<br>--regexp-extended                   | 스크립트에서 POSIX 확장 정규식을 사용할 수 있음<br>sed는 기본적으로 확장 정규식을 인식하지 않음 |
| -s<br>--separate                          | sed는 기본적으로 여러 개의 파일을 하나의 파일로 간주하지만<br>-s 옵션을 사용하면 여러 개의 파일을 각각 처리할 수 있음 |
| -u<br>--unbuffered                        | 대용량의 파일에서 스크립트 실행 결과를 터미널로 출력할 경우<br>-u 옵션을 사용하면 버퍼를 자주 비워 성능이 향상됨 |
| -z<br>--null-data                         | 구분 기호가 null인 데이터의 문자열을 변경할 때 사용          |
| --version                                 | 버전 정보 보여줌                                             |



##### -n, --quiet, --silent 옵션을 사용할 경우

```sh
# 패턴 공간의 내용은 출력하지 않고, 명령어에 의한 내용만 출력
sed -n '1,5 p' hosts
# This is Sed Sample File
# We will test to replace from a-text to b-text.
# It was created by NaleeJang.

127.0.0.1   localhost
```



##### -e 스크립트, --expression=스크립트 옵션을 사용할 경우

```sh
sed -n -e '/172.1.2.*/ s/test/imsi/p' -e 's/Test/Imsi/p' hosts
# Imsi
172.10.2.12 imsi1.example.com
172.10.2.13 imsi2.example.com
```



##### -f 스크립트파일, --file=스크립트파일 옵션을 사용할 경우

```sh
# 테스트를 위해 sed script 내용을 script.txt 파일에 저장
echo "/test[0-9].[a-z]*/ s/172.10.2/192.10.8/p" > script.txt

# 저장한 파일을 이용해 hosts의 IP 수정
sed -n -f script.txt hosts
192.10.8.12 test1.example.com
192.10.8.13 test2.example.com
```



##### -i 파일 확장자, --in-place=파일 확장자 옵션을 사용할 경우

```sh
# -i 옵션을 사용하여 hosts의 IP를 바로 수정
sed -i '/test[0-9].[a-z]*/ s/172.10.2/192.10.8/' hosts

# cat과 grep 명령어를 통해 파일 내용이 수정되었는지 확인
cat hosts | grep 'test[0-9].[a-z]*'
192.10.8.12 test1.example.com
192.10.8.13 test2.example.com

# -i 옵션을 사용하여 hosts의 IP를 바로 수정
sed -i.bak '/test[0-9].[a-z]*/ s/192.10.8/192.10.2/' hosts

ll hosts*
-rw-rw-r-- 1 jngmk jngmk 428  9월 11 23:40 hosts
-rw-rw-r-- 1 jngmk jngmk 428  9월 11 23:39 hosts.bak
```



##### --follow-symlinks 옵션을 사용할 경우

```sh
# 테스트를 위해 hosts를 보는 심볼릭 링크 sym-hosts 생성
ln -s hosts sym-hosts

# 생성된 파일 목록 확인
ll *hosts
-rw-rw-r-- 1 jngmk jngmk 428  9월 11 23:40 hosts
lrwxrwxrwx 1 jngmk jngmk   5  9월 11 23:42 sym-hosts -> hosts

# --follow-symlinks 옵션을 이용하여 심볼릭 링크 내용 수정
sed --follow-symlinks -i '/test[0-9].[a-z]*/ s/192.10.2/172.10.2/' sym-hosts

# 확인
cat hosts | grep 'test[0-9].[a-z]*'
172.10.2.12 test1.example.com
172.10.2.13 test2.example.com

# --follow-symlinks 옵션없이 심볼릭 링크 내용 수정
sed -i '/test[0-9].[a-z]*/ s/172.10.2/192.10.8/' sym-hosts

# 확인
cat hosts | grep 'test[0-9].[a-z]*'
172.10.2.12 test1.example.com
172.10.2.13 test2.example.co

cat sym-hosts | grep 'test[0-9].[a-z]*'
192.10.8.12 test1.example.com
192.10.8.13 test2.example.com
```



##### -c, --copy 옵션을 사용할 경우

```sh
# -c 옵션은 -i 옵션 바로 뒤에 와야 함
sed -ic '/test[0-9].[a-z]*/ s/172.10.2/192.10.8/' hosts

# hostsc라는 파일이 생성된 것을 확인
ll hosts*
-rw-rw-r-- 1 jngmk jngmk 428  9월 11 23:49 hosts
-rw-rw-r-- 1 jngmk jngmk 428  9월 11 23:39 hosts.bak
-rw-rw-r-- 1 jngmk jngmk 428  9월 11 23:45 hostsc
```



##### -l N, --line-length=N 옵션을 사용할 경우

```sh
# 테스트를 위해 장문의 문자열을 file로 저장
echo "This is a test sentence for testing line length. sed command has line break function. If you want to apply this function, you can use -l N option. N is number of line length" > sed-line-length.txt

# 너비 50에 맞춰 sed-line-length.txt 출력
sed -n -l 50 'l' sed-line-length.txt
This is a test sentence for testing line length. \
sed command has line break function. If you want \
to apply this function, you can use -l N option. \
N is number of line length$
```



##### -r, --regexp-extened 옵션을 사용할 경우

```sh
# 확장 정규 표현식을 이용하여 영문소문자와 숫자로 이루어진 문자열에 해당하는 라인 출력
sed -n -r '/[[:lower:]]+[0-9].*/ p' hosts
192.10.8.12 test1.example.com
192.10.8.13 test2.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com
```



##### -s, --separate 옵션을 사용할 경우

```sh
# -s 옵션없이 hosts와 hostsc 파일의 마지막 라인 번호를 출력하면 40이 출력됨
sed -n '$=' hosts hostsc
40

# -s 옵션과 함께 hosts와 hostsc 파일의 마지막 라인 번호를 출력하면 각각 출력됨
sed -n -s '$=' hosts hostsc
20
20
```



