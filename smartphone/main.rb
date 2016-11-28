# coding: utf-8
# 座標系チェッカー

require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'

nanabo = Nanabo.new(ARGV[1])

nanabo.offsets = [8, 0, 0, 0, 0, 3]

nanabo.move
sleep(1)

nanabo.servos[0].target_angle = 90
nanabo.servos[1].target_angle = 75
nanabo.servos[2].target_angle = 50
nanabo.move
sleep(2)

include CoodinateSystem
loop do

  puts "x=?"
  x = gets.chomp.to_f
  puts "y=?"
  y = gets.chomp.to_f
  puts "z=?"
  z = gets.chomp.to_f
  nanabo.set_default_arm_xy(x, y, z)
  nanabo.move
  
  angle0 = nanabo.servos[0].current_angle
  angle1 = nanabo.servos[1].current_angle
  angle2 = nanabo.servos[2].current_angle
  puts "(%d, %d, %d) move finished!"%[angle0, angle1, angle2]
  
  # アーム長さと仰角を算出
  length = arm_length(angle1, angle2).round(2)
  inc_angle = included_angle(angle1, angle2).round(2)
  rev_angle = revision_angle(angle1, angle2).round(2)
  puts "length=%.2f cm, inc_angle=%.2f DEG, rev_angle=%.2f DEG"%[length, inc_angle, rev_angle]
  
  sleep(2)
end

