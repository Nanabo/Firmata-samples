# coding: utf-8
# 座標系チェッカー

require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'

nanabo = Nanabo.new(ARGV[0])

nanabo.offsets = [8, 0, 0, 0, 0, 3, 0]

nanabo.move
sleep(1)

nanabo.servos[0].target_angle = 0
nanabo.servos[1].target_angle = 75
nanabo.servos[2].target_angle = 50
nanabo.move
sleep(2)

loop do
  puts "angles[1]=?"
  nanabo.servos[1].target_angle = gets.chomp.to_i
  puts "angles[2]=?"
  nanabo.servos[2].target_angle = gets.chomp.to_i
  nanabo.move
  
  angle1 = nanabo.servos[1].current_angle
  angle2 = nanabo.servos[2].current_angle
  puts "(%d, %d) move finished!"%[angle1, angle2]
  
  # アーム長さと仰角を算出
  length = arm_length(angle1, angle2).round(2)
  inc_angle = included_angle(angle1, angle2).round(2)
  rev_angle = revision_angle(angle1, angle2).round(2)
  puts "length=%.2f cm, inc_angle=%.2f DEG, rev_angle=%.2f DEG"%[length, inc_angle, rev_angle]
  sleep(2)
end

