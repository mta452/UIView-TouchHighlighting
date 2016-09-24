Pod::Spec.new do |spec|
  spec.name                  = 'UIView+TouchHighlighting'
  spec.version               = '1.2.0'
  spec.license               = { :type => 'Apache 2.0' }
  spec.authors               = { 'Muhammad Tayyab Akram' => 'dear_tayyab@yahoo.com' }
  spec.summary               = 'UIView category that provides a generic touch highlighting solution.'
  spec.homepage              = 'https://github.com/mta452/UIView-TouchHighlighting'
  spec.screenshots           = 'https://github.com/mta452/UIView-TouchHighlighting/raw/master/SCREENSHOT.png'
  spec.source                = { :git => 'https://github.com/mta452/UIView-TouchHighlighting.git', :tag => '1.2.0' }
  spec.source_files          = 'UIView+TouchHighlighting/**/*.{h,m}'
  spec.public_header_files   = 'UIView+TouchHighlighting/*.{h}'
  spec.framework             = 'Foundation', 'QuartzCore', 'UIKit'
  spec.platform              = :ios
  spec.ios.deployment_target = '8.0'
  spec.requires_arc          = true
end
