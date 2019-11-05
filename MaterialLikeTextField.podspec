#
# Be sure to run `pod lib lint MaterialLikeTextField.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MaterialLikeTextField'
  s.version          = '0.3.2'
  s.summary          = 'Material design styled UITextField written in one file.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
MaterialLikeTextField is material design styled text field, extends UITextField class.
                       DESC

  s.homepage         = 'https://github.com/brownsoo/MaterialLikeTextField'
  # s.screenshots      = 'https://github.com/brownsoo/MaterialLikeTextField/blob/master/mf-sample.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brownsoo' => 'hansune@me.com' }
  s.source           = { :git => 'https://github.com/brownsoo/MaterialLikeTextField.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hansoolabs'

  s.ios.deployment_target = '11.0'
  s.swift_versions = ['5.0']
  s.source_files = 'MaterialLikeTextField/Classes/**/*'
  
end
