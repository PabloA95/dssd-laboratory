require 'json'

class ApiManagement < ApplicationController

  def loginBonita

    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/loginservice',
      params: {"username":"walter.bates","password":"bpm","redirect":"false","redirectURL":""},
      headers: {'Content-Type' => 'application/x-www-form-urlencoded'}
    )
    resp = conn.post()
    return resp
  end


  def assembleCookie auxJson
    #Cookie:bonita.tenant=1; X-Bonita-API-Token=9d745119-4de2-4836-9eba-ede5c6bbbd93; JSESSIONID=07B56B905A439F6F93E1F730F8A07AD2; BOS_Locale=es_AR
    cookie='bonita.tenant='+auxJson["bonita.tenant"]
    cookie=cookie+'; X-Bonita-API-Token='+auxJson["X-Bonita-API-Token"]
    cookie=cookie+'; JSESSIONID='+auxJson["JSESSIONID"]
    cookie=cookie+'; BOS_Locale='+auxJson["BOS_Locale"]
  end


  def getProcessIdByName cookie
    # curl -b saved_cookies.txt -X GET --url 'http://localhost:8080/bonita/API/bpm/process?f=name=Pool1' -v
    # [{"displayDescription":"","deploymentDate":"2020-11-16 11:45:33.555","displayName":"Pool1","name":"Pool1","description":"","deployedBy":"4","id":"5520735587104525227","activationState":"ENABLED","version":"1.0","configurationState":"RESOLVED","last_update_date":"2020-11-16 11:45:34.082","actorinitiatorid":"1101"}]
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/process?f=name=Testeo de medicamento',
      headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
    )
    aux = conn.get()

    return JSON.parse((JSON.parse(aux.to_json))["body"])[0]["id"]
  end


  def createCase jsession, apiToken,cookie

    caseId = self.getProcessIdByName cookie

    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/case',
      #params: {"processDefinitionId":caseId},
      headers: {'Content-Type' => 'application/json','X-Bonita-API-Token'=>apiToken,'JSESSIONID'=>jsession, 'Cookie'=>cookie}
    )
    #curl -X POST --url 'http://localhost:8080/bonita/API/bpm/case' --header 'X-Bonita-API-Token:9d745119-4de2-4836-9eba-ede5c6bbbd93' --header 'JSESSIONID:07B56B905A439F6F93E1F730F8A07AD2' --header 'Content-Type:"application/json"' --header 'Cookie:bonita.tenant=1;JSESSIONID=07B56B905A439F6F93E1F730F8A07AD2;X-Bonita-API-Token=9d745119-4de2-4836-9eba-ede5c6bbbd93; BOS_Locale=es_AR' -v -d '{"processDefinitionId":"5337047891591707718"}'
    resp = conn.post() do |req|
      req.body = {processDefinitionId:caseId}.to_json
    end
    resp
  end

  def setVariable jsession,apiToken,cookie,caseId,valueToSet
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/caseVariable/'+caseId.to_s+'/jsonString',
      # params: {'value':'{"aaa":1,"bbb":123,"ccc":"w"}', 'type': "java.util.List"},
      headers: {'Content-Type' => 'application/json','X-Bonita-API-Token'=>apiToken,'JSESSIONID'=>jsession, 'Cookie'=>cookie}
    )
    aux='{"value":['+valueToSet+'], "type": "java.lang.String"}'
    resp = conn.put() do |req|
      req.body = aux
    end
    resp
  end



  def getActualActivity cookie, caseId
    # curl -b saved_cookies.txt -X GET
    # --url 'http://localhost:8080/bonita/API/bpm/activity?p=0&c=10&f=caseId%3d9004' -v
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/activity?p=0&c=10&f=caseId%3d'+caseId.to_s,
      headers: {'Cookie'=>cookie}
    )
    aux = conn.get()
    return aux
    # return JSON.parse((JSON.parse(aux.to_json))["body"])[0]["id"]

  end

  def finishActivity jsession, apiToken, cookie, caseId #finishTask???
    # curl -b saved_cookies.txt -X PUT --url 'http://localhost:8080/bonita/API/bpm/userTask/180008'
    # -v -d '{"assigned_id" : "4","state":"completed"}'
    # --header 'X-Bonita-API-Token:'$bbb --header 'JSESSIONID:'$aaa --header 'Content-Type:"application/json"'
# 220010
    response = self.getActualActivity cookie, caseId
    activityId = JSON.parse(JSON.parse(response.to_json)["body"])[0]["id"]

    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/userTask/'+activityId,
      headers: {'Content-Type' => 'application/json','X-Bonita-API-Token'=>apiToken,'JSESSIONID'=>jsession, 'Cookie'=>cookie}
    )
    resp = conn.put() do |req|
      # aux='{"assigned_id" : "###","state":"completed"}'
      req.body = '{"assigned_id" : "4","state":"completed"}' # Revisar lo de asignar el responsable
    end
    resp
    # JSON.parse((JSON.parse(response.to_json))["body"])[0]["id"]
  end


  def logoutBonita cookie
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/logoutservice',
      params: {"redirect":false},
      headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
    )
    conn.get()
  end

