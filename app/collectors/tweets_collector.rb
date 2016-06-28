# encoding: utf-8
Encoding.default_external = 'utf-8'

class TweetsCollector
  def initialize
    twitter_api_config = YAML.load(ERB.new(File.read("#{$APP_ROOT_PATH}/config/twitter_api.yml")).result)
    TweetStream.configure do |config|
      config.consumer_key       = twitter_api_config[$ENV]['consumer_key']
      config.consumer_secret    = twitter_api_config[$ENV]['consumer_secret']
      config.oauth_token        = twitter_api_config[$ENV]['access_token']
      config.oauth_token_secret = twitter_api_config[$ENV]['access_token_secret']
      config.auth_method        = :oauth
    end
    @file = File.open("#{$APP_ROOT_PATH}/db/tweet_stream_#{Time.now.strftime('%Y%m%d%H%M%S')}.tsv", 'a')
  end

  def sample_tweets
    tweets          = []
    tweet_morphemes = []
    batch_size      = 100
    header = %w{status_id user_id tweeted_at text}
    @file.puts header.join("\t")
    TweetStream::Client.new.sample do |status|
      # HACK: To use map.
      # extended sample
      # @file.puts "#{status.id}\t#{status.user.id}\t#{status.created_at}\t#{status.text.gsub(/\n|\t|\r/, ' ').gsub(/"/, '')}"
      tweet = Tweet.new
      tweet.status_id  = status.id
      tweet.user_id    = status.user.id
      tweet.tweeted_at = status.created_at
      tweets << tweet
      tweet_morphemes << tweet_morphemes(status)
      if tweets.length >= batch_size
        Tweet.import tweets
        tweets = []
        TweetMorpheme.import tweet_morphemes
        tweet_morphemes = []
      end
    end
  end

  def tweet_morphemes(tweet)
    nm = Natto::MeCab.new
    tweet_morphemes = []
    word_count = {}

    nm.parse(tweet.text) do |n|
      word_count[n.surface] ? word_count[n.surface] += 1 : word_count[n.surface] = 1 if (noun?(n) || verb?(n))
    end

    word_count.each do |k, v|
      tweet_morpheme = TweetMorpheme.new
      tweet_morpheme.surface  = k
      tweet_morpheme.count    = v
      tweet_morpheme.status_id = tweet.id

      tweet_morphemes << tweet_morpheme
    end
    tweet_morphemes
  end

  def noun?(n)
    n.feature.include?('名詞')
  end

  def verb?(n)
    n.feature.include?('動詞')
  end
end
