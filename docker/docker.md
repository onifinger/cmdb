# dockerのインストール  

## OSセットアップ  
CentOS Linux release 7.3.1611 をminimul インストール  

## proxy(squid)の設定
環境によってインターネット接続にProxyの有無が変わってくるが、
それによって各種アプリ（yum,git,python(pip),docker等々）の設定を適宜変更するのは手間になる。  
ホスト上にProxyをたてることで、各種アプリはホストのProxyを使用する固定の設定にし、
ホストのProxyで上位Proxyに転送する設定のみ変更すれば良いようにする。

### squidのインストール
minimulではsquidはインストールできないので、通常のminimulでないメディアからインストールする。  
インターネットに出れる場合は、yum install squidでよい。  
メディアをセットして、以下のコマンドを実行する。
```
# mkdir /media/CentOS/
# mount -r /dev/cdrom /media/CentOS/
# yum --disablerepo=\* --enablerepo=c7-media install squid -y
```

### squidの設定編集
```
# vi /etc/squid/squid.conf
```
以下の設定を追記する。環境に合わせて適宜、削除、修正。  
1. whitelistで許可されたドメイン以外を拒否
2. 上位認証ありProxy 192.168.56.2。認証無しならlogin以降は削除
3. ローカルIPは上位Proxyに転送しない。他はすべて上位Proxyに転送。
4. ログフォーマットをApacheとフォーマットに合わせる。合わせたくなければ削除
```
<省略>
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
# whitelist
acl whitelist dstdomain "/etc/squid/whitelist"
http_access deny !whitelist
<省略>
<行末>
cache_peer 192.168.56.2 parent 3128 0 no-query default login=user:password
always_direct allow localnet
never_direct allow all
prefer_direct off
nonhierarchical_direct off
icp_port 0

logformat squid %>a %ui %un [%tl] "%rm %ru HTTP/%rv" %Hs %<st %Ss:%Sh [%>h] [%<h]
emulate_httpd_log on
```
ホワイトリストの作成
```
vi /etc/squid/whitelist
```
適宜追記する。今回は以下の内容。
1. github.com : githubに作成したAnsibleのPlaybook  
2. python.org : Pythonのモジュール
3. docker.io : dockerのイメージ
4. cloudfront.net : dockerのイメージ
```
github.com
.python.org
.docker.io
.cloudfront.net
```
## yumの設定  
### Proxyを設定
```
# vi /etc/yum.confに設定
```
```
proxy=http://127.0.0.1:3128
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
# git config --global http.proxy http://127.0.0.1:3128
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
