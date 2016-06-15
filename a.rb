# -*- coding: utf-8 -*-

require 'natto'

nm = Natto::MeCab.new('-Oyomi')

Encoding.default_external = 'shift-jis'
x = nm.parse('庭には二羽鶏がいる')

puts x

