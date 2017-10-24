# コンテナの起動、WEBサーバの起動

## リポジトリサーバが取得したコンテンツを公開するために、apacheを起動
```
# cd /opt/cmdb/docker
# ansible-playbook 003001_run_httpd.yml -i hosts -l localhost -vvv
```

## CentOS の yumのリポジトリサーバのコンテナの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 003002_run_yumrepo.yml -i hosts -l localhost -vvv
```

## RHEL の yumのリポジトリサーバのコンテナの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 003006_run_yumrepo_rhel.yml -i hosts -l localhost -vvv
```

## OpenAuditのコンテナの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 003003_run_openaudit.yml -i hosts -l localhost,openaudit -vvv
```

## redashのコンテナの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 003004_run_redash.yml -i hosts -l localhost -vvv
```
## supersetのコンテナの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 003005_run_superset.yml -i hosts -l localhost -vvv
```

## dockerコマンドの使い方

コンテナの起動
```
# docker start コンテナ名
```

コンテナの停止
```
# docker stop コンテナ名
```

コンテナの再起動
```
# docker restart コンテナ名
```

起動中のコンテナの確認
```
# docker ps
```

停止中も含めてコンテナの確認
```
# docker ps -a
```

イメージの確認
```
# docker images
```

dockerの停止
```
# systemctl stop docker
```

dockerの起動
```
# systemctl start docker
```

dockerの再起動
```
# systemctl restart docker
```

