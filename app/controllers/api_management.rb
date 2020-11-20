require 'json'

class ApiManagement < ApplicationController

  def loginBonita

    #Revisar si siempre va las mismas credenciales

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
      url: 'http://localhost:8080/bonita/API/bpm/process?f=name=Pool',
      headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
    )
    aux = conn.get()

    return JSON.parse((JSON.parse(aux.to_json))["body"])[0]["id"]
  end


  def createCase jsession, apiToken,cookie

    caseId = self.getProcessIdByName cookie

    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/API/bpm/case',
      params: {"processDefinitionId":caseId},
      headers: {'Content-Type' => 'application/json','X-Bonita-API-Token'=>apiToken,'JSESSIONID'=>jsession, 'Cookie'=>cookie}
    )
    #curl -X POST --url 'http://localhost:8080/bonita/API/bpm/case' --header 'X-Bonita-API-Token:9d745119-4de2-4836-9eba-ede5c6bbbd93' --header 'JSESSIONID:07B56B905A439F6F93E1F730F8A07AD2' --header 'Content-Type:"application/json"' --header 'Cookie:bonita.tenant=1;JSESSIONID=07B56B905A439F6F93E1F730F8A07AD2;X-Bonita-API-Token=9d745119-4de2-4836-9eba-ede5c6bbbd93; BOS_Locale=es_AR' -v -d '{"processDefinitionId":"5337047891591707718"}'
    resp = conn.post() do |req|
      req.body = {processDefinitionId:caseId}.to_json
    end
    resp
  end

  def setProcessProtocols jason
    #IMPLEMENTAR
  end


  def logoutBonita cookie
    conn = Faraday.new(
      url: 'http://localhost:8080/bonita/logoutservice',
      params: {"redirect":false},
      headers: {'Content-Type' => 'application/json','Cookie'=>cookie}
    )
    conn.get()
  end
end
