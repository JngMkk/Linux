# 4장 파일을 찾을 수 있는 find

## 1. 사용법 알아보기

##### 사용법

```
find의 가장 기본적인 사용법은 파일을 찾고자 하는 대상 경로, 어떤 기준으로 어떤 파일을 찾을지에 대한 표현식으로.
이때 대상 경로는 기본적으로 현재 디렉터리를 가리키며
표현식에는 테스트, 연산자, 액션 및 위치옵션으로 구성될 수 있음.
```

```sh
find /etc -name chrony.conf
/etc/chrony.conf

# 파일 권한이 644이면서 rc로 시작하는 파일 검색
# -L 심볼릭 링크의 원파일 속성을 검사하도록 하는 옵션
# -perm 파일 권한을 의미
find -L /etc -perm 644 -name 'rc.*'
/etc/rc.d/rc.local
/etc/rc.local
```

---



## 2. find의 다양한 표현식

```
find는 사용자가 필요로 하는 조건으로 파일을 찾기 위한 방법을 옵션이 아닌 표현식으로 제공함.
표현식에는 find에서 찾고자 하는 파일의 속성을 정의할 수 있는 테스트,
테스트와 테스트의 검색 우선순위를 정의할 수 있는 연산자,
검색한 파일을 인수로 하여 또 다른 명령어를 실행할 수 있는 액션,
테스트와 함께 쓰이면서 테스트의 검색조건을 변경할 수 있는 위치옵션이 있음
```



### 1) 테스트

#### 시간 관련 테스트

```
파일이 언제 생성되었고, 언제 사용되었으며, 언제 변경되었는지를
현재 시각을 기준으로 명시된 분 또는 시간에 해당하는 파일을 찾아줌.
```

| 테스트   | 설명                                                         |
| -------- | ------------------------------------------------------------ |
| -amin n  | 현재 시각을 기준으로 n분 전에 액세스된 파일을 찾아줌         |
| -atime n | 현재 시각을 기준으로 n * 24시간 전에 액세스된 파일을 찾아줌  |
| -cmin n  | 현재 시각을 기준으로 n분 전에 이름이 변경된 파일을 찾아줌    |
| -ctime n | 현재 시각을 기준으로 n * 24시간 전에 이름이 변경된 파일을 찾아줌 |
| -mmin n  | 현재 시각을 기준으로 n분 전에 내용이 수정된 파일을 찾아줌    |
| -mtime n | 현재 시각을 기준으로 n * 24시간 전에 내용이 수정된 파일을 찾아줌 |



##### -amin n 테스트를 사용하는 경우

```sh
# 현재 시각 확인
date
Wed 14 Sep 2022 05:47:17 PM KST

# 3분 내에 접근한 파일 검색
find ./ -amin -3
./
./aa.txt
./expression.txt
...

# 해당 파일의 접근 시각 확인
stat amin.txt | grep Access
Access: (0600/-rw-------)  Uid: ( 1000/   jngmk)   Gid: ( 1000/   jngmk)
Access: 2022-09-14 17:46:13.749722287 +0900
```



##### -atime n 테스트를 사용하는 경우

```sh
# 1 * 24시간 내에 변경된 파일 검색
find ./ -atime -1
./
./aa.txt
./expression.txt
...
```



##### -cmin n 테스트를 사용하는 경우

```sh
# 테스트를 위해 파일 수정
echo "cmin test" >> amin.txt

# 1분 내에 수정된 파일 검색
find ./ -cmin -1
./amin.txt

# 파일 변경 상태 확인
stat amin.txt | grep Change
Change: 2022-09-14 17:52:46.332727575 +0900
```



##### -ctime n 테스트를 사용하는 경우

```sh
# 24시간 내에 수정된 파일 검색
find ./ -ctime 0
./
./aa.txt
./expression.txt
./amin.txt
...
```



##### -mmin n 테스트를 사용하는 경우

```sh
# 5분 내에 수정된 파일 검색
find ./ -mmin -5
./amin.txt

# 파일 수정 시간 확인
stat amin.txt | grep Modify
Modify: 2022-09-14 17:52:46.332727575 +0900
```



##### -mtime n 테스트를 사용하는 경우

```sh
# 24시간 내에 수정된 파일 검색
find ./ -mtime 0
./amin.txt
```

---



#### 최신 파일 검색 관련 테스트

```
명시한 파일을 기준으로 더 최근에 접근하고, 수정 및 변경이 이루어진 파일을 검색
```

| 테스트        | 설명                                                         |
| ------------- | ------------------------------------------------------------ |
| -anewer file  | 명시된 파일보다 최근에 접근한 파일을 보여줌                  |
| -cnewer file  | 명시된 파일보다 최근에 변경된 파일을 찾아줌                  |
| -newer file   | 명시된 파일보다 최근에 수정된 파일을 찾아줌                  |
| -newerXY file | 명시된 파일의 속성보다 최근에 수정된 파일을 찾아줌<br>파일 속성은 XY로 표시하며 속성 B는 리눅스에서 사용할 수 없음<br>a : 파일 참조의 액세스 시간<br>B : 파일 참조의 탄생 시간<br>c : inode 상태 변경 시간 참조<br>m : 파일 참조의 수정 시간 |



##### -anewer file 테스트를 사용하는 경우

```sh
# 테스트를 위해 expression.txt를 cat을 통해 접근
cat expression.txt

# amin.txt보다 더 최근에 수정된 파일 검색
find ./ -anewer amin.txt
./expression.txt
```



##### -cnewer file 테스트를 사용하는 경우

