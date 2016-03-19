Pod::Spec.new do |s|
  s.name         = "Permission"
  s.version      = "1.1"
  s.license      = { :type => "MIT" }
  s.homepage     = "https://github.com/delba/Permission"
  s.author       = { "Damien" => "damien@delba.io" }
  s.summary      = "A unified API to ask for permissions on iOS"
  s.source       = { :git => "https://github.com/delba/Permission.git", :tag => "v1.1" }

  s.ios.deployment_target = "8.0"

  s.source_files = "Source/**/*"

  s.requires_arc = true
end
