require 'json'

root = __dir__
package_version = lambda do |filename = 'lerna.json'|
  path = File.join(root, filename)
  JSON.load(File.read(path))['version']
end

version = package_version.call
Pod::Spec.new do |s|
  s.name            = 'NimbusJS'
  s.version         = version
  s.summary         = 'NimbusJS supplies the javascript necessary for the Nimbus framework'
  s.homepage        = 'https://github.com/salesforce/nimbus'
  s.source          = { :http => 'https://github.com/salesforce/nimbus/releases/download/' + s.version.to_s + '/NimbusJS.zip' }
  s.author          = { 'Hybrid Platform Team' => 'hybridplatform@salesforce.com' }
  s.license         = 'BSD-3-Clause'
  s.source_files    = '*.swift'
  s.resources       = ['*.js']
  s.preserve_paths  = '*'
  s.swift_version   = '4.2'

  s.ios.deployment_target = '11.0'

  s.dependency 'NimbusBridge', '= ' + version
end
