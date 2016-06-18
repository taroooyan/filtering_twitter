#**README**
### **これは**
twitterを閲覧する際にフィルタリング機能をつけたサービス
ツイートの文字列の構文解析器としてMeCab、辞書としてmecab-ipadic-neologdを使用
ユーザをしてしてツイートを見ることができる

### **開発環境**
Debian 8.4
Ruby 2.1.5p273

### **設定**
`cp template.env .env`
twitter APIのトークンを書くためあらかじめトークンを取得しておく必要があります。
また、トークンを発行したtwitterの鍵垢にアクセスできてしまうので注意
```.env
CONSUMER_KEY=""
CONSUMER_SECRET=""
ACCESS_TOKEN=""
ACCESS_TOKEN_SECRET=""
```
`bundle install`

### **課題**
タイムラインを表示できるようにする。
ユーザごとにフィルタリングワードを決めれるようにする


