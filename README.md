와이어가드 서버설정이 완료 된 경우 활용할 수 있는 스크립트입니다.

클라이언트용 설정파일을 생성하고 서버 설정파일에 해당 피어를 허용하는 내용을 자동으로 진행합니다.
완료후 클라이언트용 설정파일을 받을 수 있는 QR코드를 제공합니다.

---

**의존성**
```bash
wireguard
qrencode
```

---

**실행법**
```bash
sh ./gen_conf.sh 피어이름 할당ip마지막자리
```

*ex) sh ./gen_conf.sh user 123*  -> **user**라는 이름의 사용자에게 **10.0.0.123** IP를 할당하는 작업을 시작합니다.
