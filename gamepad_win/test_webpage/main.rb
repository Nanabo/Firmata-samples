# coding: utf-8
# ゲームパッドによる操作

require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'

nanabo = Nanabo.new(ARGV[1])

nanabo.offsets = [8, 0, 0, 0, 0, 3]

nanabo.move
sleep(1)

nanabo.servos[0].target_angle = 0
nanabo.servos[1].target_angle = 75
nanabo.servos[2].target_angle = 50
nanabo.move
sleep(2)

include CoodinateSystem
Window.loop do
  sleep(2)
end

