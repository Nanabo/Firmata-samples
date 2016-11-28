var gamepad = require('gamepad');
var childProcess = require('child_process');

// rubyのnanabo APIを子プロセスとして呼び出す
var impl = childProcess.spawn('ruby', ['impl.rb', process.argv[2]], { stdio: ['pipe', 'inherit', 'inherit']});

// 各ボタンのバッファクラス
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

// シフトA（△ボタン）、シフトB（□ボタン）が押された場合に十字キーの動作を変えるためのクラス
function ShiftController(state_num, io) {
  this.io = io;
  this.state_num = state_num;
  this.states = new Array(state_num);
}
ShiftController.prototype.shift = function(index) {
  if(index >= 0 && index <= this.state_num){
    this.states[index] = 1;
  }
}
ShiftController.prototype.unshift = function(index) {
  if(index >= 0 && index <= this.state_num){
    this.states[index] = 0;
  }
}
ShiftController.prototype.state = function() {
  for(var i=this.state_num-1; i>=0; i--){
    if(this.states[i] == 1){
      return Math.pow(2,i);
    }
  }
  return 0;
}
ShiftController.prototype.cursor_up = function() {
  switch(this.state()){
    case 0:
      this.io.write("Elevate\n");
      break;
    case 1:
      this.io.write("Grip\n");
      break;
    case 2:
      this.io.write("PitchDown\n");
      break;
  }
}
ShiftController.prototype.cursor_down = function() {
  switch(this.state()){
    case 0:
      this.io.write("Unelevate\n");
      break;
    case 1:
      this.io.write("Ungrip\n");
      break;
    case 2:
      this.io.write("PitchUp\n");
      break;
  }
}
ShiftController.prototype.cursor_left = function() {
  switch(this.state()){
    case 0:
      this.io.write("TurnLeft\n");
      break;
    case 1:
      this.io.write("M3Left\n");
      break;
    case 2:
      this.io.write("M5Left\n");
      break;
  }
}
ShiftController.prototype.cursor_right = function() {
  switch(this.state()){
    case 0:
      this.io.write("TurnRight\n");
      break;
    case 1:
      this.io.write("M3Right\n");
      break;
    case 2:
      this.io.write("M5Right\n");
      break;
  }
}

// シフト系動作の実実装
var sc = new ShiftController(2, impl.stdin);

// 方向キー動作バッファ
var CursorUpCounter = new Counter(100, function(){ sc.cursor_up(); });
var CursorDownCounter = new Counter(100, function(){ sc.cursor_down(); });
var CursorRightCounter = new Counter(100, function(){ sc.cursor_right(); });
var CursorLeftCounter = new Counter(100, function(){ sc.cursor_left(); });

// その他キー動作バッファ（△、□を除く）
var SuckCounter = new Counter(600000, function(){ impl.stdin.write("Suck\n"); });
var ReleaseCounter = new Counter(600000, function(){ impl.stdin.write("Release\n"); });
var LengthUpCounter = new Counter(200, function(){ impl.stdin.write("LengthUp\n"); });
var LengthDownCounter = new Counter(200, function(){ impl.stdin.write("LengthDown\n"); });
var SpeedUpCounter = new Counter(250, function(){ impl.stdin.write("SpeedUp\n"); });
var SpeedDownCounter = new Counter(250, function(){ impl.stdin.write("SpeedDown\n"); });
var InfoCounter = new Counter(600000, function(){ impl.stdin.write("InfoOut\n"); });


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
  InfoCounter,
  null,
  null
];

gamepad.init()

setInterval(gamepad.processEvents, 5);
setInterval(gamepad.detectDevices, 1000);

gamepad.on("move", function(id, axis, value){
  if(axis == 4){
    if(value == 1){
      CursorUpCounter.start();
      CursorDownCounter.stop();
    }else if(value == -1){
      CursorDownCounter.start();
      CursorUpCounter.stop();
    }else{
      CursorUpCounter.stop();
      CursorDownCounter.stop();
    }
  }else if(axis == 5){
    if(value == -1){
      CursorLeftCounter.start();
      CursorRightCounter.stop();
    }else if(value == 1){
      CursorRightCounter.start();
      CursorLeftCounter.stop();
    }else{
      CursorRightCounter.stop();
      CursorLeftCounter.stop();
    }
  }
});

gamepad.on("up", function(id, num){
  var b = Buttons[num];
  if(b){
    b.stop();
  }else{
    if(num == 0){
      sc.unshift(0);
    }else if(num == 3){
      sc.unshift(1);
    }
  }
});

gamepad.on("down", function(id, num){
  var b = Buttons[num];
  if(b){
    b.start();
  }else{
    if(num == 0){
      sc.shift(0);
    }else if(num == 3){
      sc.shift(1);
    }
  }
});

