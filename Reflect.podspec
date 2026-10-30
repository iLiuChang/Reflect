Pod::Spec.new do |s|
  s.name         = "Reflect"
  s.version      = "2.0.0"
  s.summary      = "Model to Dictionary in Swift."
  s.homepage     = "https://github.com/iLiuChang/Reflect"
  s.license      = "MIT"
  s.authors      = { "iLiuChang" => "iliuchang@foxmail.com" }
  s.ios.deployment_target = "12.0"
  s.osx.deployment_target = "10.13"
  s.tvos.deployment_target = "12.0"
  s.watchos.deployment_target = "4.0"
  s.visionos.deployment_target = "1.0"
  s.source       = { :git => "https://github.com/iLiuChang/Reflect.git", :tag => s.version }
  s.requires_arc = true
  s.swift_version = "5.0"
  s.source_files = "Sources/*.{swift}"
  s.resource_bundles = { 'Reflect' => ['Sources/PrivacyInfo.xcprivacy'] }
end
