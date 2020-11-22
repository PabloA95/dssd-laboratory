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
        a3 = respuestaLogin.headers["set-cookie"].split(/,|;/).map {|aux| aux.gsub(' ','').split('=')}
        prueba = Hash[a3.map {|key, value| [key, value]}]
        jsession = prueba["JSESSIONID"]
        apiToken = prueba["X-Bonita-API-Token"]
        cookie = apim.assembleCookie prueba
#####
        a2=apim.createCase(jsession, apiToken, cookie)

        hash = {}
        i=0
        params['added'].each { |key, value|
          @instance = Instance.new
          #@instance.user=params['user'][key]
          #Instance copiar valores de protocolo
          #@instance.save
          hash[i]={'protocolo'=> key, 'responsable'=>params['user'][key], 'local'=> params['local'][key] }
          i=i+1
         }

         #ENVIAR PARA SETEAR LAS VARIABLES DE BONITA
         # apim.setProcessProtocols(hash.to_json)
close = apim.logoutBonita cookie
        format.html { redirect_to @project, notice: hash.to_json } #@aux['set-cookie']
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
