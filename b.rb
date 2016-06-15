# -*- coding: utf-8 -*-
 
require 'natto'
 
text = '今日は晴れのちぶた'
 
natto = Natto::MeCab.new
natto.parse(text) do |n|
  puts "#{n.surface}: #{n.feature}"
end
