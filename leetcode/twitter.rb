# TODO: 拿掉User类, 直接在Twitter里面构建数据结构
class Twitter
  attr_accessor :users

  def initialize
    @users = {} # { id: User }
  end

  def post_tweet(user_id, tweet_id)
    if users.key?(user_id)
      users[user_id].post_feed(tweet_id)
    else
      user = User.new(user_id)
      users[user_id] = user
      user.post_feed(tweet_id)
    end
  end

  def get_news_feed(user_id)
    feeds = []
    (users[user_id].followers + [user_id]).each do |uid|
      feeds += users[uid].feeds
    end
    feeds.sort { |x, y| y[1] <=> x[1] }[0..9]
  end

  def follow(follower_id, followee_id)
    users[follower_id].follow(followee_id)
  end

  def unfollow(follower_id, followee_id)
    users[follower_id].unfollow(followee_id)
  end

  class User
    attr_accessor :followers, :feeds

    def initialize(id)
      @id = id
      @feeds = [] # [[1,12], [1,21]]
      @followers = [] # [1,2]
    end

    def lasted_feeds
    end

    def post_feed(feed_id)
      feeds << [feed_id, Time.now.to_f]
    end

    def follow(followee_id)
      followers.push(followee_id)
    end

    def unfollow(followee_id)
      followers.delete(followee_id)
    end
  end

  # class Feed < Struct(:id, :posted_at); end
end

twitter = Twitter.new
twitter.post_tweet(1, 1)
twitter.post_tweet(2, 2)
twitter.post_tweet(1, 5)
twitter.post_tweet(1, 3)
p twitter.get_news_feed(1)
twitter.follow(1, 2)
p twitter.get_news_feed(1)
twitter.unfollow(1, 2)
p twitter.get_news_feed(1)
