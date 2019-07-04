#
# Be sure to run `pod lib lint FWShadowableScroll.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FWShadowableScroll'
  s.version          = '1.0.1'
  s.summary          = 'UIScrollView extension to add a top shadow while scrolling.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A scroll view top shadow, visible while scrolling, with customizable height and radius.
                       DESC

  s.homepage         = 'https://github.com/felipewil/FWShadowableScroll'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Felipe Leite' => 'felipewil@icloud.com' }
  s.source           = { :git => 'https://github.com/felipewil/FWShadowableScroll.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'

  s.source_files = 'FWShadowableScroll/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FWShadowableScroll' => ['FWShadowableScroll/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
