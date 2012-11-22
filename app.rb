require 'sinatra'
require 'em-websocket'

EventMachine.run {


    @channels = Hash.new{ |h,k| h[k] = { :channel => EM::Channel.new, :players => {} } }
    @data_resp = false

    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8881) do |ws|
        def check_response(conn)
            if @data_resp == false
                puts "ping/ponged out"
                conn.close_connection
            end
        end

        puts "sup?"

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