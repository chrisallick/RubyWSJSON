require 'sinatra'
require 'em-websocket'

EventMachine.run {


    #@channels = Hash.new{ |h,k| h[k] = { :channel => EM::Channel.new, :players => {} } }
    @sockets = []
    @channel = EM::Channel.new

    #@data_resp = false

    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8882) do |socket|
        socket.onopen {
            puts "open"
            @sockets << socket
            sid = @channel.subscribe{ |msg| socket.send msg }
            socket.send "welcome,#{sid}"
            if @sockets.length == 2
                @channel.push "start"
            end
        }

        socket.onclose {
            puts "close"
            @sockets.delete( socket )
        }

        socket.onmessage { |msg|
            #puts msg
            begin
                #message = JSON.parse( msg )
                @sockets.each do |s|
                    if s == socket
                        #pass
                    else
                        s.send msg
                    end
                end
            rescue Exception => e
                puts "not JSON?"
                puts e
            end
        }
    end
}