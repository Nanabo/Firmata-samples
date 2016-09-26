# coding: utf-8
# GUI(Electron/Node.js)による操作

require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'

# 親プロセスからコマンドを読み取り、そのコマンドに応じた処理をnanaboにさせるプロキシクラス
class NanaboProxy
  def initialize
    @nanabo = Nanabo.new("COM7")
    @nanabo.offsets = [0, 0, 0, 0, 0, 0]
    @arm_length = 20.0
    @elevation_angle = 30.0 
  end
  
  def initial_move
    @nanabo.speed = 100
    @nanabo.move
    sleep(1)
    
    @nanabo.set_default_arm(@arm_length, @elevation_angle.to_i)
    @nanabo.move
    sleep(2)
  end
  
  def read
    commands = []
    loop do
      str = STDIN.gets
      break unless str
      commands << str.chomp
    end
    commands
  end
  
  def execute(command)
    case command
    when "TurnLeft"
      a = @nanabo.servos[0].current_angle
      b = [a+1, 180].min
     @nanabo.servos[0].target_angle = b
    when "TurnRight"
      a = @nanabo.servos[0].current_angle
      b = [a-1, 0].max
      @nanabo.servos[0].target_angle = b
    when "Elevate"
      a = @elevation_angle
      b = [a+1, 90].min
      @elevation_angle = b
      @nanabo.set_default_arm(arm_length, elevation_angle.to_i)
    when "Unelevate"
      a = @elevation_angle
      b = [a-1, -30].max
      @elevation_angle = b
      @nanabo.set_default_arm(arm_length, elevation_angle.to_i)
    when "Suck"
      p "start Suck"
      @nanabo.vacuum.suck
    when "Release"
      p "start Release"
      @nanabo.vacuum.release
    when "LengthUp"
      a = @arm_length
      b = [a+0.33, 30].min
      @arm_length = b
      @nanabo.set_default_arm(arm_length, elevation_angle.to_i)
    when "LengthDown"
      a = @arm_length
      b = [a-0.33, 10].max
      @arm_length = b
      @nanabo.set_default_arm(arm_length, elevation_angle.to_i)
    when "M3Left"
      a = @nanabo.servos[3].current_angle
      b = [a+1, 180].min
      @nanabo.servos[3].target_angle = b
    when "M3Right"
      a = @nanabo.servos[3].current_angle
      b = [a-1, 0].max
      @nanabo.servos[3].target_angle = b
    when "M5Left"
      a = @nanabo.servos[5].current_angle
      b = [a+1, 180].min
      @nanabo.servos[5].target_angle = b
    when "M5Right"
      a = @nanabo.servos[5].current_angle
      b = [a-1, 0].max
      @nanabo.servos[5].target_angle = b
    when "PitchUp"
      a = @nanabo.pitch_angle
      b = [a-1, -90].max
      @nanabo.pitch_angle = b
    when "PitchDown"
      a = @nanabo.pitch_angle
      b = [a+1, 90].min
      @nanabo.pitch_angle = b
    end
  end
  
  def move
    @nanabo.move
  end
end


# ここからメイン処理

pr = NanaboProxy.new
pr.initial_move

loop do
  commands = pr.read
  commands.each do |c|
    pr.execute(c)
  end
  pr.move
  sleep(0.01)
end

