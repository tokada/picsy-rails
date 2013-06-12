module MarketsHelper
  def owner?(market=@market)
    market and user_signed_in? and current_user == market.user rescue false
  end
end
