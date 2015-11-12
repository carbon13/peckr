# encoding: utf-8
require "#{$APP_ROOT_PATH}/app/collectors/yql_collector.rb"

class TweetsCollector < YQLCollector
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
    TweetStream::Client.new.sample do |status|
      # HACK: To use map.
      @file.puts "#{status.id}\t#{status.created_at}\t#{status.lang}\t#{status.user.id}\t#{status.user.screen_name}\t#{status.user.location}\t#{status.text.gsub(/(\n)/,' ')}"
    end
  end
end