##################################################################################

  def getActivitiesList cookie, name
    # curl -b saved_cookies.txt -X GET
    # --url 'http://localhost:8080/bonita/API/bpm/activity?p=0&c=10&f=name%3dTarea2'
    # --header 'Content-Type:"application/json"' -v
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/activity?p=0&c=10&f=name%3d'+name, #cambiar paginacion
      headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
    )
    aux = conn.get()

    return aux
    # return JSON.parse((JSON.parse(aux.to_json))["body"])[0]["id"]
  end

  def getResponsableForCase caseId, cookie
    # /API/bpm/caseVariable/:caseId/:variableName
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/caseVariable/'+caseId+'/actResponsable',  #Actualizar nombre
      headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
    )
    aux = conn.get()
return aux
  end

  def getVariable caseId, cookie, varName
    # /API/bpm/caseVariable/:caseId/:variableName
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/caseVariable/'+caseId+'/'+varName,  #Actualizar nombre
      headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
    )
    aux = conn.get()
return aux
    # return JSON.parse((JSON.parse(aux.to_json))["body"])["value"]
    # return aux #JSON.parse((JSON.parse(aux.to_json))["body"])[0]["value"].to_i
  end

  def getJefeForCase caseId, cookie
    # /API/bpm/caseVariable/:caseId/:variableName
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/caseVariable/'+caseId.to_s+'/jefe',  #Actualizar nombre
      headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
    )
    aux = conn.get()

    return aux #JSON.parse((JSON.parse(aux.to_json))["body"])[0]["value"].to_i
  end

  def setResponsable jsession,apiToken,cookie,activityId,responsable
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/userTask/'+activityId,
      headers: {'Content-Type' => 'application/json','X-Bonita-API-Token'=>apiToken,'JSESSIONID'=>jsession, 'Cookie'=>cookie}
    )
    resp = conn.put() do |req|
      # aux='{"assigned_id" : "###","state":"completed"}'
      req.body = '{"assigned_id" : '+responsable.to_s+'}' # Revisar lo de asignar el responsable
    end
    resp
  end

  def setScore jsession,apiToken,cookie,caseId,score
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/caseVariable/'+caseId.to_s+'/actScore',
      headers: {'Content-Type' => 'application/json','X-Bonita-API-Token'=>apiToken,'JSESSIONID'=>jsession, 'Cookie'=>cookie}
    )
    aux='{"value":'+score.to_s+', "type": "java.lang.Integer"}'
    resp = conn.put() do |req|
      req.body = aux
    end
    resp
  end

  def setJefe jsession,apiToken,cookie,caseId,jefe
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/caseVariable/'+caseId.to_s+'/jefe',
      headers: {'Content-Type' => 'application/json','X-Bonita-API-Token'=>apiToken,'JSESSIONID'=>jsession, 'Cookie'=>cookie}
    )
    aux='{"value":'+jefe.to_s+', "type": "java.lang.Integer"}'
    resp = conn.put() do |req|
      req.body = aux
    end
    resp
  end

  def setDecision jsession,apiToken,cookie,caseId,decision
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/caseVariable/'+caseId.to_s+'/decision',
      headers: {'Content-Type' => 'application/json','X-Bonita-API-Token'=>apiToken,'JSESSIONID'=>jsession, 'Cookie'=>cookie}
    )
    aux='{"value":"'+decision+'", "type": "java.lang.String"}'
    resp = conn.put() do |req|
      req.body = aux
    end
    resp
  end

  def setProject jsession, apiToken, cookie, caseId, project
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/caseVariable/'+caseId.to_s+'/projectId',
      headers: {'Content-Type' => 'application/json','X-Bonita-API-Token'=>apiToken,'JSESSIONID'=>jsession, 'Cookie'=>cookie}
    )
    aux='{"value":'+project.to_s+', "type": "java.lang.Integer"}'
    resp = conn.put() do |req|
      req.body = aux
    end
    resp
  end

  def getRunningCases cookie
    # curl -b saved_cookies.txt -X GET --url 'http://localhost:8080/bonita/API/bpm/process?f=name=Testeo%20de%20medicamento'
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/case?f=name=Testeo%20de%20medicamento',
      headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
    )
    aux = conn.get()

    return JSON.parse((JSON.parse(aux.to_json))["body"])

  end

  def getFinishedCases cookie
    # curl -b saved_cookies.txt -X GET --url 'http://localhost:8080/bonita/API/bpm/process?f=name=Testeo%20de%20medicamento'
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/archivedCase?f=name=Testeo%20de%20medicamento',
      headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
    )
    aux = conn.get()

    return JSON.parse((JSON.parse(aux.to_json))["body"])

  end
end
