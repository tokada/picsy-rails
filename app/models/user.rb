# 認証用のモデル
class User < ActiveRecord::Base
  devise :rememberable, :trackable, :omniauthable
  attr_accessible :name, :provider, :uid, :image, :info, :password,
    :oauth_token, :oauth_token_secret

  # TwitterのOAuth認証の実装。一度認証するとテーブルにTwitter IDを保存する。
  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first

		if user
      user.oauth_token = auth.credentials.token if user.oauth_token != auth.credentials.token
      user.oauth_token_secret = auth.credentials.secret if user.oauth_token_secret != auth.credentials.secret
      user.name = auth.info.nickname if user.name != auth.info.nickname
      user.image = auth.info.image if user.image != auth.info.image
      user.save if user.changed?
    else
			user = User.create!(:name      => auth.info.nickname,
													:provider  => auth.provider,
													:uid       => auth.uid,
													:image     => auth.info.image,
													:oauth_token => auth.credentials.token,
													:oauth_token_secret => auth.credentials.secret,
													:password  => Devise.friendly_token[0,20]
													)
		end
    user
  end

  # Twitter::Userの情報をテーブルに保存する。
  def self.find_for_twitter_user(screen_name, current_user)
    tw = current_user.get_twitter_user(screen_name)
    user = User.where(:provider => 'twitter', :uid => tw.id).first

		unless user
			user = User.create!(:name      => tw.screen_name,
													:provider  => 'twitter',
													:uid       => tw.id,
													:image     => tw.profile_image_url,
													:password  => Devise.friendly_token[0,20]
													)
		end
    user
  end

  def initiate_twitter_client
    @twitter ||= Twitter::Client.new(
      :oauth_token => oauth_token,
      :oauth_token_secret => oauth_token_secret,
    )
  end

  # GET https://api.twitter.com/1.1/users/show.json?screen_name=[screen_name]
  def get_twitter_user(screen_name)
    initiate_twitter_client
    @twitter.user(screen_name)
  end
end
