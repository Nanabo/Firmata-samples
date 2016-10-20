# coding: utf-8
require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'

nanabo = Nanabo.new("COM7")

nanabo.offsets = [0, 0, 0, 0, 0, 0]
#nanabo.same_time = true

nanabo.move
sleep(1)

length = 19.70
length2 = 18.35
angle = 12
angle2 = -8
offset = 6

first_m0 = 120
last_m0 = 60

nanabo.speed = 60
nanabo.servos[0].target_angle = first_m0
nanabo.set_default_arm(length, angle+offset)
nanabo.move
sleep(2)

nanabo.set_default_arm(length, angle)
nanabo.move
nanabo.vacuum.suck
sleep(5)

nanabo.set_default_arm(length, angle+offset)
nanabo.move
sleep(2)

nanabo.servos[0].target_angle = last_m0
nanabo.move
sleep(2)

nanabo.set_default_arm(length2, angle2)
nanabo.move
sleep(2)

nanabo.vacuum.release
nanabo.set_default_arm(length2, angle2+offset)
nanabo.move
sleep(2)

nanabo.servos[0].target_angle = first_m0
nanabo.move
sleep(2)

nanabo.set_default_arm(length2,angle2)
nanabo.move
nanabo.vacuum.suck
sleep(5)

nanabo.set_default_arm(length, angle+offset)
nanabo.move
sleep(2)

nanabo.servos[0].target_angle = last_m0
nanabo.move
sleep(2)

nanabo.set_default_arm(length, angle)
nanabo.move
sleep(2)

nanabo.vacuum.release
nanabo.set_default_arm(length, angle+offset)
nanabo.move
sleep(2)

nanabo.servos[0].target_angle = 90
nanabo.move
sleep(2)

