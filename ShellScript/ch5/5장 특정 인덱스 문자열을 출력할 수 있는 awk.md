# 5장 특정 인덱스 문자열을 출력할 수 있는 awk

```
시스템 파일 목록이나 컨테이너 목록 또는 애플리케이션 실행 결과에서 특정 컬럼에 해당하는 문자열을 추출하고,
해당 결과값을 이용하여 또 다른 명령어를 실행할 때 파라미터로 사용해야 하는 경우가 있음.
이런 경우 특정 인덱스 문자열을 출력할 수 있는 awk 명령어를 사용할 수 있음.
awk는 앞에서 사전에 실행된 명령어의 결과나 파일로부터 레코드를 선택하고,
선택된 레코드의 특정 인덱스에 해당하는 값을 출력할 수 있음.
또한 선택된 레코드를 가지고, 패턴과 일치하는지 확인하고, 데이터 조작 및 연산 등의 액션을 수행하여 그 결과를 출력.
```

## 1. awk 사용법

```
awk는 GNU 기반의 awk인 gawk, gawk의 프로파일링 버전인 pgawk,
awk의 디버거 역할을 하는 dawk가 있으며, 대부분의 GNU 기반의 리눅스에서 사용되고 있음.
그리고 BSD 계열이나 Debian 계열 리눅스에는 mawk가 사용됨.
두 가지 버전의 awk는 옵션 사용 시에만 약간의 차이가 있으며, 기능상의 차이는 없음.
```



##### 기본 사용법 1

```
awk의 가장 기본적인 사용법은 옵션, 어떤 문자열을 추출할 것인지를 기술한 awk 프로그램, 대상 파일로 이루어짐.
awk 프로그램은 어떤 문자열을 추출할 것인지를 표현한 패턴과 어떤 인덱스의 문자열을 출력할 것인지에 대한 액션으로 이루어짐.
```

```sh
# Script 디렉터리 내 파일 목록을 파일에 저장
ls -al Script/ > file-list.txt

# 두 번째 필드값이 2인 레코드의 문자열 출력
awk '$2 == 2 { print $NF }' file-list.txt
File
pattern
```

```
$2는 두 번째 필드값을 의미하며, $2 == 2는 패턴에 해당함.
중괄호 안의 print문은 액션에 해당함.
$NF는 Number of Field의 약자로 필드의 개수, 즉 마지막 필드의 문자열을 출력하겠다는 의미.
```



##### 기본 사용법 2

```
awk는 필드와 레코드를 가진 표 형식의 데이터를 추출할 때 매우 유용하게 사용될 수 있음.
그리고, awk 프로그램은 파일로 저장해두었다가 필요할 때 -f 옵션과 함께 해당 파일을 로딩하여
대상 파일에서 필요로 하는 문자열을 추출할 수 있음.
```

```sh
# 패턴과 액션을 파일에 저장
echo '$2 == 2 { print $NF }' > awk-prog.txt

# 파일을 이용해 디렉터리명 추출
awk -f awk-prog.txt file-list.txt
File
pattern
```



##### 기본 사용법 3

```
리눅스 명령어나 애플리케이션의 명령어를 통해 얻은 결과를 이용해 해당 결과에서 필요한 문자열을 추출할 수 있음.
```

```sh
# ls -l 실행 결과를 인자로 awk를 이용하여 디렉터리명 추출
ls -l Script/ | awk '$2 == 2 { print $NF }'
File
pattern
```

---



## 2. awk 프로그래밍

```
awk 프로그래밍은 어떤 인덱스의 값을 추출할 것인지를 명시하는 일을 함.
그래서 awk 프로그램을 작성할 때는 기본적으로 어떤 값을 추출할 것인지를 명시하는 액션으로 이루어짐.
awk는 패턴이 명시되지 않으면 액션에 명시된 해당 필드값을 모두 출력함.
따라서 패턴을 생략할 수도 있고, 액션을 생성할 수도 있음.
```



### 1) 액션

```
awk의 액션은 중괄호 사이에 기술됨.
액션은 제어문(조건문, 반복문 등)과 입/출력문(print, printf)로 구성됨.
```

