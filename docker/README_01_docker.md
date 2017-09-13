# dockerホストのインストール  

## OSセットアップ  
CentOS Linux release 7.3.1611 をminimul インストール  

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
```
# cd /opt
# git clone http://github.com/taka379sy/cmdb.git
```

## OSと基本となるソフトの設定
```
# cd /opt/cmdb/docker
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
