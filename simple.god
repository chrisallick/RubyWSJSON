working_dir = File.expand_path("../",__FILE__)

God.watch do |w|
  w.name 		= "simple"
  w.interval 	= 5.seconds
  w.dir   = working_dir
  w.start 		= "rackup"
  w.keepalive

  w.start_if do |start|
  	start.condition(:process_running) do |c|
  		c.running = false
  	end
  end
end