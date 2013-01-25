require 'em-websocket'

module WebSocketServer

  def init_websocket_server
    EM::WebSocket.run(:host => "0.0.0.0", :port => 8090) do |ws|
      @connected_websockets[Time.now] = ws

      ws.onopen { |handshake|
        puts "WS: WebSocket connection open"

        # Access properties on the EM::WebSocket::Handshake object, e.g.
        # path, query_string, origin, headers

        # Publish message to the client
        ws.send "WS: Hello Client, you connected from #{handshake.origin}"
        ws.send "WS: Connected clients: @connected_websockets"
      }

      ws.onclose {
        puts "WS: Connection closed"
      }

      ws.onmessage { |msg|
        puts "WS: Recieved message: #{msg}"
        handle_websocket_message(msg,ws)
      }
    end
  end

end