| 액션                           | 설명                                                         |
| ------------------------------ | ------------------------------------------------------------ |
| print                          | 대상 파일 내용을 그대로 출력함                               |
| print 필드리스트               | 대상 파일의 필드 인덱스($0 ~ $n), 자체 변수(NF, FNR 등)와<br>문자열 등을 조합하여 명시한 대로 출력 |
| print 필드리스트 > 파일        | 대상 파일의 필드 인덱스, 자체 변수, 문자열 등을<br>조합하여 명시한 대로 파일에 출력 |
| printf 포맷, 필드리스트        | 명시한 대상 파일의 필드 인덱스를 명시한 포맷에 맞추어 출력   |
| printf 포맷, 필드리스트 > 파일 | 명시한 대상 파일의 필드 인덱스를 명시한 포맷에 맞추어 파일에 출력 |
| getline                        | 표준 입력, 파이프, 현재 처리되고 있는 파일로부터 입력을 읽기 위해 사용<br>입력의 다음 라인(레코드)을 읽어 들임<br>레코드가 검색되면 1을 리턴하고, 파일의 끝이면 0을 리턴<br>에러가 발생하면 -1을 리턴 |
| getline var                    | 다음 라인을 가져와 NF, NR, FNR 빌트인 변수를 설정            |
| getline < 파일                 | 명시한 파일의 값을 읽어들임<br>단독으로 사용할 수 없으며, print 등과 함께 사용해야 함 |
| getline var < 파일             | 명시한 파일의 값을 읽어 var에 저장함<br>print 등과 함께 사용해야 하며 파일에 명시된 숫자에 해당하는 필드 출력 |



##### print 액션을 사용하는 경우

```
대상 파일의 내용을 그대로 출력해 줌.
cat을 이용해 파일 내용을 보는 것과 동일하며, 패턴과 함께 사용했을 때는 grep을 사용한 것과 유사함.
주로 내가 원하는 레코드를 패턴을 이용해 제대로 가져오는지를 검증할 경우에 사용하면 좋음.
```

```sh
# 파일의 내용 그대로를 출력
awk '{ print }' awk-sample1.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 aa.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 bb.txt
```



##### print 필드리스트 액션을 사용하는 경우

```
출력하고자 하는 필드 인덱스를 나열하면, 해당 필드값을 출력해 줌.
FNR : 현재 레코드의 순서 값
$0 : 파일 전체 값
```

```sh
# 1번째 필드와 8번째 필드값 출력
awk '{ print $1, $8 }' awk-sample1.txt
-rw-rw----. aa.txt
-rw-------. amin.txt
-rw-rw----. bb.txt

# 파일의 레코드 번호를 파일 내용과 함께 출력
awk '{ print FNR, $0 }' awk-sample1.txt
1 -rw-rw----.  1   nalee nalee  65942 05-15 16:49 aa.txt
2 -rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
3 -rw-rw----.  1   nalee nalee  65942 05-15 16:49 bb.txt
```



##### print 필드리스트 > 파일 액션을 사용하는 경우

```
선택된 필드값을 터미널에 보여주는 것이 아니라, 명시한 파일에 저장하라는 의미.
```

```sh
# 1번째 필드와 8번째 필드값을 파일에 저장
awk '{print $1, $8}' > awk-result.txt awk-sample1.txt


# awk에 의해 저장된 파일 내용 확인
cat awk-result.txt
-rw-rw----. aa.txt
-rw-------. amin.txt
-rw-rw----. bb.txt
```



##### printf 포맷, 필드리스트 액션을 사용하는 경우

