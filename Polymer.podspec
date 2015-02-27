Pod::Spec.new do |spec|
  spec.name         = 'Polymer'
  spec.version      = '0.1'
  spec.license      = 'MIT'
  spec.homepage     = 'https://github.com/LoganWright/Polymer'
  spec.authors      = { 'Logan Wright' => 'logan.william.wright@gmail.com' }
  spec.summary      = 'Endpoint focused networking for iOS and OS X.'
  spec.source       = { :git => 'https://github.com/LoganWright/Polymer.git', :tag => '0.1' }
  spec.source_files = 'Polymer/Source/**/*.{h,m}'
  spec.ios.deployment_target = "7.0"
  spec.osx.deployment_target = "10.8"
  spec.requires_arc = true
  spec.dependency 'AFNetworking', '~> 2.0'
  spec.dependency 'JSONMapping', '0.1'
end
