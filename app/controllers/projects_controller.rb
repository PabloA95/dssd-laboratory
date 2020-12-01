require 'json'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!


def home_page
  @user = User.find(current_user.id)
  apim = ApiManagement.new
  jsession = session[:jsession]
  apiToken = session[:apiToken]
  cookie = session[:cookie]

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
          aux["instance"] = Instance.find(JSON.parse(JSON.parse(auxInstance.to_json)["body"])["value"].to_i)
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
      if @project.save
      # if true

        apim = ApiManagement.new
        jsession = session[:jsession]
        apiToken = session[:apiToken]
        cookie = session[:cookie]

#Crear caso y setear variables
        caseResponse =apim.createCase(jsession, apiToken, cookie)
        caseId = JSON.parse(caseResponse.body)["id"]
        auxOrdenar=[]

    params["params"].each { |key, value|
      if value["added"]
        @instance = Instance.new
        @instance.user_id = value["user"]
        @instance.protocol_id = value["protocol"]
        @instance.start_date = value["start_date"]
        @instance.end_date = value["end_date"]
        # @instance.project = @project
        @instance.project_id = @project.id
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

    aux1 = apim.setProject jsession, apiToken, cookie, caseId, @project.id
    aux1 = apim.setVariable jsession, apiToken, cookie, caseId, paramsAux.gsub("=>",":") #params["params"].to_json.to_s#paramsAux
    aux1 = apim.finishActivity jsession, apiToken, cookie, caseId	# caseId
    apim.setJefe jsession,apiToken,cookie,caseId,current_user.id

        format.html { redirect_to "/index", notice: "" } #paramsAux.gsub("=>",":")
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
  jsession = session[:jsession]
  apiToken = session[:apiToken]
  cookie = session[:cookie]

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
  jsession = session[:jsession]
  apiToken = session[:apiToken]
  cookie = session[:cookie]

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

def projectsWithAprovedProtocolsRunning
  apim = ApiManagement.new
  cookie = session[:cookie]

  projects=Project.all
  # @project=@projects.select { |proj|  (proj.instances.all? { |inst| inst.score.nil? or inst.score>=5 }) }
  @projects =projects.select { |p|p.instances.all? { |i|i.score.nil? or i.score >= 5 }}

  @running=apim.getRunningCases cookie
  ids=[]
  @running.each { |value|
    resp=apim.getVariable value["id"], cookie, 'projectId'
    ids.append(JSON.parse((JSON.parse(resp.to_json))["body"])["value"].to_i)
  }

  @projects=@projects.select{|pro| ids.include?(pro.id)}
end

def projectWithCurrentProtocolDelayed
  apim = ApiManagement.new
  cookie = session[:cookie]

  @running=apim.getRunningCases cookie
  @delayed=[]
  @running.each { |value|
    auxInstance=apim.getVariable value["id"], cookie, "actInstance"
    instanceId=JSON.parse((JSON.parse(auxInstance.to_json))["body"])["value"].to_i
    instance=Instance.find_by(id: instanceId)
    if(!instance.nil? && !instance.end_date.nil?)
      if(instance.end_date<DateTime.now)
        @delayed.append(instance)
      end
    end
  }
  # render json: @delayed
end

def auxiliar
  apim = ApiManagement.new
  cookie = session[:cookie]

  @running=apim.getRunningCases cookie
  ids=[]
  @running.each { |value|
    resp=apim.getVariable value["id"], cookie, 'projectId'
    ids.append(JSON.parse((JSON.parse(resp.to_json))["body"])["value"].to_i)
  }
  projects=Project.all
  # projects=projects.select{|act| !ids.include?(act.id) and act.instances.all{|act| act.score.nil? }}
  projectsids=projects.collect{ |act| act.id }
  aux = projectsids-ids
  return Project.find(aux)  #protocolos archivados
  # projects.collect{|a| a.instances}
end

def projectsFinishedWithAverageGreaterEqual5
  projects=self.auxiliar
  projects=projects.select{|act| act.instances.all?{|act| act.score.present? }  }
  # aux=projects.collect{|a| a.instances }
  @projects = projects.select{|proj| (proj.instances.size>0) and (proj.instances.inject(0){|sum,e| sum + e.score }/proj.instances.size) >=5 }
  # return result
  # render json: projects.collect{|a| a.instances }.flatten #finalizados y que no tienen score nil
end

def incompletedArchivedProject
  projects=self.auxiliar
  @projects=projects.select{|act| act.instances.any?{|act| act.score.nil? }  }
  # render json:@projects#.collect{|a| a.instances }
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
