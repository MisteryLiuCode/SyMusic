//
//  SySystem.swift
//  demoBySwift
//
//  Created by sxm on 2017/5/5.
//  Copyright © 2017年 sxm. All rights reserved.
//
// -- 系统相关 --

import Foundation
import UIKit
import AVFoundation

//字符串不为空 可用
func availableString(value: String?) -> String {
    return value?.trimmingCharactersCount ?? 0 > 0 ? value! : ""
}

//整形不为空 可用
func availableInt(value: Int?) -> Int {
    return value != nil ? value! : 0
}


//是否是横屏
func isLandscape() -> Bool {
   var orientation = false
   let duration = UIDevice.current.orientation
   switch duration {
   case .landscapeLeft, .landscapeRight:
       orientation = true
   default:
       break
   }
   return orientation
}

//相机权限
func openScan(vc: UIViewController,
              navigationController: UINavigationController,
              openQuanXian: String,
              noCamera: String,
              title: String,
              sureTip: String) {
    //获取摄像设备
    let device = AVCaptureDevice.default(for: .video)
    if (device != nil) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        navigationController.pushViewController(vc, animated: true)
                        // 用户第一次同意了访问相机权限
                        //NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                }else{
                    // 用户第一次拒绝了访问相机权限
//                    NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                }
            }
        }else if status == AVAuthorizationStatus.authorized {//用户允许当前应用访问相机
            DispatchQueue.main.async {
                navigationController.pushViewController(vc, animated: true)
            }
        }else if status == AVAuthorizationStatus.denied { //用户拒绝当前应用访问相机
            DispatchQueue.main.async {
                // 无相机权限 做一个友好的提示
                SyAlertControllerView.showAlert(title: title, message: openQuanXian, cancelBtn: sureTip)
            }
        }else if status == AVAuthorizationStatus.restricted {
            //因为系统原因, 无法访问相册
        }
    }else{
        DispatchQueue.main.async {
            SyAlertControllerView.showAlert(title: title, message: noCamera, cancelBtn: sureTip)
        }
    }
}

//打开定位服务
func openLocation() -> Bool {
    if UIApplication.shared.backgroundRefreshStatus == .denied {
        SyAlertControllerView.showAlert(title: strCommon(key: "sy_tip"), message: strCommon(key: "sy_location_tip"), cancelBtn: strCommon(key: "sy_sure"))
        return false
    }else if UIApplication.shared.backgroundRefreshStatus == .restricted {
        SyAlertControllerView.showAlert(title: strCommon(key: "sy_tip"), message: strCommon(key: "sy_location_fail_tip"), cancelBtn: strCommon(key: "sy_sure"))
        return false
    }
    return true
}

//手机屏幕常亮
func screenlight(value: Bool) {
    UIApplication.shared.isIdleTimerDisabled = value
}

//退出app
func exitApplication() {
    guard let window = UIApplication.shared.delegate?.window else {
        return
    }
    UIView.animate(withDuration: 0.5, animations: {
        window?.alpha = 0
        window?.frame = CGRect.init(x: screenWidth / 2, y: screenHeight / 2, width: 0, height: 0)
    }) { (isFinished) in
        exit(0)
    }
}

//用于版本比较
func isNewVersion() -> Bool {
    let lastVersion = userDefaultsForString(forKey: appVersionKey)
    //SyPrint("当前版本\(currentVersion());,前一版本\(lastVersion)")
    if (lastVersion.count == 0) || (currentVersion as! String > lastVersion) {
        userDefaultsSetValue(value: currentVersion, key: appVersionKey)
        return true
    }
    return false
}

//是否是手机设备
internal let isIphoneDevice = UIDevice.current.userInterfaceIdiom == .phone

//当前app版本号
internal let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")

//获取当前手机系统版本号
internal let systemVersion = (UIDevice.current.systemVersion as NSString).doubleValue

//屏幕宽
internal let screenWidth = UIScreen.main.bounds.width

//屏幕高
internal let screenHeight = UIScreen.main.bounds.height

//tableView高
internal let screenHeightWithTableView = screenHeight - navigationBarWithHeight - 34.0

//距离顶部（导航栏）的距离
internal let navigationBarWithHeight = 64.0

//距离底部（工具栏）的距离
internal let toolBarWithHeight = 44.0

//状态栏
internal let statusBarWithHeight = 44.0

