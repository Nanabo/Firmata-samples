# coding: utf-8
require 'rubygems'
require 'arduino_firmata'

SERVO_COUNT = 6

# 座標系計算モジュール
module CoodinateSystem
  include Math
  
  # 極座標系の定数
  ARM1_LENGTH = 19.50
  ARM2_LENGTH = 12.50
  SUB_LENGTH = 2.75
  INCLUDED_ANGLE_BASE = 245
  PEEK_ANGLE = 43
  
  # 円柱座標系の定数
  HEIGHT_OFFSET = 13.6
  PUMP_HEIGHT = 5.5
  
  def arm_length(m1, m2)
    arm_length_impl(included_angle(m1, m2))
  end
  
  def arm_length_impl(angle)
    angle = radian(angle)
    r1 = arm1_length(angle)
    r2 = arm2_length(angle)
    sqrt(r1**2 + r2**2 - 2*r1*r2*cos(angle))
  end
  
  def included_angle(m1, m2)
    INCLUDED_ANGLE_BASE - m1 - m2
  end
  
  # アームの長さから夾角の大きさを求めるメソッド
  # 逆関数化が著しく面倒なので、線形探索的に求めていくことにする
  def included_angle_from_length(length)
    # 下限は20°
    return 20 if length < 11.0
    (20..179).each do |angle|
      # 長さを求めるf(x)は増加関数なので、f(x)が求める長さを超えた時点で角度を返す
      return angle if arm_length_impl(angle) >= length
    end
  end
  
  def revision_angle(m1, m2)
    revision_angle_impl(included_angle(m1, m2))
  end
  
  def revision_angle_impl(angle)
    length = arm_length_impl(angle)
    over_peek = angle >= PEEK_ANGLE
    angle = radian(angle)
    alpha = arm1_length(angle) * sin(angle) / length
    res = degree(asin(alpha))
    res = over_peek ? res : 180.0 - res
  end
  
  def servo2_angle(servo1_angle, inc_angle)
    INCLUDED_ANGLE_BASE - servo1_angle - inc_angle
  end
  
  def translate_system(x, y, is_ground_base)
    y -= (HEIGHT_OFFSET - PUMP_HEIGHT) if is_ground_base
    [sqrt(x**2 + y**2), degree(atan(y/x))]
  end
  
  def arm1_length(angle)
    return ARM1_LENGTH + SUB_LENGTH * cos(angle) / sin(angle)
  end
  
  def arm2_length(angle)
    return ARM2_LENGTH + SUB_LENGTH / sin(angle)
  end
  
  def radian(deg)
    deg.to_f * PI / 180.0
  end
  
  def degree(rad)
    rad * 180.0 / PI
  end
end

# Nanaboコントロールクラス
class Nanabo
  include CoodinateSystem
  attr_reader :servos, :vacuum
  attr_accessor :speed, :same_time, :holds_pitch, :pitch_angle
  
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
    @speed = 50             # 動作スピード。下記@same_timeも影響する
    @pitch_angle = 90    # バキュームのピッチ角
    @holds_pitch = true  # 真：姿勢が変わってもピッチ角を維持する
    @same_time = false  # 真：すべての動作を同じ時間で処理する（＝移動量が大きいほど早くなる）
    @vacuum = Vacuum.new(@machine)
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
    result = translate_system(x, y, is_ground_base)
    p "length=%.2f, angle=%d"%[result[0], result[1].round.to_i]
    set_default_arm(result[0], result[1].round)
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

  def target_angles=(target_array)
    @servos.each_with_index {|s,i| s.target_angle = target_array[i]}
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

# 中間値取得モジュール
module MedianFilter
  def self.med(count, &proc)
    array = (0..count).map do |i|
      proc.call
    end
    array.sort[(count-1)/2]
  end
end
