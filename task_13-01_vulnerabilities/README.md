# Домашнее задание к занятию «Уязвимости и атаки на информационные системы» - Модонов Николай

## Задание 1. Сканирование Metasploitable

Была просканирована виртуальная машина Metasploitable (IP 10.10.10.5) с помощью nmap с хоста Debian (Vagrant). Сканирование выполнялось с опцией -Pn (отключение ICMP-проверки).

### Разрешённые сетевые службы

По результатам полного сканирования портов (nmap -p-) и определения версий (nmap -sV) обнаружены следующие службы:

- 21/tcp – vsftpd 2.3.4
- 22/tcp – OpenSSH 4.7p1 Debian 8ubuntu1
- 23/tcp – Telnet (Linux telnetd)
- 25/tcp – Postfix smtpd
- 53/tcp – ISC BIND 9.4.2
- 80/tcp – Apache httpd 2.2.8
- 111/tcp – rpcbind 2
- 139/tcp – Samba smbd 3.X – 4.X
- 445/tcp – Samba smbd 3.X – 4.X
- 512/tcp – netkit-rsh rexecd
- 513/tcp – rlogin
- 514/tcp – Netkit rshd
- 1099/tcp – Java RMI (GNU Classpath grmiregistry)
- 1524/tcp – bindshell (Metasploitable root shell)
- 2049/tcp – NFS 2-4
- 2121/tcp – ProFTPD 1.3.1
- 3306/tcp – MySQL 5.0.51a
- 5432/tcp – PostgreSQL 8.3.0 – 8.3.7
- 5900/tcp – VNC 3.3
- 6000/tcp – X11
- 6667/tcp – UnrealIRCd
- 8009/tcp – Apache Jserv (AJP13)
- 8180/tcp – Apache Tomcat

### Обнаруженные уязвимости

На основе версий служб были найдены следующие уязвимости (источник – exploit-db.com):

1. **vsftpd 2.3.4** – бэкдор, позволяющий удалённое выполнение команд с правами root.  
   Ссылка: https://www.exploit-db.com/exploits/17491

2. **UnrealIRCd 3.2.8.1** – бэкдор, позволяющий удалённое выполнение кода.  
   Ссылка: https://www.exploit-db.com/exploits/13853

3. **Samba 3.0.20** – удалённое выполнение команд через username map script (CVE-2007-2447).  
   Ссылка: https://www.exploit-db.com/exploits/16320

---

## Задание 2. Сканирование в режимах SYN, FIN, Xmas, UDP

Были выполнены сканирования Metasploitable в различных режимах. Результаты:

- **SYN-сканирование** – все порты показаны как `open`, так как сервер отвечает SYN+ACK.
- **FIN-сканирование** – все порты показаны как `open|filtered`, т.к. открытые порты игнорируют FIN-пакеты.
- **Xmas-сканирование** – аналогично FIN: `open|filtered` для всех портов.
- **UDP-сканирование** – команда не завершилась (повисла), что характерно для медленных UDP-сканирований или отсутствия ответов от сервера.

### Отличия режимов с точки зрения трафика

- **SYN** – отправляется TCP-пакет с флагом SYN. Сервер отвечает SYN+ACK (порт открыт) или RST (закрыт).
- **FIN** – отправляется TCP-пакет с флагом FIN без установленного соединения. Закрытые порты отвечают RST, открытые игнорируют пакет.
- **Xmas** – отправляется TCP-пакет с флагами FIN, PSH, URG. Открытые порты игнорируют, закрытые отвечают RST.
- **UDP** – отправляется UDP-пакет. Закрытые порты возвращают ICMP "Port Unreachable", открытые либо не отвечают, либо возвращают UDP-ответ.

### Как отвечает сервер

- **SYN**: открытые порты – `open` (ответ SYN+ACK).
- **FIN / Xmas**: все порты – `open|filtered` (сервер не даёт RST, что характерно для Linux).
- **UDP**: на практике – долгое ожидание, часто без ответа (если порт открыт) или ICMP (если закрыт).

Таким образом, SYN-сканирование является наиболее точным для определения открытых портов, в то время как FIN и Xmas могут использоваться для обхода некоторых файрволов, но на Linux дают неопределённый результат.

---

## Вывод команд в консоли

```bash
vagrant@bookworm:~$ nmap -Pn -p- 10.10.10.5
Starting Nmap 7.93 ( https://nmap.org ) at 2026-09-03 06:15 UTC
Nmap scan report for 10.10.10.5
Host is up (0.00051s latency).
Not shown: 65505 closed tcp ports (conn-refused)
PORT      STATE SERVICE
21/tcp    open  ftp
22/tcp    open  ssh
23/tcp    open  telnet
25/tcp    open  smtp
53/tcp    open  domain
80/tcp    open  http
111/tcp   open  rpcbind
139/tcp   open  netbios-ssn
445/tcp   open  microsoft-ds
512/tcp   open  exec
513/tcp   open  login
514/tcp   open  shell
1099/tcp  open  rmiregistry
1524/tcp  open  ingreslock
2049/tcp  open  nfs
2121/tcp  open  ccproxy-ftp
3306/tcp  open  mysql
3632/tcp  open  distccd
5432/tcp  open  postgresql
5900/tcp  open  vnc
6000/tcp  open  X11
6667/tcp  open  irc
6697/tcp  open  ircs-u
8009/tcp  open  ajp13
8180/tcp  open  unknown
8787/tcp  open  msgsrvr
35779/tcp open  unknown
38220/tcp open  unknown
46295/tcp open  unknown
48699/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 6.11 seconds
```