```sh
# 테스트를 위해 파일에 문자열 추가
echo "cnewer test" >> Separator.txt

# amin.txt보다 최근에 변경된 파일 검색
find -L ./ -cnewer amin.txt
./Separator.txt
```



##### -newer file 테스트를 사용하는 경우

```sh
# amin.txt보다 최근에 수정된 파일 검색
find ./ -newer amin.txt
./Separator.txt
```



##### -newerXY file 테스트를 사용하는 경우

```sh
# amin.txt보다 더 최근에 수정되고, 변경된 파일 검색
find ./ -newercm amin.txt
./Separator.txt
```

---



#### 파일 권한 관련 테스트

```
찾고자 하는 파일 권한에 해당하는 파일을 검색할 수 있도록 도와줌.
```

| 테스트      | 설명                                                         |
| ----------- | ------------------------------------------------------------ |
| -perm mode  | 명시된 파일 권한과 동일한 파일을 검색함                      |
| -perm -mode | 명시된 파일 권한이 포함된 파일을 검색함                      |
| -perm /mode | 명시된 파일 권한이 세 개의 권한 중 하나라도 동일한 파일을 검색함 |
| -readable   | 로그인한 사용자가 읽을 수 있는 파일을 검색함                 |
| -writable   | 로그인한 사용자가 쓸 수 있는 파일을 검색함                   |
| -executable | 실행 권한이 있는 파일만 검색함                               |



##### -perm mode 테스트를 사용하는 경우

```sh
# 파일 권한이 660인 파일 검색
find ./ -perm 660
./aa.txt
./bb.txt
```



##### -perm -mode 테스트를 사용하는 경우

```sh
# 파일 권한이 666인 파일 검색
find ./ -perm 666

# 파일 권한이 666을 포함하는 파일 검색
find ./ -perm -666
./File/express.txt

ls -l ./File
lrwxrwxrwx express.txt -> ../expression.txt
```



##### -perm /mode 테스트를 사용하는 경우

```sh
# 파일 권한 중 하나 이상이 6에 해당하는 파일 검색
find ./ -perm /666
./
./aa.txt
./expression.txt
./amin.txt
./Separator.txt
./findtestfile
./expression.tar.gz
./test.txt
./grep-test
./File
./File/express.txt
./File/file1.txt
...
```



##### -readable 테스트를 사용하는 경우

```sh
# 테스트를 위해 root 계정에서 /temp 디렉터리에 파일 생성
mkdir /temp; touch /temp/read.txt

# temp 디렉터리에서 읽기가 가능한 파일 검색
find /temp -readable
/temp
/temp/read.txt
```



##### -writable 테스트를 사용하는 경우

```sh
# temp 디렉터리에서 쓰기가 가능한 파일 검색
find /temp -writable

# temp 디렉터리의 파일 목록 확인
ls -l /temp
total 0
-rw-r--r-- 1 root root 0  9월 14 18:12 read.txt
```



##### -executable 테스트를 사용하는 경우

```sh
# 로그인한 계정이 실행할 수 있는 파일 검색
find ./ -executable
./
./grep-test
./File
./pattern
```

---



#### 그룹 및 사용자 관련 테스트

```
찾고자 하는 그룹ID 또는 그룹명, 사용자ID 또는 사용자명에 해당하는 파일을 검색할 때 사용할 수 있음
```

| 테스트       | 설명                                                |
| ------------ | --------------------------------------------------- |
| -gid n       | 그룹ID가 명시한 그룹ID n과 동일한 파일 검색         |
| -group gname | 그룹명이 명시한 그룹명 gname과 동일한 파일 검색     |
| -nogroup     | 존재하지 않는 그룹ID를 가지고 있는 파일 검색        |
| -nouser      | 존재하지 않는 사용자ID를 가지고 있는 파일 검색      |
| -uid n       | 사용자 ID가 명시한 사용자ID n과 동일한 파일 검색    |
| -user uname  | 사용자명이 명시한 사용자명 uname과 동일한 파일 검색 |



##### -gid n 테스트를 사용하는 경우

```sh
# 테스트를 위해 root 권한으로 파일 생성
sudo touch rootfile

# 그룹ID가 0(0은 root를 의미함)인 파일 검색
find ./ -gid 0
./rootfile

# rootfile의 파일 소유권 확인
ls -l rootfile
-rw-r--r-- 1 root root 0  9월 14 18:19 rootfile
```



##### -group gname 테스트를 사용하는 경우

```sh
# 그룹소유권이 root인 파일 검색
find ./ -group root
./rootfile
```



##### nogroup 테스트를 사용하는 경우

```sh
# 테스트를 위해 chown을 이용해 존재하지 않는 사용자ID 및 그룹ID로 소유권 변경
sudo chown 1001:1001 findtestfile

# 존재하지 않는 그룹ID가 있는 파일 검색
find ./ -nogroup
./findtestfile
```



##### -nouser 테스트를 사용하는 경우

```sh
find ./ -nouser
./findtestfile
```



##### -uid n 테스트를 사용하는 경우

```sh
# root 계정 ID를 가지고 있는 파일 검색
find ./ -uid 0
./rootfile
```



##### -user uname 테스트를 사용하는 경우

```sh
# root가 소유자인 파일 검색
find ./ -user root
./rootfile
```

---



#### 파일명 관련 테스트

```
파일명을 이용하여 검색할 때 대소문자 구분을 없앤다던가 하여 심볼릭 링크 등을 검색할 수 있음
```

