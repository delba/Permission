Pod::Spec.new do |s|
  s.name         = "Sorry"
  s.version      = "1.0.1"
  s.license      = { :type => "MIT" }
  s.homepage     = "https://github.com/delba/Sorry"
  s.author       = { "Damien" => "damien@delba.io" }
  s.summary      = "The better way to ask for permission"
  s.source       = { :git => "https://github.com/delba/Sorry.git", :tag => "v1.0.1" }

  s.ios.deployment_target = "8.0"

  s.source_files = "Source/**/*"

  s.requires_arc = true
  s.deprecated_in_favor_of = "Permission"
end