```bash
vagrant@bookworm:~$ nmap -sV -Pn 10.10.10.5
Starting Nmap 7.93 ( https://nmap.org ) at 2026-09-03 06:18 UTC
Nmap scan report for 10.10.10.5
Host is up (0.0014s latency).
Not shown: 977 closed tcp ports (conn-refused)
PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         vsftpd 2.3.4
22/tcp   open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
23/tcp   open  telnet      Linux telnetd
25/tcp   open  smtp        Postfix smtpd
53/tcp   open  domain      ISC BIND 9.4.2
80/tcp   open  http        Apache httpd 2.2.8 ((Ubuntu) DAV/2)
111/tcp  open  rpcbind     2 (RPC #100000)
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
512/tcp  open  exec        netkit-rsh rexecd
513/tcp  open  login?
514/tcp  open  shell       Netkit rshd
1099/tcp open  java-rmi    GNU Classpath grmiregistry
1524/tcp open  bindshell   Metasploitable root shell
2049/tcp open  nfs         2-4 (RPC #100003)
2121/tcp open  ftp         ProFTPD 1.3.1
3306/tcp open  mysql       MySQL 5.0.51a-3ubuntu5
5432/tcp open  postgresql  PostgreSQL DB 8.3.0 - 8.3.7
5900/tcp open  vnc         VNC (protocol 3.3)
6000/tcp open  X11         (access denied)
6667/tcp open  irc         UnrealIRCd
8009/tcp open  ajp13       Apache Jserv (Protocol v1.3)
8180/tcp open  http        Apache Tomcat/Coyote JSP engine 1.1
Service Info: Hosts:  metasploitable.localdomain, irc.Metasploitable.LAN; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 53.34 seconds
```

```bash
root@bookworm:/home/vagrant# nmap -sS -Pn 10.10.10.5  # SYN
Starting Nmap 7.93 ( https://nmap.org ) at 2026-09-03 06:41 UTC
Nmap scan report for 10.10.10.5
Host is up (0.00022s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh
23/tcp   open  telnet
25/tcp   open  smtp
53/tcp   open  domain
80/tcp   open  http
111/tcp  open  rpcbind
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
512/tcp  open  exec
513/tcp  open  login
514/tcp  open  shell
1099/tcp open  rmiregistry
1524/tcp open  ingreslock
2049/tcp open  nfs
2121/tcp open  ccproxy-ftp
3306/tcp open  mysql
5432/tcp open  postgresql
5900/tcp open  vnc
6000/tcp open  X11
6667/tcp open  irc
8009/tcp open  ajp13
8180/tcp open  unknown
MAC Address: 08:00:27:BC:7C:1D (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.46 seconds
```

```bash
root@bookworm:/home/vagrant# nmap -sF -Pn 10.10.10.5  # FIN
Starting Nmap 7.93 ( https://nmap.org ) at 2026-09-03 06:41 UTC
Nmap scan report for 10.10.10.5
Host is up (0.00026s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE         SERVICE
21/tcp   open|filtered ftp
22/tcp   open|filtered ssh
23/tcp   open|filtered telnet
25/tcp   open|filtered smtp
53/tcp   open|filtered domain
80/tcp   open|filtered http
111/tcp  open|filtered rpcbind
139/tcp  open|filtered netbios-ssn
445/tcp  open|filtered microsoft-ds
512/tcp  open|filtered exec
513/tcp  open|filtered login
514/tcp  open|filtered shell
1099/tcp open|filtered rmiregistry
1524/tcp open|filtered ingreslock
2049/tcp open|filtered nfs
2121/tcp open|filtered ccproxy-ftp
3306/tcp open|filtered mysql
5432/tcp open|filtered postgresql
5900/tcp open|filtered vnc
6000/tcp open|filtered X11
6667/tcp open|filtered irc
8009/tcp open|filtered ajp13
8180/tcp open|filtered unknown
MAC Address: 08:00:27:BC:7C:1D (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 1.72 seconds
```

```bash
root@bookworm:/home/vagrant# nmap -sX -Pn 10.10.10.5  # Xmas
Starting Nmap 7.93 ( https://nmap.org ) at 2026-09-03 06:42 UTC
Nmap scan report for 10.10.10.5
Host is up (0.00033s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE         SERVICE
21/tcp   open|filtered ftp
22/tcp   open|filtered ssh
23/tcp   open|filtered telnet
25/tcp   open|filtered smtp
53/tcp   open|filtered domain
80/tcp   open|filtered http
111/tcp  open|filtered rpcbind
139/tcp  open|filtered netbios-ssn
445/tcp  open|filtered microsoft-ds
512/tcp  open|filtered exec
513/tcp  open|filtered login
514/tcp  open|filtered shell
1099/tcp open|filtered rmiregistry
1524/tcp open|filtered ingreslock
2049/tcp open|filtered nfs
2121/tcp open|filtered ccproxy-ftp
3306/tcp open|filtered mysql
5432/tcp open|filtered postgresql
5900/tcp open|filtered vnc
6000/tcp open|filtered X11
6667/tcp open|filtered irc
8009/tcp open|filtered ajp13
8180/tcp open|filtered unknown
MAC Address: 08:00:27:BC:7C:1D (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 1.93 seconds
```
