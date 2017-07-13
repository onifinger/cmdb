# dockerのインストール  

## OSセットアップ  
CentOS Linux release 7.3.1611 をminimul インストール  

## yumの設定  
### 環境に応じてProxyを設定
### 環境に応じてリポジトリの設定  
下記はftp.riken.jpに変更する場合。
```
# cd /etc/yum.repos.d
# sed -i -e "s/^mirrorlist\=http\:\/\/mirrorlist\.centos\.org\//\#mirrorlist\=http\:\/\/mirrorlist\.centos\.org\//g" ./*
# sed -i -e "s/^\#baseurl\=http\:\/\/mirror\.centos\.org\//baseurl\=http\:\/\/ftp\.riken\.jp\/Linux\//g" ./*
```
### リポジトリの追加  
docker単体であれば追加不要だが、今回、ansibleを使用するためEPELを追加する。  
下記はリポジトリサーバを、ftp.riken.jpに変更もしている。
```
# cd /etc/yum.repos.d
# yum install epel-release -y
# sed -i -e "s/^mirrorlist\=https\:\/\/mirrors\.fedoraproject\.org/\#mirrorlist\=https\:\/\/mirrors\.fedoraproject\.org/g" ./*
# sed -i -e "s/^#baseurl\=http\:\/\/download.fedoraproject.org\/pub/baseurl\=http\:\/\/ftp\.riken\.jp\/Linux\/fedora/g" ./*
```

## OSを最新の状態にアップデート、再起動
```
# yum update -y
# shutdown -h now
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

## dockerのインストール
```
# cd ~/cmdb/docker
```
### proxyの設定
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
### 追加で使用したいパッケージ一覧の編集
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
### インストール
```
# ansible-playbook docker.yml --connection=local -i hosts
```
## 【参考】上記プレイブックでは、以下の処理を行っている。
1. SELINUX　無効  
2. firewalld　停止、無効  
3. iptables　インストール、有効、起動  
4. docker　インストール、proxy設定、有効、起動  
5. 必須ではないが何かと使うツールのインストール  