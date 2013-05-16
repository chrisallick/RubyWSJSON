var client;
$(document).ready(function(){
	client = new Client( window, {
		username: "client",
		roomname: "home",
		host: "54.245.111.204",
		//host: "localhost",
		port: "8882",
		secure: false
	});

	/*
		register events, it'll validate the data type
	*/

	// you can expect a string
	client.addEvent("string_msg","string",function(msg){
		console.log( msg );
	});

	// you can expect a json object
	client.addEvent("object_msg","object",function(msg){
		console.log( msg );
	});

	// you can expect a number
	client.addEvent("number_msg","number",function(msg){
		console.log( msg );
	});

	// you can expect anything!
	client.addEvent("any_msg","any",function(msg){
		console.log( msg );
	});

	client.connect();
});