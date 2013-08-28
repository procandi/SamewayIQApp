require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'


class SettingsController < Rho::RhoController
  include BrowserHelper
  
  
  #login user information verify
  def do_login
    @id=@params['id']
    @password=@params['password']
    
    if @id==@password
      set_login_menu
      get_elink_all
    else
      render :action => :verify_faild
    end
  end
  
  #getting elink from Sinatra RESTful server
  def get_elink_all
    #res = Rho::AsyncHttp.get(
    #  :url => "http://192.168.1.140:9292/test"
    #)
    
    #@aa = Rho::JSON.parse(res["body"])
    @aa="aa" 
    render :action => :home
  end
  
  #setting login menu after logged
  def set_login_menu 
    @menu={
      "回清單" => Rho::RhoConfig.options_path+'/verify_faild',
      "登出" => Rho::RhoConfig.start_path
    }
  end
end
