# coding: utf-8
require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'

e_angle = 17
roffset = 0
loffset = 3

nanabo = Nanabo.new(ARGV[0])

nanabo.offsets = [0, 0, 0, 0, 0, 0, 0]
nanabo.same_time = true

nanabo.speed = 60
nanabo.move
sleep(1)

nanabo.speed = 100
nanabo.target_angles = [120, 90, 70, 60, 90, 90]
nanabo.move
sleep(1.5)

nanabo.target_angles = [0, 130, 40, 150, 70, 90]
nanabo.move
sleep(1.5)

nanabo.target_angles = [180, 110, 10, 30, 120, 90]
nanabo.move
sleep(1.5)

nanabo.target_angles = [90, 140, 40, 90, 90, 90]
nanabo.move
sleep(1.5)

nanabo.speed = 60
nanabo.servos[1].target_angle = 180
nanabo.move

sleep(2)

