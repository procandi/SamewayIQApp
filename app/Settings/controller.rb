require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'


class SettingsController < Rho::RhoController
  include BrowserHelper
  
  #getting report data from Sinatra RESTful server
  def do_image
    get_config
    
    @id=@params['id']
      
    #request="http://#{@ip}:#{@port}/OpenReportByAccessionNO/#{@id}"
    #res = Rho::AsyncHttp.get(
    #  :url => request
    #)
    
    @image=@id
      
    render :action => :image
  end
  
  #getting report data from Sinatra RESTful server
  def do_report
    get_config
    
    @id=@params['id']
    
    request="http://#{@ip}:#{@port}/OpenReportByAccessionNO/#{@id}"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    @report = Rho::JSON.parse(res["body"].gsub('\\\r\\\n','<br>'))
    
    render :action => :report
  end
  
  #getting elink from Sinatra RESTful server
  def get_elink_all
    #request="http://#{@ip}:#{@port}/QueryByAccessionNO/1429958235"
    request="http://#{@ip}:#{@port}/QueryByChartNO/2172145"
    #request="http://#{@ip}:#{@port}/QueryByExamDate/2012/10/25"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    @aa = Rho::JSON.parse(res["body"])
     
    render :action => :home
  end
  
  #setting login menu after logged
  def set_login_menu 
    @menu={
      "前一頁" => :back,
      "回清單" => Rho::RhoConfig.options_path+'/verify_faild',
      "登出" => Rho::RhoConfig.start_path,
      "重新整理" => :refresh, 
      "關閉系統" => :close,
      "除錯" => :log
    }
  end  
  
  #login user information verify
  def do_login
    @id=@params['id']
    @password=@params['password']
    
    if @id==@password
      set_login_menu
      get_config
      get_elink_all
    else
      render :action => :verify_faild
    end
  end
  
  #get the saved config and show config page
  def go_config
    get_config
    render :action => :config
  end
  
  #reading config from file
  def get_config
    path_to_prop=Rho::RhoApplication::get_blob_path('/')+'config.propertories'
        
    fin=File.open(path_to_prop,'r')
    result=fin.read()
    @ip=result.gsub(/:.*/,'')
    @port=result.gsub(/.*:/,'')
    fin.close
  end
  
  #setting config to file
  def do_config
    @ip=@params['ip']
    @port=@params['port']
      
    path_to_prop=Rho::RhoApplication::get_blob_path('/')+'config.propertories'
        
    fout=File.open(path_to_prop,'w')
    fout.write("#{@ip}:#{@port}")
    fout.close
    
    render :action => :verify_success
  end
end
