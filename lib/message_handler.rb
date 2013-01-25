require 'json'

module MessageHandler
  def handle_websocket_message(messsage,websocket)
    data = JSON.parse(messsage)
    puts data
  end
end