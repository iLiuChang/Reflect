Pod::Spec.new do |s|
  s.name         = "Reflect"
  s.version      = "1.0.0"
  s.summary      = "Model to Dictionary in Swift."
  s.homepage     = "https://github.com/iLiuChang/Reflect"
  s.license      = "MIT"
  s.authors      = { "iLiuChang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/iLiuChang/Reflect.git", :tag => s.version }
  s.requires_arc = true
  s.swift_version = "4.0"
  s.source_files = "Reflect/*.{swift}"
end
