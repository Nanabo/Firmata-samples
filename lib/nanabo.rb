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
    @speed = 50         # ����X�s�[�h�B���L@same_time���e������
    @pitch_angle = 90   # �o�L���[���̃s�b�`�p
    @holds_pitch = true # �^�F�p�����ς���Ă��s�b�`�p���ێ�����
    @same_time = false  # �^�F���ׂĂ̓���𓯂����Ԃŏ�������i���ړ��ʂ��傫���قǑ����Ȃ�j
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
  # �ړ��̍ہA�ł��ړ��ʂ��傫���T�[�{�̈ړ��ʂ�Ԃ�
  def max_distance
    tmp = @servos.map{|s| s.distance.abs}
    return tmp.max
  end
  
  # �o�L���[���̃s�b�`�p�����ɕۂ�
  def adjust_pitch
    servos[4].target_angle = 130 + @pitch_angle - servos[2].target_angle
  end
  
  def move_count
    return 1000 / @speed if @same_time
    return (1000 * max_distance) / (@speed * 45)
  end
end

# �T�[�{�N���X
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

# �o�L���[���N���X
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

# ���Ԓl�擾���W���[��
module MedianFilter
  def self.med(count, &proc)
    array = (0..count).map do |i|
      proc.call
    end
    array.sort[(count-1)/2]
  end
end