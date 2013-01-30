require 'em-websocket'

module WebSocketServer

  def init_websocket_server
    EM::WebSocket.run(:host => "0.0.0.0", :port => 8090) do |ws|
      ws.onopen { |handshake|
        @connected_websockets[ws] = Time.now
        puts "WS: Connection open"

        # Access properties on the EM::WebSocket::Handshake object, e.g.
        # path, query_string, origin, headers

        # Publish message to the client
        # ws.send "WS: Hello Client, you connected from #{handshake.origin}"
        # ws.send "WS: Connected clients: #{@connected_websockets}"
      }

      ws.onclose {
        puts "WS: Connection closed"
        @connected_websockets.delete(ws)
      }

      ws.onmessage { |msg|
        # puts "WS: Recieved message: #{msg}"
        handle_incoming_websocket_message(msg,ws)
      }
    end
  end

  def send_to_connected_websockets(msg)
    @connected_websockets.each do |websocket,websocket_attr|
      # puts "Sending message to websocket client: #{msg}"
      websocket.send(msg)
    end
  end

end