var kraken;
$(document).ready(function() {

    kraken = new KrakenJS( window, {
        username: "receiver",
        roomname: "compass_demo",
        host: "54.245.111.204",
        //host: "localhost",
        port: "8882",
        secure: false,
        debug: false
    });

    /*
        register events, it'll validate the data type
    */

    // you can expect a string
    kraken.addEvent("compass","object",function(msg){
            data.rotation.alpha = Math.floor(msg.a),
            data.rotation.beta = Math.floor(msg.b),
            data.rotation.gamma = Math.floor(msg.g);
    });

    kraken.addEvent("accelerometer","object",function(msg){
        //console.log( msg );
        data.acceleration.x = msg.x,
        data.acceleration.y = msg.y,
        data.acceleration.z = msg.z
    });

    kraken.connect();


    function e() {
        //data.acceleration.x = event.acceleration.x,
        //data.acceleration.y = event.acceleration.y,
        //data.acceleration.z = event.acceleration.z
    }
    touchObj = {
        isTouch: !1,
        lockRotPosition: !1,
        startY: 0,
        moveY: 0,
        knobRot: 0,
        currKnobRot: 0,
        on: !1,
        ready: !1
    }, down = "createTouch" in document ? "touchstart" : "mousedown", up = "createTouch" in document ? "touchend" : "mouseup", move = "createTouch" in document ? "touchmove" : "mousemove", playBtn = document.querySelector("#play"), knob = document.querySelector(".knob-ctrl"), hasMotion = "DeviceMotionEvent" in window, data = {
        rotation: {
            alpha: 0,
            beta: 0,
            gamma: 0
        },
        acceleration: {
            x: 0,
            y: 0,
            z: 0
        },
        noGravity: {
            x: 0,
            y: 0,
            z: 0
        }
    }, ondown = function () {
        var e = 0,
            t = ["start", "stop"];
        return function () {
            dmaf.tell(t[e ? e-- : e++]), t[e] == "start" ? ($(".knob-play").css("display", "block"), $(".knob-pause").css("display", "none")) : ($(".knob-play").css("display", "none"), $(".knob-pause").css("display", "block"))
        }
    }(), document.ontouchstart = function (e) {
        touchObj.ready || e.preventDefault()
    }, window.addEventListener("load", function () {
        setTimeout(function () {
            window.scrollTo(0, 1)
        }, 0)
    }), dmaf.addEventListener("dmaf_ready", function () {
        console.log("dmaf_ready"), dmaf.registerObject("data", data), touchObj.ready = !0, $(".loading").css("display", "none"), $(".knob-bg").css("display", "block"), knob.addEventListener(down, ondown, !1)
    }), hasMotion && window.addEventListener("devicemotion", e, !1), window.addEventListener("deviceorientation", function (e) {
        if (e.webkitCompassHeading) {
            //data.rotation.alpha = Math.floor(e.alpha),
            //data.rotation.beta = Math.floor(e.beta),
            //data.rotation.gamma = Math.floor(e.gamma);
            var t = e.gamma,
                n = e.beta,
                r = e.alpha;
            //$("#deviceOrientation .constantRow").html("<td>" + Math.round(t) + "</td><td>" + Math.round(n) + "</td><td>" + Math.round(r) + "</td><td>" + Math.round(e.webkitCompassHeading) + "</td>")
        }
    }, !1), dmaf.init()
//})(), define("main", function () {});
});