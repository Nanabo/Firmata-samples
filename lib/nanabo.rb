# coding: utf-8
require 'rubygems'
require 'arduino_firmata'

SERVO_COUNT = 6

class Nanabo
  attr_reader :servos, :vacuum
  attr_accessor :speed, :same_time
  
  def initialize(serial, params = {})
    @machine = ArduinoFirmata.connect serial
    if params[:prints_message]
      @machine.on :sysex do |command, data|
        str = ""
        data.select{|c| c != 0}.each{|c| str << c}
        p "send-string: " + str
      end
    end
    @servos = (2..7).map {|pin| Servo.new(@machine, pin, 0)}
    target_angles = [90, 145, 60, 90, 90, 90]
    @servos.each_with_index {|s,i| s.target_angle = target_angles[i]}
    @speed = 50         # 動作スピード。下記@same_timeも影響する
    @pitch_angle = 90   # バキュームのピッチ角
    @holds_pitch = true # 真：姿勢が変わってもピッチ角を維持する
    @same_time = false  # 真：すべての動作を同じ時間で処理する（＝移動量が大きいほど早くなる）
    @vacuum = Vacuum.new(@machine)
  end
  
  def move
    adjust_pitch if @holds_pitch
    count = move_count
    (0..count).each do |i|
      @servos.each do |servo|
        ratio = i.to_f / count.to_f
        servo.write_diff(ratio)
      end
      sleep(0.01)
    end
    @servos.each {|s| s.update_angle}
  end
  
  def current_angles
    @servos.map {|s| s.current_angle}
  end
  
  def target_angles
    @servos.map {|s| s.target_angle}
  end
  
  def offsets=(array)
    @servos.map.with_index {|s,i| s.offset = array[i]}
  end
  
  def signs
    @servos.map {|s| s.sign}
  end
  
  private
  # 移動の際、最も移動量が大きいサーボの移動量を返す
  def max_distance
    tmp = @servos.map{|s| s.distance.abs}
    return tmp.max
  end
  
  # バキュームのピッチ角を一定に保つ
  def adjust_pitch
    servos[4].target_angle = 130 + @pitch_angle - servos[2].target_angle
  end
  
  def move_count
    @speed = [@speed, 0].max
    if @same_time
      count = 1000 / @speed 
    else
      count = (1000 * max_distance) / (@speed * 45)
    end
    return [count, 1].max
  end
end

# サーボクラス
class Servo
  attr_reader :current_angle
  attr_accessor :target_angle, :offset

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
  
  private
  def analog_pin
    @pin - 2
  end
end

# バキュームクラス
class Vacuum
  VALVE_PIN = 10
  PUMP_PIN = 11
  
  def initialize(machine)
    @machine = machine
    @machine.digital_write VALVE_PIN, false
    @machine.digital_write PUMP_PIN, false
  end
  
  def suck
    @machine.digital_write VALVE_PIN, false
    @machine.digital_write PUMP_PIN, true
  end
  
  def release
    @machine.digital_write VALVE_PIN, true
    @machine.digital_write PUMP_PIN, false
  end
end

# 中間値取得モジュール
module MedianFilter
  def self.med(count, &proc)
    array = (0..count).map do |i|
      proc.call
    end
    array.sort[(count-1)/2]
  end
end