# dockerホストのインストール  

## OSセットアップ  
CentOS Linux release 7.3.1611 をminimul インストール  

## proxy(squid)のインストール
ホスト、コンテナから外部（インターネット）への接続は、
ホスト上のProxyサーバを経由させることで、外部への接続（認証情報、アクセス先）を制御する。  
そのために、squidをインストールする。

### squidのインストール
インターネットに出れる場合
```
# yum install squid
```
インターネットに出れない場合、minimulのインストールメディアではsquidは含まれないので、
通常のインストールメディアからインストールする。  
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
以下の設定を追記する。※環境に合わせて適宜、削除、修正を行う。  
1. whitelistで許可されたドメイン以外を拒否
2. 上位認証ありProxy 192.168.56.2。認証無しならlogin以降は削除
3. ログフォーマットをApacheとフォーマットに合わせる。合わせたくなければ削除
```
<省略>
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
# whitelist
acl whitelist dstdomain "/etc/squid/whitelist"
http_access deny !whitelist
<省略>
<行末>
cache_peer 192.168.56.2 parent 3128 0 no-query default login=user:password
#always_direct allow localnet
never_direct allow all
prefer_direct off
nonhierarchical_direct off
icp_port 0

logformat squid %>a %ui %un [%tl] "%rm %ru HTTP/%rv" %Hs %<st %Ss:%Sh [%>h] [%<h]
```
ホワイトリストの作成
```
vi /etc/squid/whitelist
```
適宜追記する。今回は以下の内容。
1. riken.jp : CentOSのリポジトリ
2. github.com : githubにあるファイルのダウンロード用
3. python.org : Pythonのモジュール
4. docker.io : dockerのイメージ
5. cloudfront.net : dockerのイメージ
6. pypa.io : Pythonのモジュール
7. npmjs.org : npmでダウンロードするファイル
8. opmantek.com : OpenAuditのファイル
9. amazonaws.com : ダウンロードファイルのみamazonaws.comに設置されることがあるため
10. nodejs.org : nodejs関連のダウンロード
```
.riken.jp
.github.com
.githubusercontent.com
.python.org
.docker.io
.cloudfront.net
.pypa.io
.npmjs.org
.opmantek.com
.amazonaws.com
nodejs.org
```

### Squidの起動
```
# systemctl start squid
# systemctl enable squid
```

## yumの設定  
### Proxyを設定
```
# vi /etc/yum.conf
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

## OSと基本となるソフトの設定
```
# cd /opt/cmdb/docker
# vi vars/config.yml
```
```
# 内部で使用するドメイン名
local_zone: ypro.local

# ホスト名
host_name: "cmdb.{{ local_zone }}"

# ホストのIPアドレス
host_ip: 172.23.141.63
#host_ip: 192.168.56.4

# ホストのインターフェイスカードの名前
nic_interface: ens32
#nic_interface: enp0s3

# localのProxy
local_proxy: "{{ host_ip }}:3128"

# dockerで使用するIPアドレス帯域（デフォルトと、追加で作成する独自ネットワーク）
default_bridge: 172.17.0.0/16
original_bridge: 192.168.10.0/24

local_net:
  - "{{ default_bridge }}"
  - "{{ original_bridge }}"

# 独自ネットワークの設定 ネットワーク名、サブネット、ゲートウェイ（ホストアドレス）、DHCP帯域
# 2～63をイメージセットアップ用 192.168.10.64/26 -> 64～127を動的IPコンテナ用 128～254を固定IPコンテナ用
network_name: bridge2
subnet: "{{ original_bridge }}"
gateway: 192.168.10.1
iprange: 192.168.10.64/26

# ローカルＤＮＳサーバ（unbound）で使用する、server設定
local_server:
  - '    interface: "{{ host_ip }}"'
  - '    access-control: 10.0.0.0/8 allow'
  - '    access-control: 172.16.0.0/12 allow'
  - '    access-control: 192.168.0.0/16 allow'
  - '    access-control: 127.0.0.0/8 allow'
  - '    do-ip6: no'
  - '    local-zone: "{{ local_zone }}." static'
  - '    local-data: "IN NS cmdb.{{ local_zone }}."'
  - '    local-data: "IN MX 10 cmdb.{{ local_zone }}."'
  - '    local-data: "cmdb.{{ local_zone }}. IN A {{ host_ip }}"'
  - '    local-data-ptr: "{{ host_ip }} cmdb.{{ local_zone }}."'
  - '    val-permissive-mode: yes'

