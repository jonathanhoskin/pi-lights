require 'json'

module MessageHandler
  def handle_incoming_websocket_message(msg,ws)
    data = JSON.parse(msg)
    puts "Data: #{data}"
    handle_incoming_on_data(data,ws) if data["on"]
    handle_incoming_off_data(data,ws) if data["off"]
    handle_incoming_status_request(ws) if data["status"]
  end

  def handle_incoming_on_data(data)
    puts "Data in handle ON: #{data}"

    data["on"].each do |output|
      add_manual_override(output)
      turn_output_on(output)
    end
  end

  def handle_incoming_off_data(data)
    puts "Data in handle OFF: #{data}"

    data["off"].each do |output|
      delete_manual_override(output)
      turn_output_off(output)
    end
  end

  def handle_incoming_status_request(ws)
    ws.send(all_sensor_pin_states.merge(all_output_pin_states).to_json)
  end

  def send_change_to_websockets(key,pin,state)
    msg = {key => {pin => state}}.to_json
    send_to_connected_websockets(msg)
  end
end