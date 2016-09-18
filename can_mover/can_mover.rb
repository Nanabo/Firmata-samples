# coding: utf-8
require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'

e_angle = 17
roffset = 0
loffset = 3

nanabo = Nanabo.new(ARGV[1])

nanabo.offsets = [8, 0, 0, 0, 0, 3]
#nanabo.same_time = true

nanabo.move
sleep(1)

nanabo.servos[1].target_angle = 75
nanabo.servos[2].target_angle = 50
nanabo.move
sleep(2)

loop do
  nanabo.servos[0].target_angle = 45
  nanabo.move
  sleep(2)
  
  nanabo.servos[1].target_angle -= e_angle + roffset
  nanabo.servos[2].target_angle += e_angle + roffset
  nanabo.move
  sleep(1)
  
  nanabo.vacuum.suck
  sleep(3)
  
  nanabo.speed = 25
  nanabo.servos[1].target_angle += e_angle + roffset
  nanabo.servos[2].target_angle -= e_angle + roffset
  nanabo.move
  sleep(2)
  
  nanabo.servos[0].target_angle = 135
  nanabo.move
  sleep(2)
  
  nanabo.servos[1].target_angle -= e_angle + loffset
  nanabo.servos[2].target_angle += e_angle + loffset
  nanabo.move
  sleep(1)
  
  nanabo.vacuum.release
  sleep(2)
  
  nanabo.speed = 50
  nanabo.servos[1].target_angle += e_angle + loffset
  nanabo.servos[2].target_angle -= e_angle + loffset
  nanabo.move
  sleep(2)
  
  nanabo.servos[0].target_angle = 90
  nanabo.move
  sleep(2)
  
  nanabo.servos[0].target_angle = 135
  nanabo.move
  sleep(2)
  
  nanabo.servos[1].target_angle -= e_angle + loffset
  nanabo.servos[2].target_angle += e_angle + loffset
  nanabo.move
  sleep(1)
  
  nanabo.vacuum.suck
  sleep(3)
  
  nanabo.speed = 25
  nanabo.servos[1].target_angle += e_angle + loffset
  nanabo.servos[2].target_angle -= e_angle + loffset
  nanabo.move
  sleep(2)
  
  nanabo.servos[0].target_angle = 45
  nanabo.move
  sleep(2)
  
  nanabo.servos[1].target_angle -= e_angle + roffset
  nanabo.servos[2].target_angle += e_angle + roffset
  nanabo.move
  sleep(1)
  
  nanabo.vacuum.release
  sleep(2)
  
  nanabo.speed = 50
  nanabo.servos[1].target_angle += e_angle + roffset
  nanabo.servos[2].target_angle -= e_angle + roffset
  nanabo.move
  sleep(2)
  
  nanabo.servos[0].target_angle = 90
  nanabo.move
  sleep(2)
end

