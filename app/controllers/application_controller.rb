class ApplicationController < ActionController::Base

  def after_sign_in_path_for(resource)
        apim = ApiManagement.new
        respuestaLogin = apim.loginBonita current_user.bonitaUser, current_user.bonitaPassword
        formatearJSONLogin = respuestaLogin.headers["set-cookie"].split(/,|;/).map {|aux| aux.gsub(' ','').split('=')}
        hashedLogin = Hash[formatearJSONLogin.map {|key, value| [key, value]}]

        session[:jsession] = hashedLogin["JSESSIONID"]
        session[:apiToken] = hashedLogin["X-Bonita-API-Token"]
        session[:cookie] = apim.assembleCookie hashedLogin
    index_url
  end

  def after_sign_out_path_for(resource)
    cookie = session[:cookie]
    apim = ApiManagement.new
    close = apim.logoutBonita cookie
    index_url
  end
  protected
  def authenticate_user!
  	if user_signed_in?
      super
    else
      # redirect_to login_path, :notice => 'if you want to add a notice'
      redirect_to "/users/sign_in"
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end
end
