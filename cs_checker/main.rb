# coding: utf-8
# ���W�n�`�F�b�J�[

require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'

nanabo = Nanabo.new("COM7")

nanabo.offsets = [8, 0, 0, 0, 0, 3]

nanabo.move
sleep(1)

nanabo.servos[1].target_angle = 75
nanabo.servos[2].target_angle = 50
nanabo.move
sleep(2)

loop do
  sleep(2)
end

