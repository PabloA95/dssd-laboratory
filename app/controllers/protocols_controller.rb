class ProtocolsController < ApplicationController
  before_action :set_protocol, only: [:show, :edit, :update, :destroy]
  # before_action :authenticate_user!


  # GET /protocols
  # GET /protocols.json
  def index
    @protocols = Protocol.all
  end

  # GET /protocols/1
  # GET /protocols/1.json
  def show
  end

  # GET /protocols/new
  def new
    @protocol = Protocol.new
  end

  # GET /protocols/1/edit
  def edit
  end

  # POST /protocols
  # POST /protocols.json
  def create
    @protocol = Protocol.new(protocol_params)

    respond_to do |format|
      # if true
      if @protocol.save
        #params['protocol']['activity']
        aux=[]
        activities=[]
        params['protocol']['activity'].each { |act|
          aux.append(act)
          @activity = Activity.new
          @activity.name=act[1] #buscar forma mas linda
          @activity.protocol=@protocol
          activities.append(@activity.name)
          # @activity.protocol_id=@protocol.id
          # @activity.protocol=@protocol
          aux.append(@activity)
          @activity.save
         }

      ##########Crear protocolos en heroku too
      if (!@protocol.local)
        
        apim = ApiManagement.new
        response = apim.loginHeroku
        token = response.body()
        parsedTkn = JSON.parse(token)
        apim.createProtocol parsedTkn["token"], @protocol.name , activities.join(",")
      end
      ##########

        format.html { redirect_to @protocol, notice: "" }
        # format.html { redirect_to @protocol, notice: 'Protocol was successfully created.' }
        format.json { render :show, status: :created, location: @protocol }
      else
        format.html { render :new }
        format.json { render json: @protocol.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /protocols/1
  # PATCH/PUT /protocols/1.json
  def update
    respond_to do |format|
      if @protocol.update(protocol_params)
        format.html { redirect_to @protocol, notice: 'Protocol was successfully updated.' }
        format.json { render :show, status: :ok, location: @protocol }
      else
        format.html { render :edit }
        format.json { render json: @protocol.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /protocols/1
  # DELETE /protocols/1.json
  def destroy
    @protocol.destroy
    respond_to do |format|
      format.html { redirect_to protocols_url, notice: 'Protocol was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_protocol
      @protocol = Protocol.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def protocol_params
      params.require(:protocol).permit(:name, :local)
    end
end
