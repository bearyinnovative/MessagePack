Pod::Spec.new do |s|
  s.name             = "MessagePack"
  s.version          = "0.1.0"
  s.license          = "ALL_RIGHTS_RESERVED"
  s.summary          = "MessagePack for BearyChat iOS."
  s.homepage         = "https://github.com/bearyinnovative/MessagePack"
  s.authors          = "cxa"
  s.source           = { :git => "https://github.com/bearyinnovative/MessagePack.git", :tag => s.version.to_s }

  s.requires_arc = true
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = '10.12'
  s.static_framework = true
  
  s.source_files = 'Sources/*.swift'
  s.preserve_paths = 'Sources/CommonDigest/module.modulemap'
  s.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/../../MessagePack/Sources/CommonDigest' }
end