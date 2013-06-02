class PropagationsController < ApplicationController
  before_action :set_propagation, only: [:show, :edit, :update, :destroy]

  # GET /propagations
  # GET /propagations.json
  def index
    @propagations = Propagation.all
  end

  # GET /propagations/1
  # GET /propagations/1.json
  def show
  end

  # GET /propagations/new
  def new
    @propagation = Propagation.new
  end

  # GET /propagations/1/edit
  def edit
  end

  # POST /propagations
  # POST /propagations.json
  def create
    @propagation = Propagation.new(propagation_params)

    respond_to do |format|
      if @propagation.save
        format.html { redirect_to @propagation, notice: 'Propagation was successfully created.' }
        format.json { render action: 'show', status: :created, location: @propagation }
      else
        format.html { render action: 'new' }
        format.json { render json: @propagation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /propagations/1
  # PATCH/PUT /propagations/1.json
  def update
    respond_to do |format|
      if @propagation.update(propagation_params)
        format.html { redirect_to @propagation, notice: 'Propagation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @propagation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /propagations/1
  # DELETE /propagations/1.json
  def destroy
    @propagation.destroy
    respond_to do |format|
      format.html { redirect_to propagations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_propagation
      @propagation = Propagation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def propagation_params
      params.require(:propagation).permit(:trade_id, :actor_from_id, :actor_to_id, :amount)
    end
end
