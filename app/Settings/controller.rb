require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'


class SettingsController < Rho::RhoController
  include BrowserHelper
  
  #to do move image serials to next step
  def do_image_move_right
    set_login_menu
    get_config
    
    @accno=@params['accno']
    @index=@params['index'].to_i()+1
    @imagemax=@params['imagemax'].to_i()
    #@temp=@params['imagehash'].split(',')
    #@imagehash=Hash.new(*@temp)
    @temp=@params['imagelist'].gsub(/[\"\[\]]/,'').gsub('\\\\','\\')
    @imagelist=@temp.split(',')

    @image=File.join(Rho::RhoApplication::get_base_app_path+'public/', "img#{@index}.jpg")
        
    render :action => :image
  end
  
  #to do move image serials to previous step
  def do_image_move_left
    set_login_menu
    get_config
    
    @accno=@params['accno']
    @index=@params['index'].to_i()-1
    @imagemax=@params['imagemax'].to_i()
    #@temp=@params['imagehash'].split(',')
    #@imagehash=Hash.new(*@temp)
    @temp=@params['imagelist'].gsub(/[\"\[\]]/,'').gsub('\\\\','\\')
    @imagelist=@temp.split(',')
    
    @image=File.join(Rho::RhoApplication::get_base_app_path+'public/', "img#{@index}.jpg")
    
    render :action => :image
  end
    
  #getting image from FTP server
  def get_image(imagelist,index)    
    file_name = File.join(Rho::RhoApplication::get_base_app_path+'public/', "img#{index}.jpg")
    url=imagelist[index].gsub('\\','/').gsub(/.*Cris_Images\//,"http://#{@ip}:#{@port}/")
    Rho::AsyncHttp.download_file(
      :url => url,
      :filename => file_name,
      :headers => {},
      :callback => url_for(:action => :httpdownload_callback)
    )
    
    file_name
  end
  
  #getting image list from Sinatra RESTful server
  def get_image_list(accno)
    get_config
    
    request="http://#{@ip}:#{@port}/GetImageListByAccessionNO/#{accno}"
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

    @imagelist.length.times do |index|
      if index==0
        @image=get_image(@imagelist,0)
      else
        get_image(@imagelist,index)
      end
    end
    
    @index=0
  end
  
  #to do image list and image
  def do_image
    set_login_menu
        
    @accno=@params['accno'].gsub('{','').gsub('}','')
    get_image_list(@accno)
    get_image(@imagelist,@index)
    
    render :action => :image
  end
  
  #getting report data from Sinatra RESTful server
  def get_report(accno)
    get_config    
    
    request="http://#{@ip}:#{@port}/OpenReportByAccessionNO/#{accno}"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    @report = Rho::JSON.parse(res["body"].gsub('\\\r\\\n','<br>'))
  end
  
  #to do report data
  def do_report
    set_login_menu

    @accno=@params['accno'].gsub('{','').gsub('}','')
    get_report(@accno)
        
    render :action => :report
  end
  
  #getting elink from Sinatra RESTful server
  def get_elink_byaccno
    set_home_menu
    get_config
    
    accno=@params['accno']        
    request="http://#{@ip}:#{@port}/QueryByAccessionNO/#{accno}"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    @elinks = Rho::JSON.parse(res["body"])
     
    render :action => :home
  end
  
  #getting elink from Sinatra RESTful server
  def get_elink_bychartno
    set_home_menu
    get_config
    
    chartno=@params['chartno']        
    request="http://#{@ip}:#{@port}/QueryByChartNO/#{chartno}"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    @elinks = Rho::JSON.parse(res["body"])
     
    render :action => :home
  end
  
  #getting elink from Sinatra RESTful server
  def get_elink_bydate
    set_home_menu
    get_config
    
    date=@params['date']        
    request="http://#{@ip}:#{@port}/QueryByExamDate/#{date}"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    @elinks = Rho::JSON.parse(res["body"])
     
    render :action => :home
  end
  
  #getting elink from Sinatra RESTful server
  def get_elink_today
    set_home_menu
    get_config
    
    #request="http://#{@ip}:#{@port}/QueryByAccessionNO/A11R4C02738"
    #request="http://#{@ip}:#{@port}/QueryByChartNO/8006154"
    #request="http://#{@ip}:#{@port}/QueryByExamDate/2012/10/25"
    #request="http://#{@ip}:#{@port}/test"
    dt=Time.now().strftime("%Y/%m/%d")
    request="http://#{@ip}:#{@port}/QueryByExamDate/#{dt}"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    @elinks = Rho::JSON.parse(res["body"])
    
    render :action => :home
  end
  
  #login user information verify
  def do_login
    get_config
    
    @id=@params['id']
    @password=@params['password']
    @id='nil' if @id==''
    @password='nil' if @password==''
      
    request="http://#{@ip}:#{@port}/GetUserVerifyResult/#{@id}/#{@password}"
    res = Rho::AsyncHttp.get(
      :url => request
    )
    
    if res["body"].to_s()=="true"
      get_elink_today
    else
      render :action => :verify_faild
    end
  end
  
  #setting Query menu in Home
  def set_home_menu
    @menu={
      "Query By Date" => Rho::RhoConfig.options_path+'/qbydate',
      "Query By Chartno" => Rho::RhoConfig.options_path+'/qbychartno',
      "Query By Accessionno" => Rho::RhoConfig.options_path+'/qbyaccno',
      "登出" => Rho::RhoConfig.start_path,
      "重新整理" => :refresh, 
      "關閉系統" => :close,
      "除錯" => :log
    }
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
  
  #go to config page and get the saved config
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
  
  #to do saved config
  def do_config
    set_config
    
    render :action => :verify_success
  end
  
  #setting config to file
  def set_config
    @ip=@params['ip']
    @port=@params['port']
      
    path_to_prop=Rho::RhoApplication::get_blob_path('/')+'config.propertories'
        
    fout=File.open(path_to_prop,'w')
    fout.write("#{@ip}:#{@port}")
    fout.close
  end
end