| 테스트          | 설명                                                         |
| --------------- | ------------------------------------------------------------ |
| -iname pattern  | 대소문자 구분없이 패턴과 일치하는 파일 검색                  |
| -inum n         | 파일의 inode 번호 n을 갖는 파일 검색                         |
| -lname pattern  | 패턴과 일치하는 심볼릭 링크 검색                             |
| -name pattern   | 패턴과 일치하는 파일 검색                                    |
| -regex pattern  | 패턴과 일치하는 경로 검색. Emacs 정규 표현식이 기본값이며<br>-regextype 옵션을 이용하여 변경할 수 있음 |
| -iregex pattern | 대소문자 구분없이 패턴과 일치하는 경로 검색                  |
| -samefile name  | 파일명과 동일한 파일 및 심볼릭 링크 검색<br>심볼릭 링크 검색을 위해서는 -L 옵션을 함께 사용해야 함 |



##### -iname pattern 테스트를 사용하는 경우

```sh
# 테스트를 위한 파일명 변경
mv expression.txt Expression.txt

# e로 시작하는 txt 파일 검색
find ./ -iname "e*.txt"
./Expression.txt
./File/express.txt
```



##### -inum n 테스트를 사용하는 경우

```sh
# 변경한 파일명을 원파일명으로 변경
mv Expression.txt expression.txt

# 테스트를 위한 inode를 검색
stat expression.txt | grep -i inode
Device: 10302h/66306d	Inode: 8658800     Links: 1

# inode가 8658800인 파일 검색
find ./ -inum 8658800
./expression.txt
```



##### -lname pattern 테스트를 사용하는 경우

```sh
# 확장자가 txt로 끝나는 심볼릭 링크 검색
find ./ -lname "*.txt"
./File/express.txt

# express.txt 파일 속성 확인
ls -l ./File/express.txt
lrwxrwxrwx 1 jngmk jngmk 17  5월 13  2020 ./File/express.txt -> ../expression.txt
```



##### -name pattern 테스트를 사용하는 경우

```
메타 문자인 애스터리스크, 물음표, 대괄호를 사용할 수 있음
```

```sh
# e로 시작하는 txt 파일 검색
find ./ -name "e*.txt"
./expression.txt
./File/express.txt
```



##### -regex pattern 테스트를 사용하는 경우

```sh
# f와 e가 순서대로 포함된 경로 검색
find ./ -regex '.*f*e'
./rootfile
./findtestfile
./File
./File/File
./pattern/findtestfile
```



##### -iregex pattern 테스트를 사용하는 경우

```sh
# -regex로 검색했을 경우
find -regex ".*s.*t"
./expression.txt
./test.txt
./grep-test
./File/express.txt
./File/test.txt

# -iregex로 검색했을 경우
find -iregex ".*s.*t"
./expression.txt
./Separator.txt
./test.txt
./grep-test
./File/express.txt
./File/test.txt
```



##### -samefile name 테스트를 사용하는 경우

```sh
# 파일명과 동일한 inode를 가지고 있는 파일 검색 (심볼릭 링크 포함)
find -L ./ -samefile expression.txt
./expression.txt
./File/express.txt
```

---



#### 파일 경로 관련 테스트

```
파일명이 아닌 현재 디렉터리를 기준으로 명시된 패턴에 의해 파일의 경로를 검색함
```

| 테스트              | 설명                                                 |
| ------------------- | ---------------------------------------------------- |
| -ipath pattern      | 대소문자를 구분하지 않고 패턴과 일치하는 경로를 검색 |
| -iwholename pattern | -ipath와 동일하지만 이식성이 떨어짐                  |
| -links n            | n개의 링크를 가지고 있는 경로를 검색함               |
| -path pattern       | 패턴과 일치하는 경로를 검색함                        |
| -wholename pattern  | -path와 동일하지만 이식성이 떨어짐                   |



##### -ipath pattern 테스트를 사용하는 경우

```sh
# f로 시작해 t로 끝나는 경로의 모든 파일 검색
find ./ -ipath './f*t'
./File/express.txt
./File/file1.txt
./File/test.txt
./File/file2.txt
```



##### -links n 테스트를 사용하는 경우

```sh
# n이 1일 경우 파일을 검색, 2일 경우 디렉터리 검색
# 2개의 링크를 가지고 있는 경로 검색
find ./ -links 2
./File
./pattern
```



##### -path pattern 테스트를 사용하는 경우

```sh
# f로 시작해 t로 끝나는 경로의 모든 파일 검색
find ./ -path "./f*t"

```

---



#### 파일 타입 관련 테스트

```
검색 기준이 파일 타입일 경우 사용할 수 있는 테스트
```

| 테스트           | 설명                                                         |
| ---------------- | ------------------------------------------------------------ |
| -fstype type     | BSD 계열의 운영체제에서 지원되며, -type 테스트와 유사한 기능 제공 |
| -type c          | 명시한 파일 타입과 동일한 파일을 검색<br>b : 블록  c : 문자  d : 디렉터리  p : 명명된 파이프<br>f : 일반 파일  l : 심볼릭 링크  s: 소켓  D : door (Solaris) |
| -xtype c         | -type과 동일하며 심볼릭 링크를 검색할 경우 -L 옵션과 함께 사용해야 함 |
| -context pattern | 패턴과 일치되는 보안 컨텍스트를 가진 파일을 검색<br>SELinux가 있는 Fedora 계열 리눅스에서만 사용 가능 |



##### -type c 테스트를 사용하는 경우

```sh
# 파일 타입이 심볼릭 링크인 파일을 검색
find ./ -type l
./File/express.txt
```



##### -xtype c 테스트를 사용하는 경우

