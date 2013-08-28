require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'


class SettingsController < Rho::RhoController
  include BrowserHelper
  
  def do_go
    render :action => :home2
  end
  
  #getting elink from Sinatra RESTful server
  def get_elink_all
    res = Rho::AsyncHttp.get(
      :url => "http://192.168.1.140:9292/QueryByChartNO/9"
    )
    
    @aa = Rho::JSON.parse(res["body"])
     
    render :action => :home
  end
  
  #setting login menu after logged
  def set_login_menu 
    @menu={
      "回清單" => Rho::RhoConfig.options_path+'/verify_faild',
      "登出" => Rho::RhoConfig.start_path
    }
  end  
  
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
  
  #reading config from file
  def get_config
    
  end
  
  #setting config to file
  def do_config
    path_to_prop=Rho::RhoApplication::get_blob_path('/')+'config.propertories'
        
    fout=File.open(path_to_prop,'w')
    fout.write(123)
    fout.close
    
    render :text => 'success'
  end
end
