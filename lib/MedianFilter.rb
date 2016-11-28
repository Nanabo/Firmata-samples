# coding: utf-8
require 'rubygems'

# ’†ŠÔ’læ“¾ƒ‚ƒWƒ…[ƒ‹
module MedianFilter
  def self.med(count, &proc)
    array = (0..count).map do |i|
      proc.call
    end
    array.sort[(count-1)/2]
  end
end
