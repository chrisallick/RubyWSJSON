#!/usr/bin/env ruby

require 'sinatra'
require 'em-websocket'

EventMachine.run {
    @channels = Hash.new{ |h,k| h[k] = { :channel => EM::Channel.new, :players => {} } }

    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8882) do |socket|
        sid = nil
        roomname = nil
        username = nil


        socket.onopen {
            roomname = socket.request["path"].split("/")[1]
            username = socket.request["path"].split("/")[2]
            if roomname and username
                sid = @channels[roomname][:channel].subscribe{ |msg| socket.send msg }
                @channels[roomname][:players][sid] = username

                puts "open: username:#{username}, roomname:#{roomname}, sid:#{sid}"

                data = { :type => "welcome", :data => sid, :players => @channels[roomname][:players] }.to_json
                socket.send data
            else
               socket.close_connection
            end
        }

        socket.onclose {
            @channels[roomname][:channel].unsubscribe(sid)
            @channels[roomname][:players].delete(sid)

            puts "close: username:#{username}, roomname:#{roomname}, sid:#{sid}"

            data = { :type => "leave", :players => @channels[roomname][:players], :data => sid }.to_json
            @channels[roomname][:channel].push data
        }

        socket.onmessage { |msg|
            puts msg
            begin
                message = JSON.parse( msg )
                @channels[roomname][:channel].push msg
            rescue Exception => e
                puts "not JSON?"
                puts e
            end
        }
    end
}