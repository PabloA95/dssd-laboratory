class ApplicationController < ActionController::Base
  
  def after_sign_in_path_for(resource)
    index_url
  end
  def after_sign_out_path_for(resource)
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
