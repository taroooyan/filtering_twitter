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
      Word.select("ng_word").uniq.each do |ngword|
        ng_words << ngword.ng_word
      end

      flag = false # フィルタリングが適応されたかどうか
      filtering_text = String.new
      words.each do |word|
        if ng_words.include?(word)
          filtering_text += "＊" * word.size
          flag = true
        else
          filtering_text += word
        end
      end
      return {text: filtering_text, flag: flag}
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

    # 戻り値は Hash
    # tweet は Array
    def user_tweet(username)
      # エラー時の試行回数 
      retries = 0
      begin
        # 鍵垢かどうか
        return {tweet: ["鍵が付いているアカウントです"]} if @client.user(username).protected

        @name = @client.user(username).name
        if @@max_id == 0
          all_info = @client.user_timeline(username, { count: 100})
        else
          all_info = @client.user_timeline(username, { count: 100, max_id: @@max_id})
        end
      rescue Twitter::Error::TooManyRequests => error
        raise if retries >= 5
        retries += 1
        sleep error.rate_limit.reset_in
        retry
      rescue
        return {tweet: ["存在していないアカウントか何らかのエラーが発生しました"]}
      end

      all_info.each do |user_info|
        # 重複するツイートを削除するため
        next if @@max_id == user_info.id
        @@max_id  = user_info.id
        time      = "#{user_info.created_at.strftime("%Y/%m/%d %X")}".strip
        flag      = false #flagはフィルタリングが適応されたかどうか
        tweet     = "#{user_info.text}".strip
        text = String.new
        reply_users = Array.new

        ## 半角スペースが省略される問題の解決
        ## テキストにユーザ名が含まれているのを分割(ィルタリング対象にしない)
        tweet = tweet.split
        tweet.each do |t|
          if t.match(/^@/)
            reply_users << "#{t} "
          else
            tmp        = Mecab.new.filtering(t) # {text: , flag: }
            text += tmp[:text]
            flag = true if tmp[:flag]
          end
        end
        @@text << {text: text, reply_users: reply_users, time: time, flag: flag}
      end
      return {name: @name, tweet: @@text}
    end
  end #/class TwitterInfo



  def home
    # DBからng wordを取得
    # ng_word:string, username:string
    @ng_words = Array.new
    Word.select("ng_word").uniq.each do |ngword|
      @ng_words << ngword.ng_word
    end
    @input = Word.new
  end

  def show
    @user  = Hash.new
    client = TwitterInfo.new()

    # DBからng wordを取得
    # ng_word:string, username:string
    @ng_words = Array.new
    Word.select("ng_word").uniq.each do |ngword|
      @ng_words << ngword.ng_word
    end

    # 配列をわたす
    @user = client.user_tweet(params[:username])
    @user[:username] = params[:username]
    @input = Word.new
  end

  def new
    @input = Word.new
    if params[:word][:ng_word] != ""
      @input[:ng_word] = params[:word][:ng_word]
      # すでに登録されているかどうか
      unless Word.exists?(ng_word: @input[:ng_word])
        if @input.save
          render :text => "#{@input[:ng_word]}を登録しました"
        else
          render :text => "エラーが発生しました"
        end

      else
        render :text => "#{@input[:ng_word]}はすでに登録されています"
      end

    else
      render :text => "空白は登録できません"
    end
  end

  def destroy
    @input = Word.destroy_all(ng_word: params[:ng_word])
    render :text => "#{params[:ng_word]}をフィルタリング対象から削除しました"
  end
end
