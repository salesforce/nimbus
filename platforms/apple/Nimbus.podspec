Pod::Spec.new do |s|
  s.name             = 'Nimbus'
  s.version          = '0.0.1'
  s.summary          = 'Nimbus is a framework for building cross-platform hybrid applications.'
  s.homepage         = 'https://git.soma.salesforce.com/MobilePlatform/Nimbus'
  s.source           = { :git => 'https://git.soma.salesforce.com/MobilePlatform/Nimbus.git', :tag => s.version.to_s }
  s.author           = { 'Hybrid Platform Team' => 'hybridplatform@salesforce.com' }
  s.license          = { :type => 'BSD-3-Clause', :file => '../../LICENSE' }
  s.source_files     = 'Sources/Nimbus/**/*.swift'
  s.swift_version    = '4.2'

  s.ios.deployment_target = '11.0'
end
