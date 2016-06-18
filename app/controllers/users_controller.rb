class UsersController < ApplicationController
  class Mecab
    def filtering(text)
      # 分解
      # オプションはここで渡す, 使う辞書の指定をする
      nm = Natto::MeCab.new("-d /usr/local/lib/mecab/dic/mecab-ipadic-neologd")
      words = Array.new
      nm.parse(text) do |n|
        words << n.surface
      end

      # DBからng wordを取得
      # ng_word:string, username:string
      ng_words = Array.new
      Word.select("ng_word").each do |ngword|
        ng_words << ngword.ng_word
      end

      filtering_text = String.new
      words.each do |word|
        if ng_words.include?(word)
          filtering_text += "*" * word.size
        else
          filtering_text += word
        end
      end
      return filtering_text
    end #/def filtering
  end #/calss Mecab


  class TwitterInfo
    def initialize
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key    = ENV["CONSUMER_KEY"]
        config.consumer_secret = ENV["CONSUMER_SECRET"]
        config.access_token    = ENV["ACCESS_TOKEN"]
        config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
      end
      # tweetの最後のid
      @@max_id = 0
      # tweet
      @@text = Array.new
    end #/def initialize

    # 自分のタイムラインを取得
    def home_timeline
      # エラー時の試行回数 
      retries = 0
      begin
        timelines = @client.home_timeline(count: 1)
        timelines.each do |tweet|
          return Mecab.new.analysis(tweet.text)
        end
      rescue Twitter::Error::TooManyRequests => error
        raise if retries >= 5
        retries += 1
        sleep error.rate_limit.reset_in
        retry
      end
    end #/def home_timeline

    def user_tweet(username)
      if @@max_id == 0
        all_info = @client.user_timeline(username, { count: 100})
      else
        all_info = @client.user_timeline(username, { count: 100, max_id: @@max_id})
      end

      all_info.each do |user_info|
        # 重複するツイートを削除するため
        next if @@max_id == user_info.id
        @@max_id = user_info.id
        string  = String.new
        time    = "#{user_info.created_at.strftime("%Y/%m/%d %X")}"
        tweet   = "#{user_info.text}".strip
        ## 半角スペースが省略される問題の解決
        ## テキストにユーザ名が含まれているのを分割(ィルタリング対象にしない)
        tweet   = tweet.split
        string += "#{time.strip} "
        tweet.each do |t_text|
          if t_text.match(/^@/)
            string += "#{t_text} "
          else
            string << Mecab.new.filtering(t_text)
          end
        end
        @@text << string ##/
      end
      return @@text
    end
  end #/class TwitterInfo



  def index
  end

  def show
    @user            = Hash.new
    @user[:username] = params[:username]
    client = TwitterInfo.new()
    # 配列をわたす
    @user[:tweet] = client.user_tweet(params[:username])
    # DBからng wordを取得
    # ng_word:string, username:string
    @ng_words = Array.new
    Word.select("ng_word").each do |ngword|
      @ng_words << ngword.ng_word
    end
    @input = Word.new
  end

  def new
    @input = Word.new
    if params[:word][:ng_word] != ""
      @input.ng_word = params[:word][:ng_word]
      @input.save
    end
  end
end
