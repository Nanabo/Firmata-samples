# coding: utf-8
require 'rubygems'
require 'arduino_firmata'

require_relative 'CoordinateSystemProxy'
require_relative 'Servo'
require_relative 'Vacuum'

SERVO_COUNT = 7

# Nanaboコントロールクラス
class Nanabo
  include CoordinateSystemProxy
  attr_reader :servos, :vacuum
  attr_accessor :speed, :same_time, :holds_pitch, :pitch_angle
  
  def initialize(serial, params = {})
    @machine = ArduinoFirmata.connect serial, bps: 57600
    if params[:prints_message]
      @machine.on :sysex do |command, data|
        str = ""
        data.select{|c| c != 0}.each{|c| str << c}
        p "send-string: " + str
      end
    end
    @servos = [2, 3, 4, 5, 6, 7, 8].map {|pin| Servo.new(@machine, pin, 0)}
    target_angles = [90, 145, 60, 90, 90, 90, 0]
    @servos.each_with_index {|s,i| s.target_angle = target_angles[i]}
    @speed = 50          # 動作スピード。下記@same_timeも影響する
    @pitch_angle = 90    # バキュームのピッチ角
    @holds_pitch = true  # 真：姿勢が変わってもピッチ角を維持する
    @same_time = false   # 真：すべての動作を同じ時間で処理する（＝移動量が大きいほど早くなる）
    @vacuum = Vacuum.new(@machine)
    @forbidden_minus_z = true
  end
  
  def set_default_arm(length, elevation_angle)
    inc_angle = included_angle_from_length(length)
    rev_angle = revision_angle_impl(inc_angle)
    servo1_angle = rev_angle.round + elevation_angle + 20
    @servos[1].target_angle = servo1_angle
    @servos[2].target_angle = servo2_angle(servo1_angle, inc_angle)
  end
  
  # is_ground_base: ピッチ角が90°で設置する高さをy=0とおく
  def set_default_arm_xy(x, y, is_ground_base = true)
    result = translate_system(x, y, is_ground_base, @forbidden_minus_z)
    set_default_arm(result[0], result[1].round)
  end
  
  # is_ground_base: ピッチ角が90°で設置する高さをy=0とおく
  def set_default_arm_xyz(x, y, z, is_ground_base = true)
    result = translate_system(y, x, false, false)
    set_default_arm_xy(result[0], z, is_ground_base)
    @servos[0].target_angle = result[1].round.to_i + 90
  end
  
  def move
    adjust_pitch if @holds_pitch
    count = move_count
    # 先に途中角度の状態をすべて計算してから、一気にサーボを動かす
    angles = Array.new(count+1 * @servos.size)
    (0..count).each do |i|
      @servos.each_with_index do |servo, j|
        angles[i*@servos.size+j] = servo.get_diff(i.to_f / count.to_f)
      end
    end
    (0..count).each do |i|
      @servos.each_with_index do |servo, j|
        servo.write_angle(angles[i*@servos.size+j])
      end
      sleep(0.02)
      #p [i, angles[i*@servos.size, @servos.size]]
    end
    @servos.each {|s| s.update_angle}
  end
  
  def current_angles
    @servos.map {|s| s.current_angle}
  end
  
  def target_angles
    @servos.map {|s| s.target_angle}
  end

  def target_angles=(target_array)
    @servos.each_with_index {|s,i| s.target_angle = target_array[i]}
  end
  
  def offsets=(array)
    @servos.map.with_index do |s,i|
      o = i < array.size ? array[i] : 0
      s.offset = o
    end
  end
  
  def signs
    @servos.map {|s| s.sign}
  end
  
  def arm_included_angle
    included_angle(@servos[1].current_angle, @servos[2].current_angle)
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
    base_count = 1000
    @speed = [@speed, 0].max
    if @same_time
      count = base_count / @speed 
    else
      count = (base_count * max_distance) / (@speed * 45)
    end
    return [count, 1].max
  end
end

