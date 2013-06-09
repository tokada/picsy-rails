class DemoController < ApplicationController
  def index
		@people = Person.all
    @matrix = Evaluation.person_matrix_quantized
    @contributions = Person.contributions_quantized
    @trades = Trade.all.order("id desc")
  end

	def run_natural_recovery
		n = params[:natural_recovery].to_f
		n = nil if n == 0.0
		Evaluation.natural_recovery! n
	end
end
