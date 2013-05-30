class User < ActiveRecord::Base
  devise :rememberable, :trackable, :omniauthable
  attr_accessible :name, :provider, :uid, :password

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first

    unless user
      user = User.create!(:name     => auth.info.nickname,
                          :provider => auth.provider,
                          :uid      => auth.uid,
                          :password => Devise.friendly_token[0,20]
                          )
    end
    user
  end
end
