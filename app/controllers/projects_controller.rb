require 'json'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

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
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if true
        @aux = self.callAPIAux
      # if @project.save
        # format.html { redirect_to @project, notice: JSON.parse(@aux.headers["set-cookie"]) }
        
#Hacer una funcion para esto
        a3 = @aux.headers["set-cookie"].split(/,|;/).map {|aux| aux.gsub(' ','').split('=')}
        prueba = Hash[a3.map {|key, value| [key, value]}]
        jsession = prueba["JSESSIONID"]
        apiToken = prueba["X-Bonita-API-Token"]
#####
        cookie = self.assembleCookie prueba
        a2=self.callAPICase(jsession, apiToken, cookie)
        close = self.closeSessionAPI cookie
        aaaaa = []
        params['added'].each { |key, value| 
          @instance = Instance.new
          # @instance.user=params['project']['users'][key]
          aaaaa.append(params['user'][key])
          aaaaa.append(key)
          #@instance.save
         }

        format.html { redirect_to @project, notice: aaaaa } #@aux['set-cookie']
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

def assembleCookie auxJson
  cookie='bonita.tenant='+auxJson["bonita.tenant"]
  cookie=cookie+'; X-Bonita-API-Token='+auxJson["X-Bonita-API-Token"]
  cookie=cookie+'; JSESSIONID='+auxJson["JSESSIONID"]
  cookie=cookie+'; BOS_Locale='+auxJson["BOS_Locale"]
  #Cookie:bonita.tenant=1; X-Bonita-API-Token=9d745119-4de2-4836-9eba-ede5c6bbbd93; JSESSIONID=07B56B905A439F6F93E1F730F8A07AD2; BOS_Locale=es_AR

end

def callAPICase jsession, apiToken,cookie
  #curl -b saved_cookies.txt -X POST 
  #--url 'http://localhost:8080/bonita/API/bpm/case' 
  #--header 'X-Bonita-API-Token:830d1632-148e-4838-a457-d13af98b0092' 
  #--header 'JSESSIONID:7B74C771666D6E832DB45E231DCE9C02' 
  #--header 'Content-Type:"application/json"' 
  #-v -d '{"processDefinitionId":"5337047891591707718"}'
  
  conn = Faraday.new(
    url: 'http://localhost:8080/bonita/API/bpm/case',
    params: {"processDefinitionId":"5337047891591707718"},
    headers: {'Content-Type' => 'application/json','X-Bonita-API-Token'=>apiToken,'JSESSIONID'=>jsession, 'Cookie'=>cookie}
  )
  #Cookie:bonita.tenant=1; X-Bonita-API-Token=9d745119-4de2-4836-9eba-ede5c6bbbd93; JSESSIONID=07B56B905A439F6F93E1F730F8A07AD2; BOS_Locale=es_AR

  #curl -X POST --url 'http://localhost:8080/bonita/API/bpm/case' --header 'X-Bonita-API-Token:9d745119-4de2-4836-9eba-ede5c6bbbd93' --header 'JSESSIONID:07B56B905A439F6F93E1F730F8A07AD2' --header 'Content-Type:"application/json"' --header 'Cookie:bonita.tenant=1;JSESSIONID=07B56B905A439F6F93E1F730F8A07AD2;X-Bonita-API-Token=9d745119-4de2-4836-9eba-ede5c6bbbd93; BOS_Locale=es_AR' -v -d '{"processDefinitionId":"5337047891591707718"}'
  resp = conn.post() do |req|
    req.body = {processDefinitionId:5337047891591707718}.to_json
  end
  resp
end

def closeSessionAPI cookie 
  # Esto no funciono
# # # Request URL http://host:port/bonita/logoutservice
# # # Request Method  GET
# # # Query parameter redirect: true or false (default set to true)
# curl -X GET http://localhost:8080/bonita/logoutservice -d '{"redirect":false}' -b saved_cookies.txt -v
  conn = Faraday.new(
    url: 'http://localhost:8080/bonita/logoutservice',
    params: {"redirect":false},
    headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
  )
  conn.get()
end


def callAPIAux
  conn = Faraday.new(
    url: 'http://localhost:8080/bonita/loginservice',
    params: {"username":"walter.bates","password":"bpm","redirect":"false","redirectURL":""},
    headers: {'Content-Type' => 'application/x-www-form-urlencoded'}
  )

  resp = conn.post()
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
