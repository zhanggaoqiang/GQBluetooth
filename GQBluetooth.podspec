

Pod::Spec.new do |s|

  s.name         = "zhanggaoqiangble"
  s.version      = "0.0.1"
  s.summary      = "低功耗蓝牙开发"
  s.description  = <<-DESC
                       连接低功耗蓝牙4.0，开发智能硬件
                   DESC
  s.homepage     = "https://github.com/zhanggaoqiang/ble"
  s.license      = "MIT"
  s.authors            = { "张高强" => "835389423@qq.com" }
  s.platform     = :ios,"9.0"
  s.source       = { :git => "https://github.com/zhanggaoqiang/ble.git", :tag => s.version }
  s.source_files  = 'BlueTooth/**/*.{h,m}'
  s.requires_arc = true
end
