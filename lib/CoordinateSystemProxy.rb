# coding: utf-8
require 'rubygems'
require_relative 'CoodinateSystem'

# ���W�n�v�Z���W���[���v���L�V
# �����W���[���ł̌v�Z���ʂ��L���b�V���ɕێ�����
module CoordinateSystemProxy
  include CoodinateSystem
  @@arm_length_map = Array.new(181)
  @@revision_angle_map = Array.new(181)
  
  def arm_length_impl(angle)
    val = @@arm_length_map[angle]
    unless val
      val = super
      @@arm_length_map[angle] = val
    end
    return val
  end
  
  def revision_angle_impl(angle)
    val = @@revision_angle_map[angle]
    unless val
      val = super
      @@revision_angle_map[angle] = val
    end
    return val
  end
end

