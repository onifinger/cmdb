# dockerのインストール  

## OSセットアップ  
entOS Linux release 7.3.1611 をminimul インストール  

## yumの設定  
環境に応じてProxyを設定する。  

環境に応じてリポジトリサーバの設定を行う。  
下記はftp.riken.jpに変更する場合。
```
# cd /etc/yum.repos.d
# sed -i -e "s/^mirrorlist\=http\:\/\/mirrorlist\.centos\.org\//\#mirrorlist\=http\:\/\/mirrorlist\.centos\.org\//g" ./*
# sed -i -e "s/^\#baseurl\=http\:\/\/mirror\.centos\.org\//baseurl\=http\:\/\/ftp\.riken\.jp\/Linux\//g" ./*
```

## リポジトリの設定  
必要に応じてリポジトリの追加を行う。docker単体であれば追加不要。  
下記はepelを追加  
```
# cd /etc/yum.repos.d
# yum install epel-release -y
# sed -i -e "s/^mirrorlist\=https\:\/\/mirrors\.fedoraproject\.org/\#mirrorlist\=https\:\/\/mirrors\.fedoraproject\.org/g" ./*
# sed -i -e "s/^#baseurl\=http\:\/\/download.fedoraproject.org\/pub/baseurl\=http\:\/\/ftp\.riken\.jp\/Linux\/fedora/g" ./*
```

## ansible , git のインストール
```
# yum install ansible git -y
```

## dockerセットアップ用Playbookの作成
```
# mkdir ~/docker
# cd ~/docker
# mkdir -p roles/common/{tasks,handlers,templates,files,vars,defaults,meta,library}
```

## SELINUX無効  
```
# vi /etc/sysconfig/selinux
･･･
SELINUX=disabled
･･･
# setenforce 0
```
## firewalld 無効  
```
# systemctl stop firewalld
# systemctl disable firewalld
```
## iptables 有効  
```
# yum install iptables-services
# systemctl start iptables
# systemctl enable iptables
```

## dockerインストール  
```
# yum install docker -y
# systemctl start docker
# systemctl enable docker
```

## proxyの設定
```
vi /lib/systemd/system/docker.service 
```
Serviceのセクションにプロキシの設定追加
```
[Service]
...
Environment="HTTP_PROXY=http://user:pass@xx.xx.xx.xx:XXXX"
ExecStart=/usr/bin/dockerd-current \
```
```
systemctl daemon-reload
systemctl restart docker
```

## 必要ではないが何かと使うツールのインストール  
```
# yum install bridge-utils net-tools telnet wget tcpdump git -y
# yum install epel-release -y
# yum install ansible -y
```

## 今回の環境で、Apache,Squidを使用するため、インストール。
```
# yum install httpd squid -y
# iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
# iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 3128 -j ACCEPT
# systemctl start httpd
# systemctl start squid
# systemctl enable httpd
# systemctl enable squid
# vi /etc/sysconfig/iptables
```
```
# sample configuration for iptables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 3128 -j ACCEPT
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
```
