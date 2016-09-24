# coding: utf-8
require 'rubygems'
require_relative 'MedianFilter'

# サーボクラス
class Servo
  attr_reader :current_angle, :target_angle
  attr_accessor :offset

  def initialize(machine, pin, target)
    @machine = machine
    @pin = pin
    @offset = 0
    @current_angle = to_angle(sign)
    @target_angle = target
  end
  
  def distance
    (@target_angle + @offset) - @current_angle
  end
  
  def write_diff(ratio = 1.0)
    angle = @current_angle + (distance.to_f * ratio.to_f).round
    @machine.servo_write @pin, angle
  end
  
  def update_angle
    @current_angle = (@target_angle + @offset)
  end
  
  def sign
    MedianFilter.med(11){@machine.analog_read(analog_pin)}
  end
  
  def to_angle(val)
    return val * 180 / 1024
  end
  
  def target_angle=(val)
    @target_angle = [[0, val].max, 180].min.to_i
  end
  
  private
  def analog_pin
    @pin - 2
  end
end

