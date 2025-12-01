platform :osx, '11.0'

target 'PingChekker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for PingChekker
  # ====================================================
  # Firebase Core & Analytics (Dasar-dasar)
  pod 'Firebase/Analytics'
  
  # Remote Config (Untuk fitur Force Update/Kill Switch)
  pod 'Firebase/RemoteConfig'
  
  # Crashlytics (Untuk error monitoring di masa depan)
  pod 'Firebase/Crashlytics'
  
  # Framework yang dibutuhkan untuk logic WifiService (SimplePing)
  # dan tools dasar Google
  pod 'GoogleUtilities'
  
  # ====================================================
  
  # Target Test: Pastikan mereka bisa mengakses Pods utama
  target 'PingChekkerTests' do
    inherit! :search_paths
    # Kita tidak perlu Firebase di sini, kecuali untuk ngetes Crashlytics.
  end
  
  target 'PingChekkerUITests' do
    # Pods for testing
  end
end

# Kita pastikan Linker Flags (-ObjC) ada di semua target.
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      
      # 1. Pastikan Build Settings untuk Dynamic Frameworks ter-link dengan benar
      config.build_settings['RUN_PATH_SEARCH_PATHS'] ||= ['@loader_path/../Frameworks']
      
      # 2. Tambahkan Linker Flag -ObjC (Wajib untuk Firebase/Analytics)
      # Ini menyelesaikan Undefined Symbols dari GUL (Google Utilities) dan FIR (Firebase)
      config.build_settings['OTHER_LDFLAGS'] ||= ['$(inherited)']
      config.build_settings['OTHER_LDFLAGS'] << '-ObjC'
      
      # 3. Hapus referensi ke SAMBA (rsync) yang memicu Sandbox deny (Fix yang sebelumnya)
      config.build_settings.delete 'FRAMEWORK_SEARCH_PATHS'
      
      # 4. Non-aktifkan "Build Libraries for Distribution" (sering konflik)
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
    end
  end
end
