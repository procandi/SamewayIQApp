require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'


class SettingsController < Rho::RhoController
  include BrowserHelper
  
  #move image serials to next step
  def do_move_right
    set_login_menu
    get_config
    
    @accno=@params['accno']
    @index=@params['index'].to_i()+1
    @imagemax=@params['imagemax'].to_i()
    #@temp=@params['imagehash'].split(',')
    #@imagehash=Hash.new(*@temp)
    @temp=@params['imagelist'].gsub(/[\"\[\]]/,'').gsub('\\\\','\\')
    @imagelist=@temp.split(',')

    do_image()
  end
  
  #move image serials to previous step
  def do_move_left
    set_login_menu
    get_config
    
    @accno=@params['accno']
    @index=@params['index'].to_i()-1
    @imagemax=@params['imagemax'].to_i()
    #@temp=@params['imagehash'].split(',')
    #@imagehash=Hash.new(*@temp)
    @temp=@params['imagelist'].gsub(/[\"\[\]]/,'').gsub('\\\\','\\')
    @imagelist=@temp.split(',')
    
    do_image()
  end
    
  #getting image from FTP server
  def do_image()  
    file_name = File.join(Rho::RhoApplication::get_base_app_path+'public/', "img#{@index}.jpg")
    url=@imagelist[@index].gsub('\\','/').gsub(/.*Cris_Images\//,"http://#{@ip}:#{@port}/")
    Rho::AsyncHttp.download_file(
      :url => url,
      :filename => file_name,
      :headers => {},
      :callback => url_for(:action => :httpdownload_callback)
    )

    @image=file_name  

    render :action => :image
  end
  
  #getting image list from Sinatra RESTful server
  def get_image_list
    set_login_menu
    get_config
        
    @accno=@params['accno'].gsub('{','').gsub('}','')
    
    request="http://#{@ip}:#{@port}/GetImageListByAccessionNO/#{@accno}"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    @temp = Rho::JSON.parse(res["body"])
    @imagemax=@temp.length
    #@imagehash=Hash.new do |hash,key|
    #  hash[key]=key
    #end
    #@imagemax.times() do |i|
    #  @imagehash[i]=@temp[i][0]+@temp[i][1]
    #end
    @imagelist=Array.new(@imagemax) do |i|  
      @temp[i][0]+@temp[i][1]
    end
    @index=0

    do_image()  
  end
  
  #getting report data from Sinatra RESTful server
  def do_report
    set_login_menu
    get_config
    
    @accno=@params['accno'].gsub('{','').gsub('}','')
    
    request="http://#{@ip}:#{@port}/OpenReportByAccessionNO/#{@accno}"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    @report = Rho::JSON.parse(res["body"].gsub('\\\r\\\n','<br>'))
        
    render :action => :report
  end
  
  #getting elink from Sinatra RESTful server
  def get_elink_today
    set_login_menu
    get_config
    
    #request="http://#{@ip}:#{@port}/QueryByAccessionNO/A11R4C02738"
    request="http://#{@ip}:#{@port}/QueryByChartNO/8006154"
    #request="http://#{@ip}:#{@port}/QueryByExamDate/2012/10/25"
    #request="http://#{@ip}:#{@port}/test"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    @elinks = Rho::JSON.parse(res["body"])
     
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
      get_elink_today
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
    
    if test ?e, path_to_prop
      fin=File.open(path_to_prop,'r')
      result=fin.read()
      @ip=result.gsub(/:.*/,'')
      @port=result.gsub(/.*:/,'')
      fin.close
    else
      @ip=''
      @port=''
    end
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