```sh
# 디렉터리만 검색
find ./ -xtype d
./
./File
./pattern

# 심볼릭 링크 검색 시 -L 옵션을 함께 사용해야 함
find ./ -xtype l

find -L ./ -xtype l
./File/express.txt
```

---



## 2) 연산자

```
연산자는 테스트를 사용해 AND, OR, NOT과 같은 연산을 할 때 사용할 수 있음.
```

| 연산자           | 설명                                                         |
| ---------------- | ------------------------------------------------------------ |
| ( expr )         | 우선순위나 표현식을 그룹핑할 경우 사용되며 백슬래시와 함께 사용돼야 함 |
| ! expr           | 표현식의 반대 결과를 리턴                                    |
| -not expr        | !expr과 같이 반대 결과 리턴                                  |
| expr1 expr2      | AND 연산을 수행하며, expr1이 false이면 expr2는 평가되지 않음 |
| expr1 -a expr2   | expr1 expr2와 동일                                           |
| expr1 -and expr2 | expr1 expr2와 동일하지만 POSIX 호환 안됨                     |
| exprl -o expr2   | OR 연산을 수행하며, expr1이 ture이면 expr2는 평가되지 않음   |
| expr1 -or expr2  | expr1 -o expr2와 동일하지만 POSIX 호환 안됨                  |
| expr1 , expr2    | expr1, expr2를 각각 수행하며 결과는 expr2에 해당하는 것만  출력됨<br>함께 출력하기 위해서는 -printf나 fprintf를 함께 사용해야 함 |



##### ( expr ) 연산자를 사용하는 경우

```sh
# ()를 사용할 때는 백슬래시와 함께 사용해야 함
find ./ \( -name "exp*" \)
./expression.txt
./expression.tar.gz
./File/express.txt
```



##### ! expr 연산자를 사용하는 경우

```sh
# 파일명이 txt로 끝나지 않는 파일명 검색
find ./ ! -name "*.txt"
./
./rootfile
./findtestfile
./expression.tar.gz
./grep-test
./File
./File/File
./pattern
./pattern/findtestfile
```



##### -not expr 연산자를 사용하는 경우

```sh
find ./ -not -name "*.txt"
./
./rootfile
./findtestfile
./expression.tar.gz
./grep-test
./File
./File/File
./pattern
./pattern/findtestfile
```



##### expr1 expr2 연산자를 사용하는 경우

```sh
# 파일 타입이 디렉터리이면서 이름이 p로 시작되는 경로 검색
find ./ -type d -name "p*"
./pattern

# 파일 타입이 파일이면서 이름이 p로 시작되는 경로 검색
find ./ -type f -name "p*"
./pattern/pattern1.txt
./pattern/pattern2.txt
./pattern/pattern3.txt
```



##### expr1 -a expr2 연산자를 사용하는 경우

```sh
# 파일 타입이 파일이면서 이름이 p로 시작되는 경로 검색
find ./ -type f -a -name "p*"
./pattern/pattern1.txt
./pattern/pattern2.txt
./pattern/pattern3.txt
```



##### expr1 -and expr2 연산자를 수행하는 경우

```sh
# 파일 사이즈가 65k이며, 이름이 a로 시작되는 파일 검색
find ./ -size 65k -and -name "a*"
./aa.txt
```



##### expr1 -o expr2 연산자를 사용하는 경우

```sh
# 파일 사이즈가 65k이거나 파일명이 r로 시작되는 파일 검색
find ./ -size 65k -o -name "r*"
./aa.txt
./rootfile
./bb.txt
```



##### expr1 -or expr2 연산자를 사용하는 경우

```sh
# 실행 권한을 가졌거나 이름이 r로 시작되는 파일 경로 검색
find ./ -executable -or -name "r*"
./
./rootfile
./grep-test
./File
./pattern
```



##### expr1 , expr2 연산자를 사용하는 경우

```sh
# 파일명이 a로 시작되는 파일과 b로 시작되는 파일 검색
find ./ -name "a*" , -name "b*"
./bb.txt

# 파일명이 a로 시작되는 파일과 b로 시작되는 파일 검색
find ./ \( -name "a*" -printf "%p\n" \) , \( -name "b*" -printf "%p\n" \)
./aa.txt
./amin.txt
./bb.txt
```

---



### 3) 액션

```
액션 역시 단독으로 사용되기보다는 테스트와 같은 표현식을 함께 사용함.
액션에는 테스트와 같은 표현식을 통해 검색된 파일을 인자로 하여 또 다른 명령어를 실행해 주는
명령어 실행 관련 액션과 검색 결과를 사용자의 입맛에 맞게 출력해 주는 결과 출력 관련 액션으로 나누어짐.
```

#### 명령어 실행 관련 액션

```
테스트를 통해 검색된 파일을 인자로 또 다른 명령어를 실행할 수 있도록 도와주는 액션
```

| 액션                     | 설명                                                         |
| ------------------------ | ------------------------------------------------------------ |
| -delete                  | 표현식에 의해 검색된 파일을 삭제                             |
| -exec command '{}' \;    | 표현식에 의해 검색된 파일을 인수로 받아 -exec 다음의 명령어를 수행<br>인수로 받을 결과값은 중괄호{}로 표현되며 세미콜론 ;은 역슬래시와 함께 사용해야 함 |
| -exec command '{}' +     | -exec과 동일하나 결과값을 연이어서 보여줌                    |
| -execdir command '{}' \; | -exec과 유사하나 서브 디렉터리부터 검색하기 때문에 결과값은 파일명만 출력 |
| -execdir command '{}' +  | -execdir과 동일하나 결과값은 연이어서 보여줌                 |
| -ok command '{}' \;      | -exec과 유사하지만 사용자에게 실행 여부를 확인 후 실행함     |
| -okdir command '{}' \;   | -execdir과 유사하지만 -ok와 같은 방식으로 사용자에게 실행 여부를 확인 후 실행 |
| -prune                   | 검색한 패턴이 디렉터리인 경우, 하위 디렉터리의 파일은 검색하지 않음 |
| -quit                    | -quit 앞에 만난 표현식에 해당하는 파일이 검색되면 검색을 종료 |



