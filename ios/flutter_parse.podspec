#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_parse'
  s.version          = '0.1.2'
  s.summary          = 'Flutter plugin for managing Parse SDK for both Android and iOS.'
  s.description      = <<-DESC
Flutter plugin for managing Parse SDK for both Android and iOS.
                       DESC
  s.homepage         = 'https://github.com/alann-maulana/flutter_parse'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Alann Maulana' => 'kangmas.alan@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Parse'

  s.ios.deployment_target = '8.0'
end

