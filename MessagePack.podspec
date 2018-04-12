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


  # _code_lambda = lambda {
  #   s.source_files = 'Sources/*.swift'
  #   s.preserve_paths = 'Sources/CommonDigest/module.modulemap'
  #   s.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/../../MessagePack/Sources/CommonDigest' }
  # }
  # begin
  #   require '../Mandrake/Components/CommonPods.rb'
  #   generate_framework_for_spec_ifneed(s, _code_lambda)
  # rescue LoadError
  #   _code_lambda.call
  # end
  require '../Mandrake/Components/CommonPods.rb'
  generate_framework_for_spec_ifneed(s) {
    s.source_files = 'Sources/*.swift'
    s.preserve_paths = 'Sources/CommonDigest/module.modulemap'
    s.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/../../MessagePack/Sources/CommonDigest' }
  }
end
