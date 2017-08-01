# dockerのインストール  

## OSセットアップ  
CentOS Linux release 7.3.1611 をminimul インストール  

## proxy(squid)のインストール
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
1. .riken.jp : CentOSのリポジトリ
2. github.com : githubに作成したAnsibleのPlaybook  
3. python.org : Pythonのモジュール
4. docker.io : dockerのイメージ
5. cloudfront.net : dockerのイメージ
```
.riken.jp
github.com
.python.org
.docker.io
.cloudfront.net
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
# vi host_vars/localhost
```
```
# ホストのIPアドレス
host_ip: 172.23.141.63

# ホストのインターフェイスカードの名前
nic_interface: ens32

# dockerで使用するIPアドレス帯域（デフォルトと、使いする独自ネットワーク）
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

# 内部で使用するドメイン名
local_zone: ypro.jp

# ローカルＤＮＳサーバ（unbound）で使用する、server設定
local_server:
  - '    interface: 0.0.0.0'
  - '    access-control: 10.0.0.0/8 allow'
  - '    access-control: 172.16.0.0/12 allow'
  - '    access-control: 192.168.0.0/16 allow'
  - '    access-control: 127.0.0.0/8 allow'
  - '    do-ip6: no'
  - '    local-zone: "{{ local_zone }}." static'
  - '    local-data: "IN NS ns.{{ local_zone }}."'
  - '    local-data: "IN MX 10 mail.{{ local_zone }}."'
  - '    local-data: "cmdb.{{ local_zone }}. IN A {{ host_ip }}"'
  - '    local-data-ptr: "{{ host_ip }} cmdb.{{ local_zone }}."'
  - '    val-permissive-mode: yes'

# ローカルＤＮＳサーバ（unbound）で使用する、外部ＤＮＳサーバの設定
forward_zone:
  - 'forward-zone:'
  - '     name: "."'
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
  - { base_os_name: 'centos', base_os_tag: '7.3.1611', image_name: 'centos7', image_tag: '7.3.1611', ip: '192.168.10.2'}
  - { base_os_name: 'centos', base_os_tag: '6.9', image_name: 'centos6', image_tag: '6.9', ip: '192.168.10.3' }
```
### ansbibleで設定を行う。
```
# ansible-playbook os.yml --connection=local -i hosts -l localhost
```
### 【参考】上記プレイブックでは、以下の処理を行っている。
1. ansible用のユーザ追加(group作成、sudo、SSH公開鍵、環境変数の設定も行う。)
2. Pythonモジュール用の環境設定。
3. SELINUX　停止、無効  
4. firewalld　停止、自動起動無効  
5. iptables　インストール、自動起動有効、起動  
6. ansibleの設定変更（bash、SSH接続、ログの設定、プレイブックの所有者の変更）
7. 必須ではないが何かと使うツールのインストール  

## dockerのインストール
前の項目でログイン時の環境変数を変更しているので、ログインをし直す。
```
# cd /opt/cmdb/docker
# ansible-playbook docker.yml --connection=local -i hosts -l localhost
```
## 【参考】上記プレイブックでは、以下の処理を行っている。
1. docker本体と、ansibleのdockerモジュールに必要なモジュールのインストール(pip,docker-ps)、proxy設定、自動起動有効、再起動
2. 独自ネットワークの作成  
