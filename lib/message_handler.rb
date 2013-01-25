require 'json'

module MessageHandler
  def handle_websocket_message(msg,ws)
    data = JSON.parse(msg)
    puts "Data: #{data}"
    handle_on_data(data,ws) if data["on"]
    handle_off_data(data,ws) if data["off"]
    handle_status_data(data,ws) if data["status"]
  end

  def handle_on_data(data,ws)
    puts "Data in handle ON: #{data}"
    turn_all_on if data["on"] == "all"
    data["on"].each { |output| turn_on_output(output) } unless data["on"] == "all"
    ws.send "Turned On"
  end

  def handle_off_data(data,ws)
    puts "Data in handle OFF: #{data}"
    turn_all_on if data["off"] == "all"
    data["off"].each { |output| turn_off_output(output) } unless data["off"] == "all"
    ws.send "Turned Off"
  end

  def handle_status_data(data,ws)
    ws.send "Status"
  end
end