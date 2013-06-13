# 認証用のモデル
class User < ActiveRecord::Base
  devise :rememberable, :trackable, :omniauthable
  attr_accessible :name, :provider, :uid, :image, :info, :password

  # TwitterのOAuth認証の実装。一度認証するとテーブルにTwitter IDを保存する。
  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first

      dd auth

		unless user
			user = User.create!(:name      => auth.info.nickname,
													:provider  => auth.provider,
													:uid       => auth.uid,
													:image     => auth.info.image,
													:password  => Devise.friendly_token[0,20]
													)
		end
    user
  end
end
