module MarketsHelper
  def owner?(market=@market)
    market and user_signed_in? and current_user == market.user rescue false
  end

  def propagation_class(propagation)
    if propagation.spence?
      "text-error"
    elsif propagation.earn?
      "text-success"
    else
      "text-info"
    end
  end
end
