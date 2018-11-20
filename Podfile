source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
inhibit_all_warnings!
use_frameworks!

def corePods

	pod 'R.swift', '~> 5.0.0.alpha.2'
	pod 'Mapbox-iOS-SDK', '~> 4.6'
	pod 'RxSwift'
end

target 'tzp-Demo' do
	corePods
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
			config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
			config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
		end
	end
end