```
지정한 포맷에 맞게 필드리스트 출력.

%-20s : 왼쪽 정렬 20 컬럼길이에 맞춰 출력

%c : 단일 문자
%d, %i : 숫자(정수 부분만 표현)
%e, %E : [-]d.dddddde[+-]dd 형식의 숫자
%f, %F : [-]ddd.dddddd 형식의 숫자
%g, %G : %e, %f 형식의 숫자를 줄여줌
%o : 8진수 정수
%u : 부호 없는 10진수
%s : 문자열
%x, %X : 16진수 정수
%% : % 기호

count$ : count는 숫자를 의미하며, 출력할 필드리스트 중 해당 count번째 해당하는 값을 출력하라는 의미
- : 왼쪽 정렬하여 출력
space : 숫자를 표현할 때 양수는 space를, 음수는 마이너스 기호를 붙여 출력
+ : 숫자를 표현할 때 양수는 플러스 기호를, 음수는 마이너스 기호를 붙여 출력
# : 제어 문자 표현 시 대체 형식을 사용함
0 : 숫자를 표현할 때 공백 대신 0을 출력함
with : 너비를 의미하며, 명시한 너비 안에서 오른쪽 정렬 후 출력
.prce : 소수점의 경우 소수점 자리수를 의미하며, 문자열의 경우 문자 개수를 의미함
```

```sh
# 8번째 필드와 6번째 필드를 지정한 포맷에 맞게 출력
awk '{printf "%-20s %s\n", $8, $6}' awk-sample1.txt
aa.txt               05-15
amin.txt             05-22
bb.txt               05-15

# 숫자를 이용하여 산술식 표현
echo "30 -20 10" | awk '{printf "%d%-d=%d\n", $1, $2, $3}'

# [-]ddd.dddddd 형식의 소수 표현과 너비 8에 소수점 2자리 표현
echo "10.568" | awk '{printf "%f %8.2f%%\n", $NF, $NF}'
```



##### printf 포맷, 필드리스트 > 파일 액션을 사용하는 경우

```sh
awk '{printf "%-20s %s\n", $8, $6}' > awk-res.txt awk-sample1.txt
cat awk-res.txt
aa.txt               05-15
amin.txt             05-22
bb.txt               05-15
```



##### getline 액션을 사용하는 경우

```sh
# 다음 라인을 읽음
awk '{getline; print $NF}' awk-sample1.txt
amin.txt
bb.txt
```



##### getline var 액션을 사용하는 경우

```
awk의 내장변수

ARGC : 명령어의 인수 개수
ARGIND : 현재 파일의 ARGV 인덱스
ARGV : 명령줄 인수 배열
FILENAME : 대상 파일명
FNR : 대상 파일 라인 번호
FS : 필드 구분 기호
NF : 대상 파일 필드 개수
NR : 대상 파일 총 레코드 개수
OFMT : 숫자의 기본 출력 포맷
OFS : 출력 필드 구분 기호
ORS : 출력 레코드 구분 기호
RS : 대상 파일의 레코드 구분 기호
```

```sh
awk '{getline var; print $NF}' awk-sample1.txt
aa.txt
bb.txt
```



##### getline < 파일 액션을 사용하는 경우

```sh
# 파일에 다음과 같이 저장
vi awk-filetype.txt
Ascii_text
Ascii_text
Ascii_text

# 파일을 읽어 첫 번째 필드값으로 변경하여 출력
awk '{getline $1 < "awk-filetype.txt"; print}' awk-sample1.txt
```



##### getline var < 파일 액션을 사용하는 경우

```sh
vi awk-test.txt
8
8
8

awk '{getline var < "awk-test.txt"; print $var }' awk-sample1.txt
aa.txt
amin.txt
bb.txt
```

---



### 2) 패턴

```
패턴은 awk를 이용해 대상 파일에서 어떤 레코드를 출력할 것인지에 대해 명시하는 것.
예를 들어, 파일 내용에 정규 표현식으로 표현된 값이 있는지, 숫자와 숫자 또는 문자와 문자를 비교할 수도 있음.
이런 관계식을 나열하여 논리 연산을 할 수도 있음.
```

