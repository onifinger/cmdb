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

## dockerセットアップ用Playbookのダウンロード
```
# cd ~/
# git clone http://github.com/taka379sy/cmdb.git
```

## インストール
```
# cd ~/cmdb/docker
```
dockerリポジトリサーバへのアクセスに、proxyの設定が必要な場合、以下のファイルの編集を行う。
```
# vi roles/docker/vars/main.yml
```
```
# proxyを使うときはy 使わないときはn
use_proxy: n
# 認証ありの場合:http://user:password@host:port
# 認証なしの場合:http://host:port
proxy_server: 'http://user:password@host:port'
# プロキシサーバを利用しないプライベートレジストリありはy なしはn
use_no_proxy: n
# プロキシサーバを利用しないプライベートレジストリ
no_proxy: 'no_proxy=local.example.com,192.168.1.1'
```
追加で使用したいパッケージがある場合は、以下のファイルを編集
```
# vi roles/additioanl_packages/vars/main.yml
```
```
pkgs:
  - bridge-utils
  - net-tools
  - telnet
  - wget
  - tcpdump
  - sysstat
```
インストール
```
# ansible-playbook docker.yml --connection=local -i hosts
```
## 上記プレイブックは、以下の処理を行っている。
### SELINUX　無効  
### firewalld　停止、無効  
### iptables　インストール、有効、起動  
### docker　インストール、proxy設定、有効、起動  
### 必須ではないが何かと使うツールのインストール  
