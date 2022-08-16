Pod::Spec.new do |s|
  s.name         = "Reflecter"
  s.version      = "1.0.0"
  s.summary      = "Model to Dictionary in Swift."
  s.homepage     = "https://github.com/iLiuChang/Reflecter"
  s.license      = "MIT"
  s.authors      = { "iLiuChang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/iLiuChang/Reflecter.git", :tag => s.version }
  s.requires_arc = true
  s.swift_version = "4.0"
  s.source_files = "Reflecter/*.{swift}"
end
