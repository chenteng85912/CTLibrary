
Pod::Spec.new do |s|
    s.name         = 'CTLibrary'
    s.version      = '1.0.0'
    s.summary      = 'Library for TYKY'
    s.homepage     = 'https://github.com/chenteng85912/CTLibrary'
    s.license       = { :type => "MIT", :file => "LICENSE" }
    s.authors      = {'CHENTENG' => 'chenteng85912@163.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/chenteng85912/CTLibrary.git', :tag => s.version}
    s.requires_arc = true

    s.source_files = 'CTLibrary/**/CTLibrary.h'
    s.frameworks = 'CoreLocation', 'MapKit', 'LocalAuthentication'

#自动定位
    s.subspec 'CTAutoLocation' do |ss|
        ss.source_files = 'CTLibrary/**/CTAutoLocation/*.{h,m}'
        ss.resources = "CTLibrary/**/CTAutoLocation/*.{png,plist,xib}"

    end

#自动滚动广告
    s.subspec 'CTAutoLoop' do |ss|
        ss.source_files = 'CTLibrary/**/CTAutoLoopViewController.{h,m}'
    end

#页面控制器
    s.subspec 'CTPageViewController' do |ss|
        ss.source_files = 'CTLibrary/**/CTCustomePageController.{h,m}'
    end

#指纹识别
    s.subspec 'CTTouchIDAuthorize' do |ss|
        ss.source_files = 'CTLibrary/**/CTTouchIDAuthorize.{h,m}'
    end

#表视图代理封装
    s.subspec 'CTTableViewDelegate' do |ss|
        ss.source_files = 'CTLibrary/**/CTTableViewDelegate/*.{h,m}'
    end

#版本检测
    s.subspec 'CTVersionCheck' do |ss|
        ss.source_files = 'CTLibrary/**/CTVersionCheck/*.{h,m}'
    end

#跑马灯
    s.subspec 'CTAutoRunLabel' do |ss|
        ss.source_files = 'CTLibrary/**/CTAutoRunLabel.{h,m}'
    end

#自定义工具类
    s.subspec 'CustomLibrary' do |ss|
        ss.source_files = 'CTLibrary/**/CustomLibrary/*.{h,m}'
    end
end
