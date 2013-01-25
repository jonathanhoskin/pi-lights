require 'json'

module MessageHandler
  def handle_websocket_message(messsage,websocket)
    data = JSON.parse(messsage)
    puts "Data: #{data}"
    handle_on_message(data) if data[:on]
    handle_off_message(data) if data[:off]
    handle_status_message(data) if data[:status]
  end

  def handle_on_data(data)
    puts "Data in handle ON: #{data}"
    turn_all_on if data[:on] == "all"
    data[:on].each { |output| turn_on_output(output) }
  end

  def handle_off_message(data)
    puts "Data in handle OFF: #{data}"
    turn_all_on if data[:off] == "all"
    data[:off].each { |output| turn_off_output(output) }  
  end

  def handle_status_message(data)

  end
end