##### -delete 액션을 사용하는 경우

```sh
# 삭제할 파일 확인
ls -l rootfile
-rw-r--r-- 1 root root 0  9월 15 17:17 rootfile

# 검색된 파일 삭제
find ./ -name rootfile -delete


# 파일 삭제 여부 확인
ls -l rootfile
ls: cannot access 'rootfile': No such file or directory
```



##### -exec command {} ; 액션을 사용하는 경우

```sh
# 검색된 파일에서 grep을 이용해 다시 특정 문자열 검색
find ./ -name 'expression.txt' -exec grep CPU '{}' \;
CPU model is Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
```



##### -exec command {} + 액션을 사용하는 경우

```sh
# 검색된 파일명을 echo를 이용해 그대로 보여줌
find ./ -name "e*.txt" -exec echo '{}' \;
./expression.txt
./File/express.txt

# 연이어 출력
find ./ -name "e*.txt" -exec echo '{}' +
./expression.txt ./File/express.txt
```



##### -execdir command {} ; 액션을 사용하는 경우

```sh
# 검색된 파일명을 보여줄 때 경로를 함께 보여줌
find ./File/ -name "f*txt" -exec echo '{}' \;
./File/file1.txt
./File/file2.txt

# 검색된 파일 명만 보여줌
find ./File/ -name "f*txt" -execdir echo '{}' \;
./file1.txt
./file2.txt
```



##### -execdir command {} + 액션을 사용하는 경우

```sh
# 경로가 포함된 파일명을 연이어서 보여줌
find ./ -name "f*" -exec echo '{}' +
./findtestfile ./File/file1.txt ./File/file2.txt ./pattern/findtestfile

# 파일명만 연이어서 보여줌
find ./ -name "f*" -execdir echo '{}' +
./findtestfile
./file1.txt ./file2.txt
./findtestfile
```



##### -ok command {} ; 액션을 사용하는 경우

```sh
# 파일명을 보여줄지 여부를 물어 경로를 포함한 파일명을 보여줌
find ./File/ -name "f*" -ok echo '{}' \;
< echo ... ./File/file1.txt > ? y
./File/file1.txt
< echo ... ./File/file2.txt > ? y
./File/file2.txt
```



##### -okdir command {} ; 액션을 사용하는 경우

```sh
# 파일명만 보여줌
find ./File/ -name "f*" -okdir echo '{}' \;
< echo ... ./File/file1.txt > ? y
./file1.txt
< echo ... ./File/file2.txt > ? y
./file2.txt
```



##### -prune 액션을 사용하는 경우

```sh
# 대소문자를 구분하지 않고 f로 시작하는 파일 검색
find . -iname "f*"
./findtestfile
./File
./File/file1.txt
./File/File
./File/file2.txt
./pattern/findtestfile

# 검색된 파일이 디렉터리이면 하위 디렉터리는 검색하지 않음
find . -iname "f*" -prune
./findtestfile
./File
./pattern/findtestfile
```



##### -quit 액션을 사용하는 경우

```sh
# p로 시작하는 파일을 만나면 검색 종료
find ./ -name "*.txt" -or -name "p*" -quit
./aa.txt
./expression.txt
./Separator.txt
./File/express.txt
./File/file1.txt
./File/file2.txt
./File/test.txt
./bb.txt
```

---



#### 결과 출력 관련 액션

```
테스트에 의해 검색된 파일들을 목적에 맞게 출력 포맷으로 출력하거나 파일로 저장해 주는 기능들을 제공함.
```

| 옵션                 | 설명                                                         |
| -------------------- | ------------------------------------------------------------ |
| -fls file            | 표현식에 의해 검색된 파일의 결과를 명시한 파일로<br>ls -l을 실행한 것과 유사한 결과를 저장 |
| -fprint file         | 표현식에 의해 검색된 파일의 결과를 명시한 파일에 저장        |
| -fprint0 file        | 표현식에 의해 검색된 파일의 결과를 명시한 파일에 뉴라인이나 공백없이 저장 |
| -printf format       | 역슬래시와 퍼센트로 된 표준 출력 포맷에 맞게 검색된 파일 결과를 보여줌 |
| -fprintf file format | -printf와 비슷하지만 -fprint와 같이 검색된 파일을 명시한 파일에 저장 |
| -ls                  | 표현식에 의해 검색된 파일의 결과를 ls -l을 실행한 것과 유사한 결과를 보여줌 |
| -print;              | 표현식에 의해 검색된 파일의 결과를 보여줌                    |
| -print0              | 표현식에 의해 검색된 파일의 결과를 뉴라인 없이 보여줌        |



##### -fls file 액션을 사용하는 경우

