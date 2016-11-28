# coding: utf-8
require 'rubygems'
require 'arduino_firmata'
require_relative '../lib/nanabo'
require 'csv'

def printServoValues(nanabo)
  
  str = (nanabo.target_angles).each_with_index() do |c, i|
    "Servos#{c}:#{i},"
  end
  
  puts str, "-----------------------------"
end


#e_angle = 17
nanabo = Nanabo.new(ARGV[0])

nanabo.offsets = [8, 20, 20, 0, 0, 0, 0]
#nanabo.same_time = true

nanabo.speed = 10
nanabo.move
sleep(1)

recipes = CSV.read(ARGV[1])

recipes.each do |row|
  nanabo.target_angles = row[0..5].map(&:to_i)
  nanabo.speed = row[6].to_i
  nanabo.move
  printServoValues(nanabo)
  sleep(0.2)
end
puts '+++DONE+++'
