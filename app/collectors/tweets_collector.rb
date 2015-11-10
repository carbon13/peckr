# encoding: utf-8
require "#{$APP_ROOT_PATH}/app/collectors/yql_collector.rb"

class TweetsCollector < YQLCollector
  def initialize
    twitter_api_config = YAML.load_file("#{$APP_ROOT_PATH}config/twitter_api.yml")
    TweetStream.configure do |config|
      config.consumer_key       = ENV['TW_CONSUMER_KEY']
      config.consumer_secret    = ENV['TW_CONSUMER_SECRET']
      config.oauth_token        = ENV['TW_ACCESS_TOKEN']
      config.oauth_token_secret = ENV['TW_ACCESS_TOKEN_SECRET']
      config.auth_method        = :oauth
    end
    @file = File.open("#{$APP_ROOT_PATH}db/tweet_stream_#{Date.today.strftime('%Y%m%d%H%M%S')}.tsv", 'a')
  end

  def sample_tweets
    TweetStream::Client.new.sample do |status|
      # HACK: To use map.
      @file.puts "#{status.id}\t#{status.created_at}\t#{status.lang}\t#{status.user.id}\t#{status.user.screen_name}\t#{status.user.location}\t#{status.text.gsub(/(\n)/,' ')}"
    end
  end
end
