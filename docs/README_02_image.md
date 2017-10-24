# dockerのイメージファイルの作成

## docker hub から CentOS6と7の公式イメージをダウンロードし、環境に合わせて設定変更した最新イメージを作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002001_os_image.yml -i hosts -l localhost,centos -vvv
```

## registry.access.redhat.com から RHEL6と7の公式イメージをダウンロードし、環境に合わせて設定変更した最新イメージを作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002006_os_image_rhel.yml -i hosts -l localhost,rhel -vvv
```

## centos の yumのリポジトリサーバの最新イメージファイルの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002002_yumrepo_image.yml -i hosts -l localhost,centos -vvv
```

## RHEL の yumのリポジトリサーバの最新イメージファイルの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002007_yumrepo_image_rhel.yml -i hosts -l localhost,rhel -vvv
```

## OpenAuditの最新イメージファイルの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002003_openaudit_image.yml -i hosts -l localhost,centos6 -vvv
```

## redashの最新イメージファイルの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002004_redash_image.yml -i hosts -l localhost,centos7 -vvv
```
## supersetの最新イメージファイルの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002005_superset_image.yml -i hosts -l localhost,centos7 -vvv
```
