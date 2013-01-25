require 'em-websocket'

module WebSocketServer

  def init_websocket_server
    EM::WebSocket.run(:host => "0.0.0.0", :port => 8090) do |ws|
      ws.onopen { |handshake|
        puts "WS: WebSocket connection open"

        # Access properties on the EM::WebSocket::Handshake object, e.g.
        # path, query_string, origin, headers

        # Publish message to the client
        ws.send "WS: Hello Client, you connected to #{handshake.path}"
      }

      ws.onclose {
        puts "WS: Connection closed"
      }

      ws.onmessage { |msg|
        puts "WS: Recieved message: #{msg}"
        eval(msg) if self.respond_to?(msg)
      }
    end
  end

end