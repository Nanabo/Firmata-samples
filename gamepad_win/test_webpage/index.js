function buttonPressed(b, val) {
  if (typeof(b) == "object") {
    return b.pressed;
  }
  return b == val;
}


// fpsƒJƒEƒ“ƒ^
function FpsCounter(fps) {
  this.fps = fps;
  this.count = 0;
}
FpsCounter.prototype.process = function(button, opt_val) {
  var val = opt_val === undefined? 1.0 : opt_val;
  if(buttonPressed(button, val)){
    return this.update();
  }else{
    this.reset();
    return false;
  }
}
FpsCounter.prototype.update = function(){
  if(this.count == 0){
    this.count += 1;
    return true;
  }
  this.count += 1;
  if(this.fps > 0 && this.count >= this.fps){
    this.count = 0;
  }
  return false;
}
FpsCounter.prototype.reset = function(){
  this.count = 0;
}

var start;

var SuckCounter = new FpsCounter(-1);
var ReleaseCounter = new FpsCounter(-1);
var SpeedUpCounter = new FpsCounter(15);
var SpeedDownCounter = new FpsCounter(15);
var LengthUpCounter = new FpsCounter(15);
var LengthDownCounter = new FpsCounter(15);
var TurnRightCounter = new FpsCounter(15);
var TurnLeftCounter = new FpsCounter(15);
var ElevateCounter = new FpsCounter(15);
var UnelevateCounter = new FpsCounter(15);


window.addEventListener("gamepadconnected", function(e) {
  console.log("Gamepad connected at index %d: %s. %d buttons, %d axes.",
    e.gamepad.index, e.gamepad.id,
    e.gamepad.buttons.length, e.gamepad.axes.length);
    
  gameLoop();
});

window.addEventListener("gamepaddisconnected", function(e) {
  console.log("Gamepad disconnected from index %d: %s",
    e.gamepad.index, e.gamepad.id);
    cancelRequestAnimationFrame(start);
});

function gameLoop() {
  var gamepads = navigator.getGamepads ? navigator.getGamepads() : (navigator.webkitGetGamepads ? navigator.webkitGetGamepads : []);
  if (!gamepads) {
    return;
  }
  var gp = gamepads[0];
  if(SuckCounter.process(gp.buttons[1])){
    console.log("Suck button");
  }else if(ReleaseCounter.process(gp.buttons[2])){
    console.log("Release button");
  }
  if(SpeedDownCounter.process(gp.buttons[4])){
    console.log("Speed Down button");
  }else if(SpeedUpCounter.process(gp.buttons[5])){
    console.log("Speed Up button");
  }
  if(LengthDownCounter.process(gp.buttons[6])){
    console.log("Length Down button");
  }else if(LengthUpCounter.process(gp.buttons[7])){
    console.log("Length Up button");
  }
  
  if(TurnRightCounter.process(gp.axes[0], 1)){
    console.log("Turn Right");
  }else if(TurnLeftCounter.process(gp.axes[0], -1)){
    console.log("Turn Left");
  }
  if(UnelevateCounter.process(gp.axes[1], 1)){
    console.log("Unelevate");
  }else if(ElevateCounter.process(gp.axes[1], -1)){
    console.log("Elelevate");
  }
  
  start = requestAnimationFrame(gameLoop);
}

