EM.epoll
EM.run do
    trap("TERM") { stop }
    trap("INT")  { stop }

    @name = "rubyclient"
    @room = "home"
    @host = "ws://54.245.111.204:8882/#{@name}/#{@room}"

    @connected = false

    @ws = WebSocket::EventMachine::Client.connect(:uri => @host)

    @ws.onopen do
        puts "Connected"
        @connect = true
    end

    def send_msg( name, type, value )
        msg = { :clientName => @name, :name => name, :type => type, :value =>value }
        @ws.send( { :message => { :message => msg } }.to_json )
    end

    @ws.onmessage do |msg, type|
        puts "Received message: #{msg}"
    end

    @ws.onclose do
        @connected = false
        puts "Disconnected"
    end

end