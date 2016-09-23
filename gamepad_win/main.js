//var electron = require('electron');
var gamepad = require('gamepad');
var childProcess = require('child_process');

var impl = childProcess.spawn('ruby', ['impl.rb'], { stdio: ['pipe', 'inherit', 'inherit']});

function Counter(interval, callback) {
  this.interval = interval;
  this.callback = callback;
  this.id = 0;
}
Counter.prototype.start = function(){
  this.callback();
  this.id = setInterval(this.callback, this.interval);
}
Counter.prototype.stop = function(){
  if(this.id == 0){ return; }
  clearInterval(this.id);
  this.id = 0;
}

var TurnRightCounter = new Counter(400, function(){ impl.stdin.write("TurnRight\n"); });
var TurnLeftCounter = new Counter(400, function(){ impl.stdin.write("TurnLeft\n"); });
var ElevateCounter = new Counter(250, function(){ impl.stdin.write("Elevate\n"); });
var UnelevateCounter = new Counter(250, function(){ impl.stdin.write("Unelevate\n"); });
var SuckCounter = new Counter(600000, function(){ impl.stdin.write("Suck\n"); });
var ReleaseCounter = new Counter(600000, function(){ impl.stdin.write("Release\n"); });
var LengthUpCounter = new Counter(250, function(){ impl.stdin.write("LengthUp\n"); });
var LengthDownCounter = new Counter(250, function(){ impl.stdin.write("LengthDown\n"); });
var SpeedUpCounter = new Counter(250, function(){ impl.stdin.write("SpeedUp\n"); });
var SpeedDownCounter = new Counter(250, function(){ impl.stdin.write("SpeedDown\n"); });

var Buttons = [
  null,
  SuckCounter,
  ReleaseCounter,
  null,
  SpeedDownCounter,
  SpeedUpCounter,
  LengthDownCounter,
  LengthUpCounter,
  null,
  null,
  null,
  null
];

gamepad.init()

setInterval(gamepad.processEvents, 5);
setInterval(gamepad.detectDevices, 1000);

gamepad.on("move", function(id, axis, value){
  if(axis == 4){
    if(value == 1){
      ElevateCounter.start();
      UnelevateCounter.stop();
    }else if(value == -1){
      UnelevateCounter.start();
      ElevateCounter.stop();
    }else{
      ElevateCounter.stop();
      UnelevateCounter.stop();
    }
  }else if(axis == 5){
    if(value == -1){
      TurnLeftCounter.start();
      TurnRightCounter.stop();
    }else if(value == 1){
      TurnRightCounter.start();
      TurnLeftCounter.stop();
    }else{
      TurnRightCounter.stop();
      TurnLeftCounter.stop();
    }
  }
});

gamepad.on("up", function(id, num){
  var b = Buttons[num];
  if(b){
    b.stop();
  }
});

gamepad.on("down", function(id, num){
  var b = Buttons[num];
  if(b){
    b.start();
  }
});

/*
const app = electron.app;

const BrowserWindow = electron.BrowserWindow;

let mainWindow;

app.on('window-all-closed', function(){
  if (process.platform != 'darwin') {
    app.quit();
  }
});

app.on('ready', function(){
  mainWindow = new BrowserWindow({width:800, height: 600});
  mainWindow.loadURL('file://' + __dirname + '/index.html');
  
  mainWindow.on('closed', function() {
    mainWindow = null;
  });
});
*/