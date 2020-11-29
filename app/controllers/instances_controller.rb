class InstancesController < ApplicationController
  before_action :set_instance, only: [:show, :edit, :update, :destroy, :instance_form, :next]
  # before_action :authenticate_user!

  # GET /instances/form/:id/:caseId/:activityId
  def instance_form
    @caseId = params[:caseId]
    @activityId = params[:activityId]
  end

  # GET /instances/next/:id
  def next
    aux=[]
    total=0
    cant=0
    params['score'].each { |e| cant=cant+1; total=total+ e[1].to_i}
    aux.append(total)
    aux.append(total.to_f/cant)
    aux.append((total+cant-1)/cant)
    # @instance.score=(total+cant-1)/cant
#Para donde redondeamos?
    @instance.update(:score => (total+cant-1)/cant)
    # @instance.save

    apim = ApiManagement.new
    jsession = session[:jsession]
    apiToken = session[:apiToken]
    cookie = session[:cookie]

    aux1 = apim.setScore jsession, apiToken, cookie, params[:caseId], (total+cant-1)/cant
    aux1 = apim.finishActivity jsession, apiToken, cookie, params[:caseId]
    redirect_to "http://localhost:3000/index"
  end

  # GET /instances
  # GET /instances.json
  def index
    @instances = Instance.all
  end

  # GET /instances/1
  # GET /instances/1.json
  def show
  end

  # GET /instances/new
  def new
    @instance = Instance.new
  end

  # GET /instances/1/edit
  def edit
  end

  # POST /instances
  # POST /instances.json
  def create
    @instance = Instance.new(instance_params)

    respond_to do |format|
      if @instance.save
        format.html { redirect_to @instance, notice: 'Instance was successfully created.' }
        format.json { render :show, status: :created, location: @instance }
      else
        format.html { render :new }
        format.json { render json: @instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instances/1
  # PATCH/PUT /instances/1.json
  def update
    respond_to do |format|
      if @instance.update(instance_params)
        format.html { redirect_to @instance, notice: 'Instance was successfully updated.' }
        format.json { render :show, status: :ok, location: @instance }
      else
        format.html { render :edit }
        format.json { render json: @instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instances/1
  # DELETE /instances/1.json
  def destroy
    @instance.destroy
    respond_to do |format|
      format.html { redirect_to instances_url, notice: 'Instance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_instance
      @instance = Instance.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def instance_params
      params.require(:instance).permit(:name, :user_id, :start_date, :end_date, :order, :local, :score, :project_id, :protocol_id)
    end
end