```sh
# f로 시작하는 파일을 찾은 결과를 파일에 저장
find ./ -name "f*" -fls f-file.txt


cat f-file.txt
  3147234      0 -rw-rw-r--   1 jngmk    jngmk           0  5월 22  2020 ./findtestfile
  3147247      4 -rw-rw-r--   1 jngmk    jngmk           5  5월 13  2020 ./File/file1.txt
  3147248      4 -rw-rw-r--   1 jngmk    jngmk           6  5월 13  2020 ./File/file2.txt
  3147252      0 -rw-rw-r--   1 jngmk    jngmk           0  9월 15 17:34 ./f-file.txt
  3147240      0 -rw-rw-r--   1 jngmk    jngmk           0  5월 21  2020 ./pattern/findtestfile
```



##### -fprint file 액션을 사용하는 경우

```sh
# p로 시작하는 파일을 찾은 결과를 파일에 저장
find ./ -name "p*" -fprint p-file.txt


cat p-file.txt
./p-file.txt
./pattern
./pattern/pattern1.txt
./pattern/pattern3.txt
./pattern/pattern2.txt
```



##### -fprint0 file 액션을 취하는 경우

```sh
# 뉴라인이나 공백 없이 결과를 파일에 저장
find ./ -name "p*" -fprint0 p-file2.txt


cat p-file2.txt
/p-file.txt./p-file2.txt./pattern./pattern/pattern1.txt./pattern/pattern3.txt./pattern/pattern2.txt
```



##### -printf format 액션을 사용하는 경우

```sh
# 포맷에 의해 결과를 출력
# %f는 파일명, %c는 마지막 상태 변경 시간을 의미 \n은 뉴라인
find ./ -name "p*" -printf "%f %c\n"
p-file.txt Thu Sep 15 17:35:19.4800589890 2022
p-file2.txt Thu Sep 15 17:36:10.2196342410 2022
pattern Thu Sep 15 17:17:19.4631147000 2022
pattern1.txt Thu Sep 15 17:17:19.4631147000 2022
pattern3.txt Thu Sep 15 17:17:19.4631147000 2022
pattern2.txt Thu Sep 15 17:17:19.4631147000 2022
```



##### -fprintf file format 액션을 사용하는 경우

```sh
# 포맷에 의한 결과를 파일에 저장
find ./ -name "p*" -fprintf p-file3.txt "%f %c\n"


cat p-file3.txt
p-file.txt Thu Sep 15 17:35:19.4800589890 2022
p-file2.txt Thu Sep 15 17:36:10.2196342410 2022
p-file3.txt Thu Sep 15 17:39:45.2658850320 2022
pattern Thu Sep 15 17:17:19.4631147000 2022
pattern1.txt Thu Sep 15 17:17:19.4631147000 2022
pattern3.txt Thu Sep 15 17:17:19.4631147000 2022
pattern2.txt Thu Sep 15 17:17:19.4631147000 2022
```



##### -ls 액션을 사용하는 경우

```sh
# 검색된 파일을 ls -l을 실행한 것처럼 보여줌
find ./ -name "p*" -ls

  3147253      4 -rw-rw-r--   1 jngmk    jngmk          92  9월 15 17:35 ./p-file.txt
  3147254      4 -rw-rw-r--   1 jngmk    jngmk         106  9월 15 17:36 ./p-file2.txt
  3147255      4 -rw-rw-r--   1 jngmk    jngmk         334  9월 15 17:39 ./p-file3.txt
  3147236      4 drwxrwxr-x   2 jngmk    jngmk        4096  5월 21  2020 ./pattern
  3147237      4 -rw-rw-r--   1 jngmk    jngmk          18  5월  8  2020 ./pattern/pattern1.txt
  3147239      4 -rw-rw-r--   1 jngmk    jngmk           9  5월 13  2020 ./pattern/pattern3.txt
  3147238      4 -rw-rw-r--   1 jngmk    jngmk          11  5월  8  2020 ./pattern/pattern2.txt
```



##### -print 액션을 사용하는 경우

```sh
# 검색된 파일을 보여줌 ( find의 기본 액션 )
find ./ -name "p*" -print
./p-file.txt
./p-file2.txt
./p-file3.txt
./pattern
./pattern/pattern1.txt
./pattern/pattern3.txt
./pattern/pattern2.txt
```



##### -print0 액션을 사용하는 경우

```sh
# 공백이나 뉴라인 없이 검색된 파일을 보여줌
find . -name "p*" -print0
./p-file.txt./p-file2.txt./p-file3.txt./pattern./pattern/pattern1.txt./pattern/pattern3.txt./pattern/pattern2.txt
```

---



### 4) 위치 옵션

```
위치 옵션은 테스트 수행 시 테스트에 영향을 줌.
-daystart, -follow 및 -regextype을 제외한 모든 위치 옵션은
위치 옵션 앞에 지정된 테스트를 포함하여 모든 테스트에 영향을 줌.
이는 명령줄을 구문 분석할 때 위치 옵션이 처리되고 파일이 검사될 때까지 테스트는 수행되지 않기 때문.
이와 반대로 -daystart, -follow 및 -regextype 위치 옵션은
명령 행에서 나중에 나타나는 테스트에만 영향을 미침.
따라서 명확성을 위해 표현의 시작 부분에 배치하는 것이 가장 좋음
```

