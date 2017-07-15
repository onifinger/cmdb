# dockerのインストール  

## OSセットアップ  
CentOS Linux release 7.3.1611 をminimul インストール  

## yumの設定  
### 環境に応じてProxyを設定
yum.confに設定
```
proxy=http://proxy_ipaddress:proxy_port
proxy_username=proxy_user
proxy_password=proxy_password
```
### 必要に応じてリポジトリサーバの設定変更  
下記は近場のftp.riken.jpに変更する場合。  
mirrorlistをコメントアウトして、baseurlで直指定。
```
# cd /etc/yum.repos.d
# sed -i -e "s/^mirrorlist\=http\:\/\/mirrorlist\.centos\.org\//\#mirrorlist\=http\:\/\/mirrorlist\.centos\.org\//g" ./*
# sed -i -e "s/^\#baseurl\=http\:\/\/mirror\.centos\.org\//baseurl\=http\:\/\/ftp\.riken\.jp\/Linux\//g" ./*
```
### リポジトリの追加  
docker単体であれば追加不要だが、今回、ansibleを使用するためEPELを追加する。  
下記は近場のftp.riken.jpに変更する場合。  
```
# cd /etc/yum.repos.d
# yum install epel-release -y
# sed -i -e "s/^mirrorlist\=https\:\/\/mirrors\.fedoraproject\.org/\#mirrorlist\=https\:\/\/mirrors\.fedoraproject\.org/g" ./*
# sed -i -e "s/^#baseurl\=http\:\/\/download.fedoraproject.org\/pub/baseurl\=http\:\/\/ftp\.riken\.jp\/Linux\/fedora/g" ./*
```

## OSを最新の状態にアップデート、再起動
```
# yum update -y
# shutdown -r now
```

## ansible , git のインストール
```
# yum install ansible git -y
```

## dockerセットアップ用Playbookのダウンロード
環境に応じてgitで使用するProxyを設定
```
# git config --global http.proxy http://proxy_user:proxy_password@proxy_ipaddress:proxy_port
```
プレイブックのダウンロード
```
# cd /opt
# git clone http://github.com/taka379sy/cmdb.git
```

## OSの設定
```
# cd /opt/cmdb/docker
```
### ansible実行用のユーザ編集
パスワード、UIDの変更を行いたい場合は修正。
```
# vi roles/useradd/vars/main.yml
```
```
users:
  - { name: 'ansibleuser', password: "{{ 'password'|password_hash('sha512')}}" , uid: '601' }
```
### 追加で使用したいパッケージ一覧の編集
dockerとは別に、追加で使用したいパッケージがある場合は、以下のファイルを編集
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
  - bind-utils
```
### ansbibleでOSの設定を行う。
```
# ansible-playbook os.yml --connection=local -i hosts -l localhost
# 
```
### 【参考】上記プレイブックでは、以下の処理を行っている。
1. ansible用のユーザ追加(group作成、sudo、SSH公開鍵、環境変数の設定も行う。)
2. この後pipで追加インストールする、Pythonモジュール用の環境設定。
3. SELINUX　停止、無効  
4. firewalld　停止、自動起動無効  
5. iptables　インストール、自動起動有効、起動  
6. ansibleの設定変更（bash、SSH接続、ログの設定、プレイブックの所有者の変更）
7. 必須ではないが何かと使うツールのインストール  

## dockerのインストール
以降の作業は、上記で作成したアカウント(ansibleuser)で実行する。
```
# cd /opt/cmdb/docker
```
### proxyの設定
dockerリポジトリサーバへのアクセスに、proxyの設定が必要な場合、以下のファイルの編集を行う。  
環境に応じてgitで使用するProxyを設定
```
# git config --global http.proxy http://proxy_user:proxy_password@proxy_ipaddress:proxy_port
```
```
# vi /opt/cmdb/docker/host_vars/localhost
```
適宜、Proxyの設定等を行う。
```
# proxyを使うときはy 使わないときはn
use_proxy: n

# 認証ありの場合:http://user:password@host:port
# 認証なしの場合:http://host:port
#proxy_server: 'http://user:password@host:port'
prsv: '192.168.1.1'
prpt: '8080'
prus: 'user'
prpw: 'password'
proxy_server: "http://{{ prus }}:{{ prpw }}@{{ prsv }}:{{ prpt }}"

# プロキシサーバを利用しないプライベートレジストリありはy なしはn
use_no_proxy: n

# プロキシサーバを利用しないプライベートレジストリ
no_proxy: 'no_proxy=local.example.com,192.168.1.1'

# Pythonモジュールをインストールするディレクトリ
pydir: /opt/ansible_python
pypath: "{{ pydir }}/lib/python2.7/site-packages"

# 独自ネットワークの設定 ネットワーク名、サブネット、ゲートウェイ（ホストアドレス）、DHCP帯域
network_name: bridge2
subnet: 192.168.10.0/24
gateway: 192.168.10.1
iprange: 192.168.10.64/26
```
### インストール
```
# ansible-playbook docker.yml --connection=local -i hosts -l localhost
```
## 【参考】上記プレイブックでは、以下の処理を行っている。
1. docker本体と、ansibleのdockerモジュールに必要なモジュールのインストール(pip,docker-ps)、proxy設定、自動起動有効、再起動
2. 独自ネットワークの作成  
