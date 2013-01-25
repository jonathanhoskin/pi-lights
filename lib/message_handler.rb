require 'json'

module MessageHandler
  def handle_websocket_message(messsage,websocket)
    data = JSON.parse(messsage)
    puts "Data: #{data}"
    handle_on_data(data) if data["on"]
    handle_off_data(data) if data["off"]
    handle_status_data(data) if data["status"]
  end

  def handle_on_data(data,websocket)
    puts "Data in handle ON: #{data}"
    turn_all_on if data["on"] == "all"
    data["on"].each { |output| turn_on_output(output) }
    websocket.send "Turned On"
  end

  def handle_off_data(data,websocket)
    puts "Data in handle OFF: #{data}"
    turn_all_on if data["off"] == "all"
    data["off"].each { |output| turn_off_output(output) }
    websocket.send "Turned Off"
  end

  def handle_status_data(data,websocket)
    websocket.send "Status"
  end
end