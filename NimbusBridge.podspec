require 'json'

root = __dir__
package_version = lambda do |filename = 'lerna.json'|
  path = File.join(root, filename)
  JSON.load(File.read(path))['version']
end

version = package_version.call
Pod::Spec.new do |s|
  s.name             = 'NimbusBridge'
  s.module_name      = 'Nimbus'
  s.version          = version
  s.summary          = 'Nimbus is a framework for building cross-platform hybrid applications.'
  s.homepage         = 'https://github.com/salesforce/nimbus'
  s.source           = { :git => 'https://github.com/salesforce/nimbus.git', :tag => s.version.to_s }
  s.author           = { 'Hybrid Platform Team' => 'hybridplatform@salesforce.com' }
  s.license          = 'BSD-3-Clause'
  s.source_files     = 'platforms/apple/Sources/Nimbus/**/*.swift'
  s.resource         = 'packages/@nimbus-js/runtime/src/nimbus.js'
  s.swift_version    = '4.2'

  s.ios.deployment_target = '11.0'
end
