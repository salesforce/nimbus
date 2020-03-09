Pod::Spec.new do |s|
  s.name             = 'Nimbus'
  s.version          = '0.0.10'
  s.summary          = 'Nimbus is a framework for building cross-platform hybrid applications.'
  s.homepage         = 'https://github.com/salesforce/nimbus'
  s.source           = { :git => 'https://github.com/salesforce/nimbus.git', :tag => s.version.to_s }
  s.author           = { 'Hybrid Platform Team' => 'hybridplatform@salesforce.com' }
  s.license          = 'BSD-3-Clause'
  s.source_files     = 'platforms/apple/Sources/Nimbus/**/*.swift'
  s.swift_version    = '4.2'

  s.ios.deployment_target = '11.0'
end
