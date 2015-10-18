class GetuiService
  def initialize(_args = {})
    @pusher = IGeTui.pusher(app_id, app_key, master_secret)
  end
end
