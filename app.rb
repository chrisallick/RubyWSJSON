#require 'sinatra'
require 'em-websocket'
require 'redis'

$redis = Redis.new

class Helpers
    @@S3_KEY='AKIAIONDHVBZ6Z4CP75A'
    @@S3_SECRET='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'

    def self.s3_upload(img_data, bucket, extension, uuid)
        name = uuid + extension

        connection = Fog::Storage.new(
            :provider                 => 'AWS',
            :aws_secret_access_key    => @@S3_SECRET,
            :aws_access_key_id        => @@S3_KEY
        )

        directory = connection.directories.create(
            :key    => bucket,
            :public => true
        )
    
        content_type = case extension
        when ".gif"
            "image/gif"
        when ".png"
            "image/png"
        when ".jpeg" || ".jpg"
            "image/jpeg"
        else
            ""
        end

        file = directory.files.create(
            :key    => name,
            :body   => img_data,
            :content_type => content_type,
            :public => true
        )
    
        if extension == ".gif"
            return "https://s3.amazonaws.com/"+bucket+"/"+name
        else
            return "http://trash.imgix.net/#{name}"
        end
    end
end

EventMachine.run {
    @S3_BUCKET='trash-images'
    @allowed_video_upload_formats = [".png", ".gif", ".jpeg", ".jpg"]
    @channels = Hash.new{ |h,k| h[k] = { :channel => EM::Channel.new, :players => {} } }
    @data_resp = false

    def self.process_msg(msg)
        justurl = true
        if msg["type"] == "chat"
            if msg["msg"] =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
                str = open(msg["msg"])
                if ["image/jpg", "image/gif", "image/jpeg", "image/png"].include? str.content_type
                    s3_url = Helpers.s3_upload( open(msg["msg"]).read, "trash-images", "."+str.content_type.split("/")[1], UUIDTools::UUID.random_create.to_s )
                    msg["msg"] = s3_url
                    msg["type"] = "image"
                    $redis.lpush("stream:#{msg["room"]}",msg.to_json)
                    $redis.ltrim("stream:#{msg["room"]}", 0, 39)

                    @channels[msg["room"]][:channel].push msg.to_json
                    justurl = false
                end
            end

            if justurl
                $redis.lpush("chat:#{msg["room"]}",msg.to_json)
                $redis.ltrim("chat:#{msg["room"]}", 0, 99)

                @channels[msg["room"]][:channel].push msg.to_json
            end
        # elsif msg["type"] == "register"
        #     @channels[msg["room"]][:clients][msg["msg"]] = msg["username"]
        #     msg["msg"] = @channels[msg["room"]][:clients]

        #     @channels[msg["room"]][:channel].push msg.to_json
        # elsif msg["type"] == "pong"
        #     @data_resp = true
        end
    end

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