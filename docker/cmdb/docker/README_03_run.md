# コンテナの起動、WEBサーバの起動

## リポジトリサーバが取得したコンテンツを公開するために、apacheを起動
```
# cd /opt/cmdb/docker
# ansible-playbook 003001_run_httpd.yml -i hosts -l localhost -vvv
```

## yumのリポジトリサーバのコンテナの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 003002_run_yumrepo.yml -i hosts -l localhost -vvv
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
