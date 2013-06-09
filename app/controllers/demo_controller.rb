class DemoController < ApplicationController
  def index
		@people = Person.all
    @matrix = Evaluation.person_matrix_quantized
    @contributions = Person.contributions_quantized
    @trades = Trade.all.order("id desc")
  end

	# 自然回収
	def natural_recovery
		n = params[:natural_recovery].to_i
		n = nil if n == 0
		Evaluation.natural_recovery!(n / 100.0) # %なので100で割る
		redirect_to root_path
	end

	# 取引
	def trade
		@amount = params[:amount].to_i / 100000.0
		@person_from = Person.find(params["person-from"].to_i)
		@person_to = Person.find(params["person-to"].to_i)
		if @person_from.present? and @person_to.present? and @amount > 0.0
			@person_from.pay(@person_to, @amount)
		end
		redirect_to root_path
	end
end