| 위치 옵션        | 설명                                                         |
| ---------------- | ------------------------------------------------------------ |
| -d               | FreeBSD, NetBSD, MacOS X 및 OpenBSD와의 호환성을 위한 -depth 동의어 |
| -depth           | 서브 디렉터리의 파일을 먼저 검색                             |
| -daystart        | 24시간이 아닌 해당일을 기준으로 파일 검색<br>-amin, -atime, -cmin, -ctime, -mmin 및 -mtime과 함께 사용해야 함 |
| -regexttype type | -regex나 -iregex의 정규식 구문을 변경<br>기본 유형은 emacs임. posix-awk, posix-basic, posix-egrep, posix-extended가 있음 |
| -maxdepth levels | 명시한 level만큼 서브 디렉터리의 파일을 검색                 |
| -mindepth levels | 명시한 level만큼 서브 디렉터리부터 파일을 검색함             |
| -mount           | USB나 CD-ROM과 같은 시스템의 파일을 검색하지 않음            |
| -warn<br>-nowarn | 경고 메시지를 켜거나 끔. 경고는 명령줄 사용법에만 적용되며<br>디렉터리를 검색할 때 발견되는 조건에는 적용되지 않음.<br>표준 입력이 tty이면 -warn, 그렇지 않으면 -nowarn에 해당함 |



##### -depth 위치 옵션을 사용하는 경우

```sh
# 서브 디렉터리부터 검색됨을 확인
find . -name "p*"
./pattern
./pattern/pattern1.txt
./pattern/pattern3.txt
./pattern/pattern2.txt

# 서브 디렉터리의 파일부터 검색됨을 확인
find ./ -depth -name "p*"
./pattern/pattern1.txt
./pattern/pattern3.txt
./pattern/pattern2.txt
./pattern
```



##### -daystart 위치 옵션을 사용하는 경우

```sh
# 현재 시각을 기준으로 24시간 내에 수정된 파일 검색
find ./ -ctime 0
./
./findtestfile
./expression.tar.gz
./aa.txt
./expression.txt
./Separator.txt

# 현재 시각을 기준으로 현재 날짜에 수정된 파일 검색
find ./ -daystart -ctime 0
./
./findtestfile
./expression.tar.gz
./aa.txt
./expression.txt
./Separator.txt
```



##### -regextype 위치 옵션을 사용하는 경우

```sh
# POSIX 형식의 패턴을 사용했을 경우
find ./ -regex "./[[:lower:]]*"


# 패턴 타입을 변경했을 경우
find ./ -regextype posix-basic -regex './[[:lower:]]*'
./
./findtestfile
./pattern
```



##### -maxdepth levels 위치 옵션을 사용하는 경우

```sh
# 명시된 깊이까지만 검색됨
find ./ -maxdepth 1 -name "p*"
./p-file.txt
./p-file2.txt
./p-file3.txt
./pattern
```



##### -warn, -nowarn 위치 옵션을 사용하는 경우

```sh
# -warn에 의해 발생된 경고 메시지
find ./ -name findtestfile -depth -warn
find: warning: you have specified the global option -depth after the argument -name, but global options are not positional, i.e., -depth affects tests specified before it as well as those specified after it.  Please specify global options before other arguments.
./findtestfile
./pattern/findtestfile

# 경고 메시지 끄기
find ./ -name findtestfile -depth -nowarn
```

---



## 3. find 옵션

### 1) 심볼릭 링크 관련 옵션

| 옵션 | 설명                                                         |
| ---- | ------------------------------------------------------------ |
| -P   | 파일을 검사할 때 심볼릭 링크인 경우, 심볼릭 링크 자체의 속성을 검사하며<br>find의 기본 옵션임 |
| -L   | 파일을 검사할 때 파일이 심볼릭 링크인 경우, 심볼릭 링크에 연결된 파일의 속성을 검사하며<br>검사되는 모든 파일 목록을 보여줌 |
| -H   | 파일을 검사할 때 파일이 심볼릭 링크인 경우, 심볼릭 링크 자체의 속성을 검사하나<br>명령 행에 지정된 파일이 심볼릭 링크인 경우 심볼릭 링크에 연결된 파일의 속성을 검사 |



##### -P 옵션을 사용하는 경우

```SH
find -P ./ -type f -name "e*"
./expression.tar.gz
./expression.txt
```



##### -L 옵션을 사용하는 경우

```sh
# 타입이 파일이고 e로 시작하는 파일 검색
find -L ./ -type f -name "e*"
./expression.tar.gz
./expression.txt
./File/express.txt

# express.txt 파일 속성 확인
file ./File/express.txt
./File/express.txt: symbolic link to ../expression.txt
```

---



### 2) 디버그 관련 옵션

| 옵션      | 설명                                                         |
| --------- | ------------------------------------------------------------ |
| -D tree   | 표현식 트리를 원래의 최적화된 형태로 보여줌                  |
| -D search | 디렉터리 트리를 자세하게 탐색                                |
| -D stat   | stat이나 lstat과 같은 시스템 호출이 필요한 파일을 검사할 때 메시지를 출력 |
| -D rates  | 표현식이 얼마나 성공했는지 요약해서 보여줌                   |
| -D opt    | 표혀신식 tree 최적화와 관련된 진단 정보를 보여줌<br>최적화와 관련된 -O 옵션을 참조하여 사용할 수 있음 |



##### -D tree 옵션을 사용하는 경우

```sh
# 표현식 트리를 보여줌
find -D tree ./ -name "e*"
Predicate List:
[(] [-name] [)] [-a] [-print] 
Eval Tree:
pred=[-a] type=bi_op prec=and cost=Unknown est_success_rate=0.8000 no side effects 
left:
    pred=[-name e*] type=primary prec=no cost=Unknown est_success_rate=0.8000 no side effects 
    no children.
right:
...
```



##### -D search 옵션을 사용하는 경우

