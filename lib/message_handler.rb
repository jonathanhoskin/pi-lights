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

    data["on"].each do |output|
      @manual_override_outputs << output
      turn_output_on(output)
      ws.send({:output => [{output => :on}]}.to_json)
    end
  end

  def handle_off_data(data,ws)
    puts "Data in handle OFF: #{data}"

    data["off"].each do |output|
      @manual_override_outputs.delete(output)
      turn_output_off(output)
      ws.send({:output => [{output => :off}]}.to_json)
    end

    ws.send "Turned Off"
  end

  def handle_status_data(data,ws)
    ws.send "Status"
  end
end