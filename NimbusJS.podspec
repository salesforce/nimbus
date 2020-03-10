Pod::Spec.new do |s|
  s.name            = 'NimbusJS'
  s.version         = '0.99.0'
  s.summary         = 'NimbusJS supplies the javascript necessary for the Nimbus framework'
  s.homepage        = 'https://github.com/salesforce/nimbus'
  s.source          = { :http => 'https://github.com/salesforce/nimbus/releases/download/0.0.9/NimbusJS.zip' }
  s.author          = { 'Hybrid Platform Team' => 'hybridplatform@salesforce.com' }
  s.license         = 'BSD-3-Clause'
  s.source_files    = '*.swift'
  s.resources       = ['*.js']
  s.preserve_paths  = '*'
  s.swift_version   = '4.2'

  s.ios.deployment_target = '11.0'
end
