# dockerのイメージファイルの作成

## docker hub から CentOS6と7の公式イメージをダウンロードし、環境に合わせて設定変更した最新イメージを作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002001_os_image.yml -i hosts -l localhost,centos -vvv
```
### 【参考】上記プレイブックでは、以下の処理を行っている。
1. docker hub から公式イメージをダウンロード、コンテナを作成
2. リポジトリ（SCL,EPEL）の追加と、全リポジトリを日本（riken）を見るようにする。
3. yumで最新の状態にアップデート
4. コンテナから最新イメージを作成

## yumのリポジトリサーバの最新イメージファイルの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002002_yumrepo_image.yml -i hosts -l localhost,centos -vvv
```
### 【参考】上記プレイブックでは、以下の処理を行っている。
1. OSの最新イメージからコンテナを作成
2. yumにProxyサーバの設定
3. yumで必要なパッケージのインストール
4. コンテナからイメージの作成

## OpenAuditの最新イメージファイルの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002003_openaudit_image.yml -i hosts -l localhost,centos6 -vvv
```
### 【参考】上記プレイブックでは、以下の処理を行っている。
1. OSの最新イメージからコンテナを作成
2. yumで必要なパッケージのインストール
3. このあとansibleでexpectモジュールを使用するため、pythonのモジュール(pexpect)をpipでインストール
4. openaduitの起動用のスクリプトをローカルからコピー
5. MySQLの初期化・起動
6. MySQLの外部からの接続用のアカウント作成
7. PHPの設定変更(OpenAudit推奨値）
8. OpenAudITのダウンロード、インストール
9. 初期データの退避
10. コンテナからイメージの作成

## redashの最新イメージファイルの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002004_redash_image.yml -i hosts -l localhost,centos7 -vv
```
### 【参考】上記プレイブックでは、以下の処理を行っている。
1. OSの最新イメージからコンテナを作成
2. 起動用のスクリプトをローカルからコピー
3. yumで必要なパッケージのインストール
4. redisの起動
5. PostgreSQLの初期設定、起動
6. Apacheにredash用の設定追加、起動
7. 必要なファイルのダウンロード
8. 必要なpythonモジュールのインストール
9. git,npmのProxy設定
10. npmのインストール
11. PostgreSQLにredashの初期設定
12. 初期データの退避
13. コンテナからイメージの作成

## supersetの最新イメージファイルの作成
```
# cd /opt/cmdb/docker
# ansible-playbook 002005_superset_image.yml -i hosts -l localhost,centos7 -vvv
```
### 【参考】上記プレイブックでは、以下の処理を行っている。
1. OSの最新イメージからコンテナを作成
2. 起動用のスクリプトをローカルからコピー
3. yumで必要なパッケージのインストール
4. Pythonのデフォルトエンコーディングをutf8に変更
5. 初期データの退避
6. コンテナからイメージの作成
