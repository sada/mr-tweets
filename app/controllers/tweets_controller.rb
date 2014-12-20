class TweetsController < ApplicationController
  include ActionController::Live

  def index
  end

  def stream
    topics = Settings.twitter.topics
    response.headers['Content-Type'] = 'text/event-stream; charset=utf-8'
    sse = SSE.new(response.stream, retry: 300, event: "tweet")

    begin
      twitter_api_client.filter(:track => topics.join(",")) do |tweet|
        next if tweet.retweet?
        sse.write(tweet.attrs)
      end
    rescue IOError

    ensure
      sse.close
    end
  end

  private

  def twitter_api_client
    Twitter::Streaming::Client.new do |config|
      config.consumer_key = Settings.twitter.consumer_key
      config.consumer_secret = Settings.twitter.consumer_secret
      config.access_token = Settings.twitter.access_token
      config.access_token_secret = Settings.twitter.access_token_secret
    end
  end
end
