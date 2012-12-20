require 'sinatra'
require 'em-websocket'

EventMachine.run {


    @channels = Hash.new{ |h,k| h[k] = { :channel => EM::Channel.new, :players => {} } }
    @data_resp = false

    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8882) do |ws|
        """
            check response from deliberate ping/pong
        """
        # def check_response(conn)
        #     if @data_resp == false
        #         puts "ping/ponged out"
        #         conn.close_connection
        #     end
        # end

        ws.onopen {
            puts "open"
            room = ws.request["path"].split("/")[1]
            if room
                sid = @channels[room][:channel].subscribe{ |msg| ws.send msg }
                @channels[room][:players][sid] = sid
                data = { :type => "welcome", :data => sid, :players => @channels[room][:players] }.to_json
                ws.send data
            else
                puts "probably close this or something..."
            end

            """
                this can be used to create a more robust ping/pong check for clients
            """
            # timer = EM.add_periodic_timer(20) {
            #     @data_resp = false
            #     data = { :type => "ping" }.to_json
            #     ws.send data
            #     EM.add_timer(2) do
            #         check_response(ws)
            #     end
            # }

            ws.onclose {
                puts "close"
                # DESTROY THEM!!!!
                @channels[room][:channel].unsubscribe(sid)
                @channels[room][:players].delete(sid)
                data = { :type => "leave", :data => sid }.to_json
                @channels[room][:channel].push data
            }

            ws.onmessage { |msg|
                puts msg
                begin
                    message = JSON.parse( msg )
                    @channels[room][:channel].push msg
                rescue Exception => e
                    puts "not JSON?"
                    puts e
                end
            }
        }
    end
}