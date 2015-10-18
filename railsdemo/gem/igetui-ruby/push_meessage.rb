class PushMessageToList < GetuiService
  attr_accessor :text, :title, :client_ids

  def initialize(args = {})
    super
    @title = args.delete(:title)
    @text = args.delete(:text)
    @client_ids = args.delete(:client_ids)
  end

  # return example
  #   {
  #     "result" => "ok",
  #     "details" => {
  #       "112fdb5117781873febb5d8a1f28794f" => "successed_online"
  #     },
  #     "contentId" => "OSL-0803_U8fyEKRLWr6l0ILiLNfxe5"
  #   }
  def execute
    fail InvalidError.new(caused_by: 'Title') if @title.nil?
    fail InvalidError.new(caused_by: 'client_ids') if @client_ids.nil?

    template = IGeTui::NotificationTemplate.new
    template.title = @title
    template.text = @text

    list_message = IGeTui::ListMessage.new
    list_message.data = template

    client_list = []
    client_ids = @client_ids
    client_ids.each do |client_id|
      client_list << IGeTui::Client.new(client_id)
    end

    begin
      content_id = @pusher.get_content_id(list_message)
      @pusher.push_message_to_list(content_id, client_list)
    rescue => e
      return e
    end
  end
end

# 创建一条透传消息
template = IGeTui::TransmissionTemplate.new
# Notice: content should be string.
content = {
  action: 'notification',
  title: '标题aaa',
  content: '内容',
  type: 'article',
  id: '4274'
}
content = content.to_s.delete(':').gsub('=>', ':')
template.transmission_content = content
# 设置iOS的推送参数，如果只有安卓 App，可以忽略下面一行
# template.set_push_info("", 1, "这里是iOS推送的显示信息", "")

# 创建群发消息
list_message = IGeTui::ListMessage.new
list_message.data = template

# 创建客户端对象
client_1 = IGeTui::Client.new(your_client_id_1)
client_2 = IGeTui::Client.new(your_client_id_2)
client_list = [client_1, client_2]

content_id = pusher.get_content_id(list_message)
ret = pusher.push_message_to_list(content_id, client_list)

class PushSingleMessage < GetuiService
  attr_accessor :text, :title, :client_id

  def initialize(args = {})
    super
    @title = args.delete(:title)
    @text = args.delete(:text)
    @client_id = args.delete(:client_id)
  end

  # return example
  #    {
  #      "taskId" => "OSS-0803_pDKsoDFtXZ67OP2lzimeQ3",
  #      "result" => "ok",
  #      "status" => "successed_online"
  #    }
  def execute
    fail InvalidError.new(caused_by: 'Title') if @title.nil?
    fail InvalidError.new(caused_by: 'client_id') if @client_id.nil?

    template = IGeTui::NotificationTemplate.new
    template.title = @title
    template.text = @text

    single_message = IGeTui::SingleMessage.new
    single_message.data = template
    client = IGeTui::Client.new(@client_id)
    begin
      @pusher.push_message_to_single(single_message, client)
    rescue => e
      return e
    end
  end
end