# ローカルＤＮＳサーバ（unbound）で使用する、外部ＤＮＳサーバの設定。
# 外部DNSサーバが無い場合は"forward_zone:"の定義ごとコメントアウト
forward_zone:
  - 'forward-zone:'
  - '     name: "."'
#  - '     forward-addr: 192.168.56.2'
  - '     forward-addr: 172.23.1.18'
  - '     forward-addr: 172.23.1.17'

# Pythonモジュールをインストールするディレクトリ
pydir: /opt/ansible_python
pypath: "{{ pydir }}/lib/python2.7/site-packages"

# ansibleユーザ
users:
  - { name: 'ansibleuser', password: "{{ 'password'|password_hash('sha512')}}" , uid: '601' }

# 運用で役に立つパッケージの追加（ansible,gitは最初に手動でインストールするので除く）
pkgs:
  - bridge-utils
  - net-tools
  - telnet
  - wget
  - tcpdump
  - sysstat
  - bind-utils

# dockerで外部から取得するベースになるＯＳイメージの情報と、内部でカスタマイズ後のイメージの情報。
images:
  - { base_os_name: 'centos', base_os_tag: '7.3.1611', image_name: 'centos7', image_tag: '7.3.1611_v001', ip: '192.168.10.2'}
  - { base_os_name: 'centos', base_os_tag: '6.9', image_name: 'centos6', image_tag: '6.9_v001', ip: '192.168.10.3' }

# yumリポジトリサーバのイメージ作成に使用する、ベースのＯＳイメージの情報と、作成後のイメージの情報。
yum_repo:
  - { base_os_name: 'centos7', base_os_tag: '7.3.1611_v001', image_name: 'repocentos7', image_tag: 'v001', ip: '192.168.10.128', dir: '/var/www/html/centos/7/x86_64/' }
  - { base_os_name: 'centos6', base_os_tag: '6.9_v001', image_name: 'repocentos6', image_tag: 'v001', ip: '192.168.10.129', dir: '/var/www/html/centos/6/x86_64/' }

# openauditの設定
openaudit_install_file: OAE-Linux-x86_64-release_1.12.10.1.run
#openaudit_install_file: OAE-Linux-x86_64-release_2.0.2.run
openaudit_mysql_pass: 12345678
openaudit_port: 8000
openaudit:
  - { base_os_name: 'centos6', base_os_tag: '6.9_v001', image_name: 'openaudit', image_tag: '1.12.10.1_v001', ip: '192.168.10.130' }
#  - { base_os_name: 'centos7', base_os_tag: '7.3.1611_v001', image_name: 'openaudit', image_tag: '2.0.2_v001', ip: '192.168.10.130' }

# redashの設定
redash_port: 8001
redash:
  - { base_os_name: 'centos7', base_os_tag: '7.3.1611_v001', image_name: 'redash', image_tag: '3.0.0_v001', ip: '192.168.10.131' }

# supersetの設定
superset_port: 8088
superset_user: { username: 'admin', userfirstname: 'admin', userlastname: 'admin', email: 'root@localhost.localdomain', password: 'password' }
superset:
  - { base_os_name: 'centos7', base_os_tag: '7.3.1611_v001', image_name: 'superset', image_tag: '0.18.3_v001', ip: '192.168.10.132'
}
```

### ansbibleで設定を行う。
```
# ansible-playbook 001001_os.yml -i hosts -l localhost -vvv

```
### 【参考】上記プレイブックでは、以下のような処理を行っている。
1. 必須ではないが何かと使うツールのインストール  
2. Pythonモジュール用の環境設定。
3. SELINUX　停止、無効  
4. firewalld　停止、自動起動無効  
5. iptables　インストール、自動起動有効、起動  
6. ansibleの設定変更（sudo、SSH接続、ログの設定）
7. DNS(unbound)の設定

## dockerのインストール
前の項目でログイン時の環境変数を変更しているので、ログインをし直す。
```
# cd /opt/cmdb/docker
# ansible-playbook 001002_docker.yml -i hosts -l localhost -vvv
```
## 【参考】上記プレイブックでは、以下の処理を行っている。
1. docker本体と、ansibleのdockerモジュールに必要なモジュールのインストール(pip,docker-ps)、proxy設定、自動起動有効、再起動
2. 独自ネットワークの作成  


## asible用のユーザの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 001003_user.yml -i hosts -l localhost -vvv
```
## 【参考】上記プレイブックでは、以下の処理を行っている。
1. ansible用のユーザ追加(group作成、sudo、SSH公開鍵、環境変数の設定も行う。)
