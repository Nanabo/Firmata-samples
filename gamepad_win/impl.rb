# coding: utf-8
# GUI(Electron/Node.js)‚É‚æ‚é‘€ì

require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'

nanabo = Nanabo.new("COM7")

nanabo.offsets = [0, 0, 0, 0, 0, 0]

nanabo.speed = 100
nanabo.move
sleep(1)

nanabo.set_default_arm(20.0, 30)
nanabo.move
sleep(2)
arm_length = 20.0
elevation_angle = 30.0

loop do
  command = gets.chomp
  next unless command
  p command
  case command
  when "TurnLeft"
    a = nanabo.servos[0].current_angle
    b = [a+5, 180].min
    p "start turnLeft: %d=>%d"%[a, b]
    nanabo.servos[0].target_angle = b
  when "TurnRight"
    a = nanabo.servos[0].current_angle
    b = [a-5, 0].max
    p "start turnRight: %d=>%d"%[a, b]
    nanabo.servos[0].target_angle = b
  when "Elevate"
    a = elevation_angle
    b = [a+2.5, 90].min
    p "start Elevate: %.1f=>%.1f"%[a, b]
    elevation_angle = b
    nanabo.set_default_arm(arm_length, elevation_angle.to_i)
  when "Unelevate"
    a = elevation_angle
    b = [a-2.5, -30].max
    p "start Unelevate: %.1f=>%.1f"%[a, b]
    elevation_angle = b
    nanabo.set_default_arm(arm_length, elevation_angle.to_i)
  when "Suck"
    p "start Suck"
    nanabo.vacuum.suck
  when "Release"
    p "start Release"
    nanabo.vacuum.release
  when "LengthUp"
    a = arm_length
    b = [a+1, 30].min
    p "start lengthUp: %d=>%d"%[a, b]
    arm_length = b
    nanabo.set_default_arm(arm_length, elevation_angle.to_i)
  when "LengthDown"
    a = arm_length
    b = [a-1, 10].max
    p "start lengthDown: %d=>%d"%[a, b]
    arm_length = b
    nanabo.set_default_arm(arm_length, elevation_angle.to_i)
  when "SpeedUp"
    s = nanabo.speed
    t = [s*1.5, 1000].min.to_i
    p "start SpeedUp: %d=>%d"%[s, t]
    nanabo.speed = t
  when "SpeedDown"
    s = nanabo.speed
    t = [s/1.5, 25].max.to_i
    p "start SpeedUp: %d=>%d"%[s, t]
    nanabo.speed = t
  end
  nanabo.move
  command = ""
  STDIN.flush
  sleep(0.01)
end
