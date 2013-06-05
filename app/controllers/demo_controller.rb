class DemoController < ApplicationController
  def index
    @matrix = Evaluation.person_matrix.to_a.map{|r|
      r.map{|c| sprintf("%10.4f", c) }
    }
    @contributions = Person.contributions
  end
end
