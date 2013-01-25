require 'json'

module MessageHandler
  def handle_websocket_message(messsage,websocket)
    data = JSON.parse(messsage)
    handle_on_message(messsage) if data[:on]
    handle_off_message(messsage) if data[:off]
    handle_status_message(messsage) if data[:status]
  end

  def handle_on_message(messsage)
    turn_all_on if messsage[:on] == "all"
    messsage[:on].each { |output| turn_on_output(output) }
  end

  def handle_off_message(messsage)
    turn_all_on if messsage[:off] == "all"
    messsage[:off].each { |output| turn_off_output(output) }  
  end

  def handle_status_message(messsage)

  end
end