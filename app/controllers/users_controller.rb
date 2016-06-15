class UsersController < ApplicationController
  class Mecab
    def filtering(text)
      # オプションはここで渡す, 使う辞書の指定をする
      nm = Natto::MeCab.new("-d /usr/local/lib/mecab/dic/mecab-ipadic-neologd")
      # 分解
      words   = Array.new
      filtering_text = String.new
      nm.parse(text) do |n|
        words << n.surface
      end
      # TODO 原文からスペースが消える問題があるのでどうしよう
      ng_words = ["ごみ", "つかれた", "スタンプ", "すごい", "天才", "芹澤優"]
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
    end #/def initialize

    # 自分のタイムラインを取得
    def home_timeline
      # エラー時の試行回数 
      retries = 0
      begin
        timelines = @client.home_timeline(count: 1)
        timelines.each do |tweet|
          text = "#{tweet.created_at.strftime("%Y/%m/%d %X")}: #{tweet.text}"
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
      text = Array.new
      all_info = @client.user_timeline(username, { count: 100})
      all_info.each do |user_info|
        tweet = "#{user_info.created_at.strftime("%Y/%m/%d %X")}: #{user_info.text}".strip
        text << Mecab.new.filtering(tweet)
      end
      return text
    end
  end #/class TwitterInfo



  def index
  end

  def show
    @user            = Hash.new
    @user[:username] = "@#{params[:username]}"
    client = TwitterInfo.new()
    # 配列をわたす
    @user[:tweet] = client.user_tweet(params[:username])
  end
end
