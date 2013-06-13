class MarketsController < ApplicationController
	before_action :authenticate_user!, except: [:index, :show];
  before_action :set_market, only: [:show, :edit, :update, :destroy, :trade, :natural_recovery, :open, :close]
	before_action :authenticate_owner, only: [:edit, :update, :destroy, :open, :close]

  # GET /markets
  # GET /markets.json
  def index
    @markets = Market.all.order("updated_at desc")
  end

  # GET /markets/1
  # GET /markets/1.json
  def show
		@people = @market.people
    @matrix = @market.matrix_quantized
    @contributions = @market.contributions_quantized
    @trades = @market.trades.order("id desc")
    @nr_or_trades = @market.nr_or_trades
    @last_trade = @trades.first
    @last_propagations = @market.last_propagations
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
		@market.natural_recovery_ratio_percent = 1
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
        format.html { redirect_to @market, notice: '市場を作成しました。' }
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
        format.html { redirect_to @market, notice: '市場の設定を更新しました。' }
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
    if @market.closed?
      redirect_to @market, :error => "#{@market.name}は取引停止中です。"
    else
      @amount_human = params[:amount].to_f
      @amount = @amount_human / @market.evaluation_parameter.to_f
      @person_from = @market.people.find(params["person-from"].to_i)
      @person_to = @market.people.find(params["person-to"].to_i)
      if @person_from.present? and @person_to.present? and @amount > 0.0
        @market.trade(@person_from, @person_to, @amount)
        redirect_to @market, :notice => "取引を実施しました。（#{@person_from.name} から #{@person_to.name} へ #{@amount_human}）"
      else
        redirect_to @market, :error => "パラメータが正常でないため、取引を実施しませんでした。"
      end
    end
	end

	# 自然回収
	# POST /markets/1/natural_recovery
	def natural_recovery
    @market.natural_recovery_ratio_percent = params[:natural_recovery_ratio_percent]
    if @market.valid?
			@market.natural_recovery!
		end
		redirect_to @market
	end

  # 市場をオープンする
  def open
    if @market.closed?
      @market.open!
      redirect_to @market, :notice => "市場を取引再開しました。"
    else
      redirect_to @market, :error => "市場はすでに取引を受け付けています。"
    end
  end

  # 市場をクローズする
  def close
    if @market.opened?
      @market.close!
      redirect_to @market, :notice => "市場を取引停止しました。"
    else
      redirect_to @market, :error => "市場はすでに取引停止しています。"
    end
  end

  private
    def authenticate_owner
      if current_user != @market.user
        redirect_to @market, :error => "オーナーにしか許可されていない操作です。"
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_market
      @market = Market.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def market_params
      params.require(:market).permit(:name, :description, :people_count,
				:evaluation_parameter, :initial_self_evaluation, :natural_recovery_ratio_percent)
    end
end