```sh
# 검색 과정을 보여줌
find -D search ./ -name "e*" -exec ls -l '{}' \;
consider_visiting (early): ‘./’: fts_info=FTS_D , fts_level= 0, prev_depth=-2147483648 fts_path=‘./’, fts_accpath=‘./’
consider_visiting (late): ‘./’: fts_info=FTS_D , isdir=1 ignore=0 have_stat=1 have_type=1 
consider_visiting (early): ‘./findtestfile’: fts_info=FTS_NSOK, fts_level= 1, prev_depth=0 fts_path=‘./findtestfile’, fts_accpath=‘findtestfile’
consider_visiting (late): ‘./findtestfile’: fts_info=FTS_NSOK, isdir=0 ignore=0 have_stat=0 have_type=1 
consider_visiting (early): ‘./expression.tar.gz’: fts_info=FTS_NSOK, fts_level= 1, prev_depth=1 fts_path=‘./expression.tar.gz’, fts_accpath=‘expression.tar.gz’
consider_visiting (late): ‘./expression.tar.gz’: fts_info=FTS_NSOK, isdir=0 ignore=0 have_stat=0 have_type=1 
-rw-rw-r-- 1 jngmk jngmk 750  5월 13  2020 ./expression.tar.gz
...
```



##### -D stat 옵션을 사용하는 경우

```sh
# stat 시스템 호출이 일어난 경우를 보여줌
find -D stat ./ -perm 600 -name "e*"
debug_stat (expression.tar.gz)
debug_stat (expression.txt)
./expression.txt
debug_stat (express.txt)
```



##### -D rates 옵션을 사용하는 경우

```sh
# 표현식 성공률을 요약해서 보여줌
find -D rates ./ -perm 600 -name "e*"
./expression.txt
Predicate success rates after completion:
 ( -name e* [est success rate 0.8] [real success rate 3/25=0.12] -a [est success rate 0.01] [real success rate 1/25=0.04] [call stat] [need type] -perm 600 [est success rate 0.01] [real success rate 1/3=0.3333]  ) -a [est success rate 0.008] [real success rate 1/25=0.04] -print [est success rate 1] [real success rate 1/1=1]
```



##### -D opt 옵션을 사용하는 경우

```sh
# 표현식 실행 순서가 어떻게 최적화되어 실행되는지를 보여줌
find -O1 -D opt ./ -perm 600 -name "e*"
Predicate List:
[(] [-perm] [-a] [-name] [)] [-a] [-print] 
...
Optimized command line:
 ( -name e* [est success rate 0.8] -a [est success rate 0.01] [call stat] [need type] -perm 600 [est success rate 0.01]  ) -a [est success rate 0.008] -print [est success rate 1] 
./expression.txt
```

---



### 3) 레벨 관련 옵션

```
쿼리 최적화를 활성화함. find를 사용하여 파일을 검색할 때 사용된 전반적인 테스트의 효과를 유지하면서
실행 속도를 높이기 위해 테스트 순서를 변경함
```

| 옵션 | 설명                                                         |
| ---- | ------------------------------------------------------------ |
| -O0  | 최적화 수준 1과 같음                                         |
| -O1  | 기본 최적화 수준으로 파일이름을 기반으로 하는 테스트가 먼저 수행되도록 식 순서가 바뀜 |
| -O2  | -type이나 -xtype과 함께 사용할 때 -name을 테스트한 후 -type 테스트를 수행함 |
| -O3  | 전체 비용 기반 쿼리 최적화 프로그램이 활성화됨<br>-o의 경우 성공할 수 있는 표현식이 더 빨리 평가되고<br>-a의 경우 실패할 수 있는 표현식이 더 빨리 평가됨 |



##### -O0 옵션을 사용하는 경우

```sh
# 파일 권한, 파일명 순서로 검색하면 파일명, 권한 순서로 변경됨을 알 수 있음
find -O0 -D opt ./ -perm 600 -name "e*"
...
Optimized command line:
 ( -name e* [est success rate 0.8] -a [est success rate 0.01] [call stat] [need type] -perm 600 [est success rate 0.01]  ) -a [est success rate 0.008] -print [est success rate 1] 
./expression.txt
```



##### -O1 옵션을 사용하는 경우

```sh
# 파일 권한, 파일명 순서로 검색하면 파일명, 권한 순서로 변경됨을 알 수 있음
find -O1 -D opt ./ -perm 600 -name "e*"
...
Optimized command line:
 ( -name e* [est success rate 0.8] -a [est success rate 0.01] [call stat] [need type] -perm 600 [est success rate 0.01]  ) -a [est success rate 0.008] -print [est success rate 1] 
./expression.txt
```



##### -O2 옵션을 사용하는 경우

```sh
# -O1은 파일명을 찾고 그 다음 단계로 넘어감
find -O1 -D opt ./ -type l -name "e*"
...
Optimized command line:
 ( -name e* [est success rate 0.8] -a [est success rate 0.0311] [need type] -type l [est success rate 0.0311]  ) -a [est success rate 0.02488] -print [est success rate 1] 
./File/express.txt

# -O2는 파일명을 찾고 바로 이어 파일 타입 평가한 후 다음 단계로 넘어감
find -O2 -D opt ./ -type l -name "e*"
```



##### -O3 옵션을 사용하는 경우

```sh
# -a 연산자일 경우 평가율이 0.02488
find -O3 -D opt ./ -type l -a -name "e*"
...
Optimized command line:
 ( -name e* [est success rate 0.8] -a [est success rate 0.0311] [need type] -type l [est success rate 0.0311]  ) -a [est success rate 0.02488] -print [est success rate 1] 
./File/express.txt

# -o 연산의 경우 평가율이 0.8311
find -O3 -D opt ./ -type l -o -name "e*"
```

