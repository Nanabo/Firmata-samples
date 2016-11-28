# coding: utf-8
require 'rubygems'

# ���W�n�v�Z���W���[��
module CoodinateSystem
  include Math
  
  # �ɍ��W�n�̒萔
  ARM1_LENGTH = 19.50
  ARM2_LENGTH = 12.50
  SUB_LENGTH = 2.75
  INCLUDED_ANGLE_BASE = 245
  PEEK_ANGLE = 43
  
  # �~�����W�n�̒萔
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
  
  # �A�[���̒��������p�̑傫�������߂郁�\�b�h
  # �t�֐������������ʓ|�Ȃ̂ŁA���`�T���I�ɋ��߂Ă������Ƃɂ���
  def included_angle_from_length(length)
    # ������20��
    (20..179).each do |angle|
      # ���������߂�f(x)�͑����֐��Ȃ̂ŁAf(x)�����߂钷���𒴂������_�Ŋp�x��Ԃ�
      return angle if arm_length_impl(angle) >= length
    end
    return 179
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
  
  def translate_system(x, y, is_ground_base, forbidden_minus_y)
    y = [0, y].max if forbidden_minus_y
    y -= (HEIGHT_OFFSET - PUMP_HEIGHT) if is_ground_base
    theta = 0
    if x != 0
      theta = degree(atan(y/x))
    else
      theta = (y > 0) ? 90 : -90
    end
    [sqrt(x**2 + y**2), theta]
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

