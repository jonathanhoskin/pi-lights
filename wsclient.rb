# require 'eventmachine'
require 'websocket-eventmachine-client'

class KeyboardHandler < EM::Connection
  include EM::Protocols::LineText2

  attr_reader :websocket

  def initialize(ws)
    @websocket = ws
  end

  def receive_line(data)
    @websocket.send(data)
  end
end


EM.run do
  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://raspberrypi.local:8090')

  ws.onopen do
    puts "Connected"
  end

  ws.onmessage do |msg, type|
    puts "Received message: #{msg}"
  end

  ws.onclose do
    puts "Disconnected"
    abort()
  end

  EM.open_keyboard(KeyboardHandler, ws)
end
