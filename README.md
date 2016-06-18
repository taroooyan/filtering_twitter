#README
### **これは**
twitterを閲覧する際にフィルタリング機能をつけたサービス  
ツイートの文字列の構文解析器としてMeCab、辞書としてmecab-ipadic-NEologdを使用  
ユーザをしてしてツイートを見ます

### **開発環境**
- Debian 8.4
- Ruby 2.1.5p273
- MeCab 0.996
- mecab-ipadic-NEologdをインストールするためメモリは1.5以上必要


### **インストール**
- [MeCab](http://taku910.github.io/mecab/)
- [mecab-ipadic-NEologd](https://github.com/neologd/mecab-ipadic-neologd)  
  辞書のパスの確認  
  `echo `mecab-config --dicdir`"/mecab-ipadic-neologd"`  
  辞書のパスは必ず下になるようにしてください  
  `/usr/local/lib/mecab/dic/mecab-ipadic-neologd`  
- `bundle install`

### 設定
#### 環境変数の設定
`cp template.env .env`
twitter APIのトークンを書くためあらかじめトークンを取得しておく必要があります。
また、トークンを発行したtwitterの鍵垢にアクセスできてしまうので注意
辞書ファイルのパスを入れる際に"-d"をつけ忘れないようにしてください
```.env
CONSUMER_KEY="xxx"
CONSUMER_SECRET="xxx"
ACCESS_TOKEN="xxx"
ACCESS_TOKEN_SECRET="xxx"
DICTIONARY_PATH="-d xxx"
```
#### DBの設定
`rake db:migrate`


### **課題**
- タイムラインを表示できるように
- ユーザごとにフィルタリングワードを決めれるように


