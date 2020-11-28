require 'json'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  #after_action :logerBonita, only: [:authenticate_user!]
  #after_action :logerOutBonita, only: [:destroy_user_session!]

# def logerBonita
#   if (user_signed_in?) #(current_user != nil) #defined?(current_user) != nil
#     apim = ApiManagement.new
#     respuestaLogin = apim.loginBonita
#     formatearJSONLogin = respuestaLogin.headers["set-cookie"].split(/,|;/).map {|aux| aux.gsub(' ','').split('=')}
#     hashedLogin = Hash[formatearJSONLogin.map {|key, value| [key, value]}]
#
#     session[:jsession] = hashedLogin["JSESSIONID"]
#     session[:apiToken] = hashedLogin["X-Bonita-API-Token"]
#     session[:cookie] = apim.assembleCookie hashedLogin
#     # jsession = hashedLogin["JSESSIONID"]
#     # apiToken = hashedLogin["X-Bonita-API-Token"]
#     # cookie = apim.assembleCookie hashedLogin
#   end
# end
#
# def logerOutBonita
#   cookie = session[:cookie]
#   apim = ApiManagement.new
#   close = apim.logoutBonita cookie
# end

def home_page
  @user = User.find(current_user.id)

  # ESTO HAY QUE HACERLO UNA VEZ CUANDO SE LOGUEA Y DESPUES GUARDARLAS EN SESSION!!!
  apim = ApiManagement.new
  respuestaLogin = apim.loginBonita
  formatearJSONLogin = respuestaLogin.headers["set-cookie"].split(/,|;/).map {|aux| aux.gsub(' ','').split('=')}
  hashedLogin = Hash[formatearJSONLogin.map {|key, value| [key, value]}]
  jsession = hashedLogin["JSESSIONID"]
  apiToken = hashedLogin["X-Bonita-API-Token"]
  cookie = apim.assembleCookie hashedLogin
  #
  @listaMostrar=[]
  if (current_user.has_role? :responsable)
    lista = apim.getActivitiesList cookie, "Ejecucion local" #revisar si se puede pasar el id para que filtre segun la variable de proceso
    lista = JSON.parse(JSON.parse(lista.to_json)["body"])
    lista.each { |value|
        responsable = apim.getResponsableForCase value["caseId"], cookie  #No lo encuentra poque no lo definimos
        # responsable = apim.getVariable value["caseId"], cookie, "actResponsable"
        responsableId = JSON.parse(JSON.parse(responsable.to_json)["body"])["value"]

        if (responsableId.to_i==@user.id)
          aux={}
  #         #-enviar tambien proyectId y protocolId o solo instanceid
          apim.setResponsable jsession,apiToken,cookie,value["id"],4 # => walter.bates #@user.id  #hay que conseguir los tokens y las cookies
          auxInstance=apim.getVariable value["caseId"], cookie, "actInstance"
          aux["instance"] = JSON.parse(JSON.parse(auxInstance.to_json)["body"])["value"]
          aux["activityId"] = value["id"]
          aux["caseId"] = value["caseId"]
          @listaMostrar.append(aux)
        end
    }
  end

  @listaJefe=[]
  if (current_user.has_role? :jefe)
    lista2 = apim.getActivitiesList cookie, "Tomar decision" #CAMBIAR NOMBRE
    lista2 = JSON.parse(JSON.parse(lista2.to_json)["body"])
    lista2.each { |value|
        jefe = apim.getJefeForCase value["caseId"], cookie

        # jefe = apim.getVaraible value["caseId"], cookie, "jefe"
        jefeId = JSON.parse(JSON.parse(jefe.to_json)["body"])["value"]
        if (@user.id==jefeId.to_i)
          @listaJefe.append(value)
        end
      }
  end
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
# jsession = session[:jsession]
# apiToken = session[:apiToken]
# cookie = session[:cookie]
######

        # hash = {}
