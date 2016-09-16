# coding: utf-8
# 座標系チェッカー

require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'

nanabo = Nanabo.new("COM7")

nanabo.offsets = [8, 0, 0, 0, 0, 3]

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
  puts "(%d, %d) move finished!"%[nanabo.servos[1].current_angle, nanabo.servos[2].current_angle]
  sleep(2)
end

