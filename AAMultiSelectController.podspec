#
# Be sure to run `pod lib lint AAMultiSelectController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AAMultiSelectController'
  s.version          = '0.4.0'
  s.summary          = 'AAMultiSelectController provide a elegant popup view to display a multiple select dialog.'

  s.description      = <<-DESC
    AAMultiSelectController provide a popup dialog to user which can select from multiple choice, and you also can customize it.
                       DESC

  s.homepage         = 'https://github.com/aozhimin/AAMultiSelectController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dev-aozhimin' => 'aozhimin0811@gmail.com' }
  s.source           = { :git => 'https://github.com/aozhimin/AAMultiSelectController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AAMultiSelectController/Classes/**/*'
  
  s.resource_bundles = {
     'AAMultiSelectController' => ['AAMultiSelectController/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Masonry'
end
