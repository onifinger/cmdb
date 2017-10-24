# dockerホストのインストール  

## OSセットアップ  
Red Hat Enterprise Linux Server release 7.4 (Maipo)を最小構成でインストール  
※今回は仮想マシンで作成

### RHNへの登録 
```
# subscription-manager register
ユーザー名: XXXXX
パスワード:
# subscription-manager list
<省略>
状態:             サブスクライブしていません
<省略>
# subscription-manager list --available
<省略>
プール ID: XXXXXXXXXXXXXXXXXXXXXXX
<省略>
システムタイプ: 仮想
<省略>
# subscription-manager attach --pool=XXXXXXXXXXXXXXXXXXXXXXX
# subscription-manager list
<省略>
状態:             サブスクライブ済み
<省略>
```
### リポジトリの追加  
```
# subscription-manager repos --list-enabled
# subscription-manager repos --enable rhel-7-server-extras-rpms
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
```
# cd /opt
# git clone http://github.com/taka379sy/cmdb.git
```

## OSと基本となるソフトの設定
```
# cd /opt/cmdb/docker
# cp vars/config.yml_sample vars/config.yml
# vi vars/config.yml
```
必要応じて適宜変更
```
# ホストのIPアドレス
host_ip: 172.23.141.63
```

### ansbibleで設定を行う。
```
# ansible-playbook 001001_os.yml -i hosts -vvv
```

## dockerのインストール
前の項目でログイン時の環境変数を変更しているので、ログインをし直す。
```
# ansible-playbook 001002_docker.yml -i hosts -vvv
```
