# リポジトリサーバの運用

## コンテンツの更新(centos6)
```
# docker exec -it repocentos6 /bin/bash
# reposync -n -t /var/cache/yum -p /var/www/html/centos/6/x86_64/ --download-metadata
# ls -d /var/www/html/centos/6/x86_64/* | xargs -I{} createrepo "{}"
```
コンテナに入らずにホストから制御する場合
```
# docker exec -it centos6repo reposync -n -t /var/cache/yum -p /var/www/html/centos/6/x86_64/ --download-metadata
# ls -d /var/www/html/centos/6/x86_64/* | xargs -I{} docker exec -i centos6repo createrepo "{}"
```

## コンテンツの更新(centos7)
```
# docker exec -it repocentos7 /bin/bash
# reposync -n -t /var/cache/yum -p /var/www/html/centos/7/x86_64/ --download-metadata
# ls -d /var/www/html/centos/7/x86_64/* | xargs -I{} createrepo "{}"
```
コンテナに入らずにホストから制御する場合
```
# docker exec -it centos7repo reposync -n -t /var/cache/yum -p /var/www/html/centos/7/x86_64/ --download-metadata
# ls -d /var/www/html/centos/7/x86_64/* | xargs -I{} docker exec -i centos7repo createrepo "{}"
```
