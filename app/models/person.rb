# 個人／Person
#
# 伝播投資貨幣を使用している個人。
#
class Person < ActiveRecord::Base
  default_scope { order :id }

	belongs_to :market

	belongs_to :user

  # 個人は他の経済主体に評価を与える
  has_many :given_evaluations, :as => :buyable, :class_name => 'Evaluation', :dependent => :destroy

  # 個人は他の経済主体から評価を与えられる
  has_many :earned_evaluations, :as => :sellable, :class_name => 'Evaluation', :dependent => :destroy

  # 個人は取引時に他の経済主体から商品を買い、その売主に評価を与える
  has_many :given_trades, :as => :buyable, :class_name => 'Trade', :dependent => :destroy

  # 個人は取引時に他の経済主体に商品を売り、その買主から評価をもらう
  has_many :earned_trades, :as => :sellable, :class_name => 'Trade', :dependent => :destroy

  # 個人は商品を所有する
  has_many :items, :as => :ownable

  # 個人は貢献度の伝播履歴をもつ
  has_many :propagations, :as => :evaluatable, :dependent => :destroy

  # 個人は名前をもつ
  attr_accessible :name

  # 個人は貢献度の値をもつ
  attr_accessible :contribution

  validates :name, :presence => true

  # 状態遷移
  state_machine :state, :initial => :alive do
    state :alive
    state :dead
    state :purged

    event :kill do
      transition :alive => :dead
    end

    event :resurrect do
      transition :dead => :alive
    end

    event :purge do
      transition :dead => :purged
    end
  end

  # 評価を与える取引を行う（支払う）
  def pay(seller, amount)
    market.trade(self, seller, amount)
  end

  # 評価を得る取引を行う（稼ぐ）
  def earn(buyer, amount)
    market.trade(buyer, self, amount)
  end

  # 他の経済主体に評価を与える
  def evaluate!(seller, amount)
    ev = given_evaluations.where(:buyable => self, :sellable => seller).first_or_initialize
    ev.amount = amount
    ev.save
  end

  # 他の経済主体への評価値を取得する
  def evaluation_to(seller)
    Evaluation.where(:buyable => self, :sellable => seller).first.amount
  end

  # 他の経済主体からの評価値を取得する
  def evaluation_from(buyer)
    Evaluation.where(:buyable => buyer, :sellable => self).first.amount
  end

  # 自己評価値を取得する
  def self_evaluation
    evaluation_to(self)
  end

  # ゲーム用に自己評価値を整数化したもの
  def self_evaluation_quantized(n=100000)
		q = self_evaluation * n
    n <= 1 ? sprintf("%0.04f", q) : sprintf("%d", q)
  end

	# PICSY効果
	def picsy_effect_quantized(n=100000)
		q = picsy_effect.to_f * n
    q = (n <= 1 ? sprintf("%0.04f", q) : sprintf("%d", q))
    if q.to_i == 0
      ""
    elsif q.to_i > 0
      "+#{q}"
    else
      q
    end
	end

	# PICSY効果を更新する
	def update_picsy_effect!
		effect = propagations.effect.pluck(:amount).sum
		update_attribute(:picsy_effect, effect)
	end

  # @ではじまる場合にTwitter IDを取得する
  def update_twitter_name(current_user)
    if name =~ /^\@([0-9a-z_]{1,15})/
      tw_name = $1
      self.user = User.find_for_twitter_user(tw_name, current_user)
      save
    end
  end

end
