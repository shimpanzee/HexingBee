target 'HexingBee' do
  use_frameworks!
  inhibit_all_warnings!

  pod 'Factory'
  pod 'TinyConstraints'

  target 'HexingBeeTests' do
    inherit! :search_paths
    use_frameworks!
    pod 'MockingbirdFramework'
  end

  post_install do |installer|
    # Configure the Pods project
    installer.pods_project.build_configurations.each do |config|
      config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
    end

    # Configure the Pod targets
    installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
     config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
     config.build_settings.delete 'DEAD_CODE_STRIPPING'
    end
   end
  end

end

