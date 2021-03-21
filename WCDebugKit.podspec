#
# Be sure to run `pod lib lint WCDebugKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WCDebugKit'
  s.version          = '0.1.0'
  s.summary          = 'A "Swiss Army Knife" Debug Kit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A debug kit for iOS
                       DESC

  s.homepage         = 'https://github.com/daydreamboy/WCDebugKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wesley chen' => 'wesley4chen@gmail.com' }
  s.source           = { :git => 'https://github.com/daydreamboy/WCDebugKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.source_files = [ 
    'SourceCode/Classes/WCDebugKit.h', 
    'SourceCode/Classes/WCDebugKit_Configuration.h' 
  ]
  s.public_header_files = [ 'SourceCode/Classes/WCDebugKit.h' ]
  s.script_phase = { :name => 'create_universal_framework.sh', :script => 'bash "${PROJECT_DIR}/../scripts/create_universal_framework.sh"' }

  # Note: 
  # WDK prefix short for WCDebugKit

  # subspec 'DebugPanel'
  # Note: this a basic subspec
  s.subspec 'DebugPanel' do |ss|
  	ss.source_files = [
  		'SourceCode/Classes/DebugPanel/**/*'
  	]
  	ss.public_header_files = [
			'SourceCode/Classes/DebugPanel/WDKDebugPanelPod.h',
			'SourceCode/Classes/DebugPanel/WDKDebugPanel.h',
			'SourceCode/Classes/DebugPanel/DebugActions/**/*.h',
    ]
    ss.private_header_files = [
      'SourceCode/Classes/DebugPanel/DebugActions/WDKDebugAction_Internal.h',
      'SourceCode/Classes/DebugPanel/DebugActions/WDKDebugGroup_Internal.h'
    ]
    # Note: exclude_files will remove files
    # ss.exclude_files = [
    #   'SourceCode/Classes/DebugPanel/DebugActions/WDKDebugAction_Internal.h',
    #   'SourceCode/Classes/DebugPanel/DebugActions/WDKDebugGroup_Internal.h'
    # ]
		ss.resource_bundles = {
    	'WCDebugKit' => ['Pod/Assets/**/*']
  	}
  end

  s.subspec 'CommonTools' do |ss|
  	ss.source_files = [
  		'SourceCode/Classes/CommonTools/**/*'
  	]
  end

  # subspec 'AppInfoViewer'
  s.subspec 'AppInfoViewer' do |ss|
    ss.dependency 'WCDebugKit/DebugPanel'
    ss.dependency 'WCDebugKit/CommonTools'

  	ss.source_files = [
      'SourceCode/Classes/AppInfoViewer/**/*', 
  	]
  	ss.public_header_files = [
			'SourceCode/Classes/AppInfoViewer/WDKAppInfoViewer.h',
		]
  end

  # subspec 'DeviceInfoViewer'
  s.subspec 'DeviceInfoViewer' do |ss|
    ss.dependency 'WCDebugKit/DebugPanel'

  	ss.source_files = [
  		'SourceCode/Classes/DeviceInfoViewer/**/*',
  	]
  	ss.public_header_files = [
			'SourceCode/Classes/DeviceInfoViewer/WDKDeviceInfoViewer.h',
		]
  end

  # subspec 'FileExplorer'
  s.subspec 'FileExplorer' do |ss|
  	ss.dependency 'WCDebugKit/DebugPanel'
    ss.dependency 'WCDebugKit/CommonTools'

  	ss.source_files = [
      'SourceCode/Classes/FileExplorer/**/*',
  	]
  end

  # subspec 'ViewInspector'
  s.subspec 'ViewInspector' do |ss|
    ss.dependency 'WCDebugKit/DebugPanel'
    ss.dependency 'WCDebugKit/CommonTools'

  	ss.source_files = [
      'SourceCode/Classes/ViewInspector/**/*',
  	]
  end

  # subspec 'ObjectExplorer'
  s.subspec 'ObjectExplorer' do |ss|
  	ss.dependency 'WCDebugKit/DebugPanel'
  	ss.source_files = [
      'SourceCode/Classes/ObjectExplorer/**/*',
  	]
  end

  # subspec 'HookManager'
  s.subspec 'HookManager' do |ss|
    ss.dependency 'WCDebugKit/DebugPanel'
    ss.dependency 'WCDebugKit/CommonTools'

  	ss.source_files = [
      'SourceCode/Classes/HookManager/**/*',
  	]
  end

    # subspec 'HeapExplorer'
    s.subspec 'HeapExplorer' do |ss|
      ss.dependency 'WCDebugKit/DebugPanel'
      ss.dependency 'WCDebugKit/CommonTools'
  
      ss.source_files = [
        'SourceCode/Classes/HeapExplorer/**/*',
      ]
    end

  # subspec 'IntegratedTools'
#  s.subspec 'IntegratedTools' do |ss|
#    ss.dependency 'WCDebugKit/DebugPanel'
#    ss.dependency 'FLEX', '= 2.4.0'
#    ss.source_files = [
#          'SourceCode/Classes/IntegratedTools/**/*',
#      ]
#    end

end