| 패턴                                   | 설명                                                         |
| -------------------------------------- | ------------------------------------------------------------ |
| BEGIN { 액션 }<br>END { 액션 }         | 입력된 데이터의 첫 번째 레코드를 읽기 전에<br>BEGIN에 의해 선언된 액션을 먼저 처리하며<br>모든 작업 완료 후 마지막에 END 액션을 처리 |
| BEGINFILE { 액션 }<br>ENDFILE { 액션 } | FILENAME이라는 awk 자체 변수를 사용할 경우에만 사용          |
| /정규 표현식/                          | 패턴을 정규 표현식 형태로 작성할 경우 // 사이에 표현         |
| 관계식                                 | 필드와 패턴 값을 비교할 경우 산술 연산자를 사용하여 비교할 수 있음 |
| 패턴1 && 패턴2                         | 패턴이나 관계식을 AND 연산                                   |
| 패턴1 \|\| 패턴2                       | 패턴이나 관계식을 OR 연산                                    |
| 패턴1 ? 패턴2 : 패턴3                  | 패턴1(또는 관계식)이 true이면 패턴2가 리턴되며 false이면 패턴3이 리턴됨 |
| ( 패턴 )                               | 패턴이나 관계식을 그룹핑하거나 우선순위를 높임               |
| ! 패턴                                 | 패턴이나 관계식을 NOT 연산함                                 |
| 패턴1, 패턴2                           | 패턴1, 패턴2 형식을 범위 패턴이라고 하며,<br>패턴1부터 패턴2 사이에 해당하는 레코드를 출력함 |



##### BEGIN { 액션 } END { 액션 }을 사용하는 경우

```
패턴 BEGIN과 END는 다른 패턴 표현과는 다르게
awk 수행을 위해 대상 파일에서 데이터를 읽어들이기 전 또는 후에 실행되는 특수 패턴임.
```

```sh
# 8번째 필드를 출력하기 전에 "# FILENAME #" 문구를 출력
awk 'BEGIN {print "# FILENAME #"} {print $8}' awk-sample1.txt
# FILENAME #
aa.txt
amin.txt
bb.txt

# 8번째 필드 출력 후 "THE FILE IS NR(레코드 수)"를 출력
awk '{print $8} END {print "THE FILE IS "NR}' awk-sample1.txt
aa.txt
amin.txt
bb.txt
THE FILE IS 3
```



##### /정규 표현식/을 사용하는 경우

```sh
# 소유자와 그룹이 읽고 쓰기 가능한 파일 찾기
awk "/^-rw-rw/ { print }" awk-sample1.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 aa.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 bb.txt

# 파일명이 a로 시작해 txt로 끝나는 파일 목록 출력
awk '/a[[:lower:]]*.txt/ { print }' awk-sample1.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 aa.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
```



##### 관계식을 사용하는 경우

```sh
# 2번째 필드값이 2로, 디렉터리일 경우에만 디렉터리명 출력
awk '$2 == 2 { print $NF }' awk-sample.txt
File
pattern
```



##### 패턴1 && 패턴2를 사용하는 경우

```sh
# 레코드 번호 6이 아니고, 디렉터리인 경우만 디렉터리 목록 출력
awk 'NR !=6 && $2 == 2 { print }' awk-sample.txt
drwxrwxr-x.  2   nalee nalee     86 05-21 13:07 pattern

# 소유자가 읽고 쓸 수 있으며, a와 txt 사이가 영문소문자로 이루어진 파일 목록 출력
awk '/^-rw-*/ && /a[[:lower:]]*.txt/ { print }' awk-sample.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 aa.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-rw-rw-.  1   nalee nalee     60 05-21 12:27 Separator.txt
```



##### 패턴1 || 패턴2를 사용하는 경우

```sh
# 파일 소유자가 nalee가 아니고, 파일 사이즈가 0인 파일 목록 출력
awk '$3 != "nalee" || $4 == 0 { print }' awk-sample.txt
-rw-rw-r--.  1   test   test      0 05-22 14:28 findtestfile
-rw-r--r--.  1   root   root      0 05-24 11:52 rootfile
```



##### 패턴1 ? 패턴2 : 패턴3을 사용하는 경우

