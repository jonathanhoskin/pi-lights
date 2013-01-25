require 'json'

module MessageHandler
  def handle_websocket_message(messsage,websocket)
    data = JSON.parse(messsage)

    
  end
end