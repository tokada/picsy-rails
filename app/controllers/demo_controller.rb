class DemoController < ApplicationController
  def index
		@people = Person.all
    @matrix = Evaluation.person_matrix_quantized
    @contributions = Person.contributions_quantized
    @trades = Trade.all.order("id desc")
  end

	def natural_recovery
		n = params[:natural_recovery].to_i
		n = nil if n == 0
		Evaluation.natural_recovery!(n / 100000.0)
		redirect_to root_path
	end
end