```sh
# 2번째 필드값이 2면 Directory를 res에 저장하고, 아니면 File을 res에 저장한 후
# 파일명은 10칸 내에 맞추고, res 변수값과 뉴라인을 추가하여 출력
awk '$2 == 2 ? res="Directory" : res="File" { printf "%-20s %s\n", $NF, res }' awk-sample.txt

aa.txt               File
amin.txt             File
bb.txt               File
expression.tar.gz    File
expression.txt       File
File                 Directory
findtestfile         File
grep-test            File
pattern              Directory
rootfile             File
Separator.txt        File
test.txt             File
```



##### (패턴)을 사용하는 경우

```sh
# 6번째 필드(수정일자)가 05-22보다 크거나 같은 경우의 파일 목록 출력
# 관계식을 소괄호로 묶어 가독성을 높이는 데 사용
awk '($6 >= "05-22") { print }' awk-sample.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-rw-r--.  1   test   test      0 05-22 14:28 findtestfile
-rw-r--r--.  1   root   root      0 05-24 11:52 rootfile
```



##### ! 패턴을 사용하는 경우

```sh
# 파일 소유자가 nalee가 아닌 파일 목록 출력
awk '!(/nalee/) { print }' awk-sample.txt
-rw-rw-r--.  1   test   test      0 05-22 14:28 findtestfile
-rw-r--r--.  1   root   root      0 05-24 11:52 rootfile
```



##### 패턴1, 패턴2를 사용하는 경우

```sh
# 파일 레코드 번호가 2부터 5까지에 해당하는 파일 목록 출력
awk 'FNR==2, FNR==5 { print }' awk-sample.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 bb.txt
-rw-rw-r--.  1   nalee nalee    750 05-13 14:40 expression.tar.gz
-rw-------.  1   nalee nalee    717 05-21 12:26 expression.txt

# 파일 수정일자가 05-20보다 늦고 05-25보다 빠른 일자에 수정한 파일 목록 출력
awk '($6 > "05-20"), ($6 < "05-25") { print }' awk-sample.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-------.  1   nalee nalee    717 05-21 12:26 expression.txt
-rw-rw-r--.  1   test   test      0 05-22 14:28 findtestfile
drwxrwxr-x.  2   nalee nalee     86 05-21 13:07 pattern
-rw-r--r--.  1   root   root      0 05-24 11:52 rootfile
-rw-rw-rw-.  1   nalee nalee     60 05-21 12:27 Separator.txt
```

---



## 3. awk 옵션

```
awk 옵션은 일반적으로 사용되는 표준 옵션과 awk 프로그래밍을 위한 확장 옵션으로 이루어짐.
awk 옵션에는 마이너스 기호와 함께 알파벳 한글자로 이루어진 POSIX 스타일의 옵션과
더블 마이너스 기호와 긴 문자열로 이루어진 GNU 스타일의 옵션이 있음.
표준 옵션은 GNU 기반의 리눅스나 BSD 또는 Debian 기반 리눅스에서 사용하는
mawk의 표준 옵션이나 모두 동일한 포맷을 가짐.
그러나 mawk의 확장 옵션의 경우에는 -W와 함께 GNU 스타일의 긴 문자열로 이루어진 옵션을 사용함
```



### 1) 표준 옵션

```
표준 옵션은 awk 프로그램이 되어 있는 파일을 이용하여 awk를 수행할 수 있는 옵션과
대상 파일의 구분 기호를 바꿔주는 옵션, 외부에서 선언된 값이나 별도의 값을 사용할 때 쓰이는 옵션이 있음
```

| 옵션                                        | 설명                                                         |
| ------------------------------------------- | ------------------------------------------------------------ |
| -f 파일<br>--file 파일                      | awk 프로그램(패턴 {액션})을 파일에 저장하고<br>해당 파일을 이용하여 필요한 필드 및 레코드를 추출함 |
| -F 구분 기호<br>--field-separator 구분 기호 | 필드 구분 기호를 변경할 수 있음<br>awk의 기본 필드구분 기호는 스페이스지만<br>-F 옵션을 통해 필드 구분 기호를 변경할 수 있음 |
| -v 변수=값<br>--assign 변수=값              | 필드 및 레코드를 출력할 때 -v 옵션을 통해 변수의 값을 함께 출력 가능 |



