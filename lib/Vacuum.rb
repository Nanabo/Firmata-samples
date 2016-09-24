# coding: utf-8
require 'rubygems'

# バキュームクラス
class Vacuum
  VALVE_PIN = 10
  PUMP_PIN = 11
  
  def initialize(machine)
    @machine = machine
    @machine.digital_write VALVE_PIN, false
    @machine.digital_write PUMP_PIN, false
    @is_sucking = false
  end
  
  def suck
    @machine.digital_write VALVE_PIN, false
    @machine.digital_write PUMP_PIN, true
    @is_sucking = true
  end
  
  def release
    @machine.digital_write VALVE_PIN, true
    @machine.digital_write PUMP_PIN, false
    @is_sucking = false
  end
  
  def sucking?
    return @is_sucking
  end
end

