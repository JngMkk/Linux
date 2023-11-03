#!/bin/bash

# 서명용 호스트 초기화
echo "==============================================="
echo "          Initializing signing host            "
echo "==============================================="

# 레드햇 리눅스에는 일반적으로 /etc/pki/CA 디렉터리가 존재함.
# 해당 디렉터리에 index.txt 파일을 생성하고
# serial 1000이라는 숫자를 입력하여 파일을 생성
# 이는 마지막에 인증서를 생성할 때 index.txt에 발행한 인증서 정보를 저장하고
# serial에 발급된 인증서 수를 등록하기 위함임
touch /etc/pki/CA/index.txt
echo '1000' | tee /etc/pki/CA/serial

# 인증 기관용 인증서 생성
echo "==============================================="
echo "      Creating a certificate authority         "
echo "==============================================="

echo "-----------------------------------------------"
echo "            Generate rsa ca key                "
echo "-----------------------------------------------"

# RSA 개인 키를 생성함
# 이때 키는 -out 옵션 다음에 오는 ca.key.pem 파일에 저장되고
# 4096은 생성되는 키의 사이즈를 말함
# 가장 기본적인 방법으로 키를 생성하였지만
# 다른 옵션(-aes256, -camellia256, --des3과 같은 옵션)을 사용하여 생성되는 키의 암호화 방식을 설정할 수 있음.
# 개인 키가 생성되면 openssl req 명령어를 이용하여 앞에서 생성한 키를 이용하여 인증 기관용 인증요청서를 생성함.
openssl genrsa -out ca.key.pem 4096

echo "-----------------------------------------------"
echo "          Generate rsa ca cert key             "
echo "-----------------------------------------------"
openssl req -key ca.key.pem -new -x509 -days 7300 -extensions v3_ca -out ca.crt.pem

# 클라이언트에 인증기관용 인증서 추가
echo "==============================================="
echo "  Adding the certificate authority to clients  "
echo "==============================================="
echo "cp ca.crt.pem /etc/pki/ca-trust/source/anchors/"
cp ca.crt.pem /etc/pki/ca-trust/source/anchors/

# 자기 스스로 인증한 인증서이므로
# 앞에서 생성한 인증요청서를 /etc/pki/ca-trust/source/anchors/ 디렉터리에 복사하고
# update-ca-trust extract 명령어를 이용하여 믿을 수 있는 인증서라고 시스템이 인식할 수 있도록 만들어 줌
echo "update-ca-trust extract"
update-ca-trust extract

# SSL/TLS 서버 키 생성
echo "==============================================="
echo "          Creating an SSL/TLS key              "
echo "==============================================="

# 클라이언트에서 사용할 SSL/TLS를 위한 서버 키를 CA 개인 키를 만들 때처럼
# openssl genrsa 명령어를 이용하여 서버 개인 키를 만들어 줌
# /etc/pki/tls/openssl.cnf를 인증서 생성 디렉터리에 복사
# 원래는 복사 후 cnf 파일을 사용하기 편리하게 수정하지만 생략
openssl genrsa -out server.key.pem 2048

# SSL/TLS 인증요청서 생성
echo "==============================================="
echo "Creating an SSL/TLS certificate signing request"
echo "==============================================="
cp /etc/pki/tls/openssl.cnf .
openssl req -config openssl.cnf -key server.key.pem -new -out server.csr.pem

# SSL/TLS 인증서 생성
echo "==============================================="
echo "      Creating the SSL/TLS certificate         "
echo "==============================================="

# 앞에서 생성한 서버용 인증요청서와 인증기관용 개인 키 및 인증요청서를 가지고 인증서를 발급받음
# 발급받는 인증서는 -out 옵션을 이용하여 server.crt.pem 파일에 저장
openssl ca -config openssl.cnf -extensions v3_req -days 3650 -in server.csr.pem -out server.crt.pem -cert ca.crt.pem -keyfile ca.key.pem