#         i=0
#         params['added'].each { |key, value|
#           @instance = Instance.new
#           #@instance.user=params['user'][key]
#
#           #@instance.save
#           hash[i]={'protocolo'=> key, 'responsable'=>params['user'][key], 'local'=> params['local'][key] }
#           aux=hash.to_json+","
#           i=i+1
#          }
# valueToSet="["+hash.to_json+"]"

#Crear caso y setear variables
        caseResponse =apim.createCase(jsession, apiToken, cookie)
        caseId = JSON.parse(caseResponse.body)["id"]
auxOrdenar=[]

    params["params"].each { |key, value|
      if value["added"]
        @instance = Instance.new
        @instance.user_id = value["user"]
        @instance.protocol_id = value["protocol"]
        # @instance.project = @project
        @instance.project_id = 1
        @instance.save
        # Instance(id: integer, name: string, user_id: integer,
        #start_date: datetime, end_date: datetime, order: integer,
        # local: boolean, score: integer, project_id: integer,
        #protocol_id: integer, created_at: datetime, updated_at: datetime)

        #Instance copiar valores de protocolo

        #Crear instancia!!!
        # if (value["local"]=="0")
        value["instance"]=@instance.id
        auxOrdenar.append(value)
      end
    }
    auxOrdenar=auxOrdenar.sort_by { |w| w["orden"] }
    paramsAux=auxOrdenar.join(',')
    # paramsAux=paramsAux[1...]


    #DESHARCODEAR despues de terminar
    aux1 = apim.setVariable jsession, apiToken, cookie, caseId, paramsAux.gsub("=>",":") #params["params"].to_json.to_s#paramsAux
# Setear el jefe
######
aux1 = apim.finishActivity jsession, apiToken, cookie, caseId	# caseId
apim.setJefe jsession,apiToken,cookie,caseId,current_user.id

# close = apim.logoutBonita cookie
        format.html { redirect_to @project, notice: paramsAux.gsub("=>",":") }
        # format.html { redirect_to @project, notice: JSON.parse(@aux.headers["set-cookie"]) }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

# GET /projects/tomar_decision
def tomar_decision_form

  apim = ApiManagement.new
  respuestaLogin = apim.loginBonita
  #Hacer una funcion para esto
  #Recuperar tokens de la sesion
  formatearJSONLogin = respuestaLogin.headers["set-cookie"].split(/,|;/).map {|aux| aux.gsub(' ','').split('=')}
  hashedLogin = Hash[formatearJSONLogin.map {|key, value| [key, value]}]
  jsession = hashedLogin["JSESSIONID"]
  apiToken = hashedLogin["X-Bonita-API-Token"]
  cookie = apim.assembleCookie hashedLogin

  @caseId=params["caseId"]
  @activityId=params["activityId"]
  instancia=apim.getVariable @caseId, cookie, "actInstance"
  instancia=JSON.parse(JSON.parse(instancia.to_json)["body"])["value"]
  @instancia = Instance.find(instancia)

  # render json: @instancia
end

# POST /projects/resolver
def resolver
  apim = ApiManagement.new
  respuestaLogin = apim.loginBonita
  #Hacer una funcion para esto
  #Recuperar tokens de la sesion
  formatearJSONLogin = respuestaLogin.headers["set-cookie"].split(/,|;/).map {|aux| aux.gsub(' ','').split('=')}
  hashedLogin = Hash[formatearJSONLogin.map {|key, value| [key, value]}]
  jsession = hashedLogin["JSESSIONID"]
  apiToken = hashedLogin["X-Bonita-API-Token"]
  cookie = apim.assembleCookie hashedLogin


# render json: params["decision"]
apim.setDecision jsession,apiToken,cookie,params["caseId"],params["decision"]
aux1 = apim.finishActivity jsession, apiToken, cookie, params["caseId"]
  redirect_to "http://localhost:3000/index"
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
