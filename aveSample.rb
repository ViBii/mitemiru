require 'statsample'

a = [1,2,3,4,5,6,7,8,9,10].to_scale
#=> Vector(type:scale, n:10)[1,2,3,4,5,6,7,8,9,10]

a.mean #平均 => 5.5
a.range # => 9
a.sd #標準偏差 => 3.0276503540974917
a.variance #分散 => 9.166666666666666
a.skew #尖度 => 0.0
a.kurtosis #歪度 -1.5616363636363637
a.sum #合計 => 55 
puts a.summary
#= Vector 4
#  n :10
#  n valid:10
#  median: 5.5
#  mean: 5.5000
#  std.dev.: 3.0277
#  std.err.: 0.9574
#  skew: 0.0000
#  kurtosis: -1.5616
#=> nil

