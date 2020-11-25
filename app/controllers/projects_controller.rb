require 'json'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

def home_page
  @user = User.find(current_user.id)
end


  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
    @protocols = Protocol.all
    @users = User.getResponsables
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    @project.user=current_user
    @project.start_date=DateTime.now
    respond_to do |format|
      # if @project.save
      if true

        apim = ApiManagement.new
respuestaLogin = apim.loginBonita

#Hacer una funcion para esto
#Recuperar tokens de la sesion
        formatearJSONLogin = respuestaLogin.headers["set-cookie"].split(/,|;/).map {|aux| aux.gsub(' ','').split('=')}
        hashedLogin = Hash[formatearJSONLogin.map {|key, value| [key, value]}]
        jsession = hashedLogin["JSESSIONID"]
        apiToken = hashedLogin["X-Bonita-API-Token"]
        cookie = apim.assembleCookie hashedLogin
######

        # hash = {}
#         i=0
#         params['added'].each { |key, value|
#           @instance = Instance.new
#           #@instance.user=params['user'][key]
#           #Instance copiar valores de protocolo
#           #@instance.save
#           hash[i]={'protocolo'=> key, 'responsable'=>params['user'][key], 'local'=> params['local'][key] }
#           aux=hash.to_json+","
#           i=i+1
#          }
# valueToSet="["+hash.to_json+"]"

#Crear caso y setear variables
        # caseResponse =apim.createCase(jsession, apiToken, cookie)
        # caseId = JSON.parse(caseResponse.body)["id"]
auxOrdenar=[]
# paramsAux=""
    params["params"].each { |key, value|
      if value["added"]
        auxOrdenar.append(value)
        # paramsAux=paramsAux+","+value.to_json.to_s
        #Crear instancia!!!
      end
    }
    auxOrdenar=auxOrdenar.sort_by { |w| w["orden"] }
    paramsAux=auxOrdenar.join(',')
    # paramsAux=paramsAux[1...]
    aux1 = apim.setVariable jsession, apiToken, cookie, 12048, paramsAux.gsub("=>",":") #params["params"].to_json.to_s#paramsAux

######
# aux1 = apim.finishActivity jsession, apiToken, cookie, 12006	# caseId

close = apim.logoutBonita cookie
        format.html { redirect_to @project, notice: aux1 }
        # format.html { redirect_to @project, notice: JSON.parse(@aux.headers["set-cookie"]) }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :user_id, :start_date, :end_date)
    end
end