##### -f 파일 / --file 파일 옵션을 사용하는 경우

```sh
echo '$2 == 2 { print $NF }' > awk-prog.txt

awk -f awk-prog.txt awk-sample.txt
File
pattern
```



##### -F 구분 기호 / --field-separator 구분 기호 옵션을 사용하는 경우

```sh
# 파일 확인
cat awk-test.csv
Nalee Jang,2,Red Hat Korea,1230
Gildong Hong,1,ABC Corporation,2345
Yejee Kim,2,BBB Company,5678
Heechul Park,1,CCC Company,6789

# awk-test.csv의 이름 출력 실패
awk '{ print $1 }' awk-test.csv

# -F 옵션을 이용해 구분 기호를 ,로 바꿈
awk -F ',' '{ print $1 }' awk-test.csv
est.csv
Nalee Jang
Gildong Hong
Yejee Kim
Heechul Park
```



##### -v 변수=값 / --assign 변수=값 옵션을 사용하는 경우

```
명시된 변수에 명시된 값을 저장함. 그리고 해당 변수를 액션에서 출력할 경우 함께 사용할 수 있음.
또는 셸 스크립트 구현 시 앞에서 실행된 명령문의 결과값을 -v 옵션을 통해 변수에 할당하고,
이를 출력할 때 함께 사용할 수 있음.
```

```sh
# label에 저장된 "Filename: "이라는 문자열을 파일명과 함께 출력
awk -v label="Filename: " '{ print label $NF }' awk-sample1.txt
Filename: aa.txt
Filename: amin.txt
Filename: bb.txt
```

---



### 2) 확장 옵션 (pawk)

```
확장 옵션은 awk 프로그래밍을 위한 디버그 옵션이나 내장변수 정보, 에러 미시지 등을 표현할 경우 사용되는 옵션들.
GNU 기반의 리눅스에서 사용하는 gawk는 POSIX 스타일의 옵션과 GNU 스타일의 옵션을 제공하며,
BSD나 Debian 기반의 리눅스에서 사용하는 mawk는 -W와 함께 GNU 스타일의 옵션을 제공함.
```

| 옵션                                | 설명                                                         |
| ----------------------------------- | ------------------------------------------------------------ |
| -b<br>--characters-as-bytes         | 입력되는 문자열을 바이트로 처리하며,<br>문자열 길이를 구하는 length() 같은 함수의 결과값에 영향을 줌 |
| -C<br>--copyright                   | GNU 라이센스 정보를 보여줌                                   |
| -p파일명<br>--profile=파일명        | awk 프로그램(패턴 {액션})을 awkprog.out 또는 명시한 파일에 파싱하여 저장 |
| -S<br>--sandbox                     | system() 함수, getline, 프린트 함수를 이용한<br>redirection, 확장 모듈 사용을 할 수 없음 |
| -d파일명<br>--dump-variables=파일명 | awk 내장 변수와 값을 명시한 파일에 저장하여 확인할 수 있음   |
| -L 'fatal'<br>--lint='fatal'        | 구문 오류에 대한 에러 메시지를 자세하게 보여줌               |



##### -b / --characters-as-bytes 옵션을 사용하는 경우

```
문자를 바이트로 계산함.
영문자를 제외한 한글이나 일본어 같은 경우에는 1문자를 표현하기 위해 2바이트 혹은 3바이트를 사용함.
```



##### -d파일명 / --dump-variables=파일명 옵션을 사용하는 경우

```
대상 파일로부터 필요한 파일을 출력할 때 사용된 awk 내장 변수 정보를 명시한 파일에 저장함.
이때 -d와 파일명 사이에 공백을 주면 안됨.
```



##### -L 'fatal' / --lint='fatal' 옵션을 사용하는 경우

```
프로그램에 구문 오류가 있을 경우 왜 에러가 발생했는지를 자세하게 보여주며,
에러 메시지를 출력하지 않는 경우에도 에러 메시지를 보여줌.
```



##### -S / --sandbox 옵션을 사용하는 경우

```
대상 파일을 제외한 이외 파일의 접근을 막음.
```