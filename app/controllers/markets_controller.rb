class MarketsController < ApplicationController
	before_filter :authenticate_user!, :except => [:index, :show];
  before_action :set_market, only: [:show, :edit, :update, :destroy, :trade, :natural_recovery]

  # GET /markets
  # GET /markets.json
  def index
    @markets = Market.all
  end

  # GET /markets/1
  # GET /markets/1.json
  def show
		@people = @market.people
    @matrix = @market.matrix_quantized
    @contributions = @market.people.contributions_quantized
    @trades = @market.trades.order("id desc")
  end

  # GET /markets/new
  def new
    @market = Market.new
		# デフォルト名称をセットする
		@market.set_default_name(current_user)
		@market.user = current_user
		@market.people_count = 3
		@market.evaluation_parameter = 100000
		@market.initial_self_evaluation = 10000
		@market.natural_recovery_rate = 1
  end

  # GET /markets/1/edit
  def edit
  end

  # POST /markets
  # POST /markets.json
  def create
    @market = Market.new(market_params)
		@market.user = current_user
		
    respond_to do |format|
      if @market.save
        format.html { redirect_to @market, notice: 'Market was successfully created.' }
        format.json { render action: 'show', status: :created, location: @market }
      else
        format.html { render action: 'new' }
        format.json { render json: @market.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /markets/1
  # PATCH/PUT /markets/1.json
  def update
    respond_to do |format|
      if @market.update(market_params)
        format.html { redirect_to @market, notice: 'Market was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @market.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /markets/1
  # DELETE /markets/1.json
  def destroy
    @market.destroy
    respond_to do |format|
      format.html { redirect_to markets_url }
      format.json { head :no_content }
    end
  end

	# 取引
	# POST /markets/1/trade
	def trade
		@amount = params[:amount].to_i / @market.evaluation_parameter.to_f
		@person_from = Person.find(params["person-from"].to_i)
		@person_to = Person.find(params["person-to"].to_i)
		if @person_from.present? and @person_to.present? and @amount > 0.0
			@person_from.pay(@person_to, @amount)
		end
		redirect_to market_path(@market)
	end

	# 自然回収
	# POST /markets/1/natural_recovery
	def natural_recovery
		n = params[:natural_recovery].to_i
		n = nil if n == 0
		if n > 0 and n < 100
			@market.natural_recovery!(n / 100.0)
		end
		redirect_to market_path(@market)
	end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_market
      @market = Market.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def market_params
      params.require(:market).permit(:name, :people_count,
				:evaluation_parameter, :initial_self_evaluation, :natural_recovery_rate)
    end
end
