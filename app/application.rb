require 'rho/rhoapplication'

class AppApplication < Rho::RhoApplication
  def initialize
    # Tab items are loaded left->right, @tabs[0] is leftmost tab in the tab-bar
    # Super must be called *after* settings @tabs!
    @tabs = nil
    #To remove default toolbar uncomment next line:
    @@toolbar = nil
    #setting default menu list
    @default_menu = {
      "回首頁" => Rho::RhoConfig.start_path,
      "設定" => Rho::RhoConfig.options_path+'/go_config',
      "重新整理" => :refresh,
      "關閉系統" => :close,
      "除錯" => :log
    }
    super

    # Uncomment to set sync notification callback to /app/Settings/sync_notify.
    # SyncEngine::set_objectnotify_url("/app/Settings/sync_notify")
    SyncEngine.set_notification(-1, "/app/Settings/sync_notify", '')
  end
end
