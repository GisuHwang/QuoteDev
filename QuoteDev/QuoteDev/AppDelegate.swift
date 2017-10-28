//
//  AppDelegate.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 14..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // 로컬 및 원격 통지에 대한 권한을 요청
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: { (flag, err) in
                
            })
            application.registerForRemoteNotifications()
        } else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .sound], categories: nil))
            // Fallback on earlier versions
        }
        
        // MARK: Firebase Auth 진행 코드
        // UserDefaults에 저장된 uid가 없을 경우, Firebase의 Auth signInAnonymously을 진행합니다.
        // Firebase의 익명 Auth는 앱을 지웠다 설치하더라도 같은 uid를 갖습니다. ( 디바이스 의존성 )
        if UserDefaults.standard.string(forKey: Constants.userDefaults_Uid) == nil {
            Auth.auth().signInAnonymously { (user, error) in
                print("///// signInAnonymously user: ", user ?? "no user")
                print("///// signInAnonymously user uid: ", user?.uid ?? "no user uid")
                print("///// signInAnonymously error: ", error ?? "no error")
                
                // SignIn 후, UserDefaults에 저장합니다.
                guard let uid = user?.uid else { return }
                UserDefaults.standard.set(uid, forKey: Constants.userDefaults_Uid)
            }
        }
        print("///// userDefaults uid: ", UserDefaults.standard.string(forKey: Constants.userDefaults_Uid) ?? "no data")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // 특정 알림에 대해 사용자가 선택한 작업을 앱에 알리기 위해 호출됩니다.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("userNotificatonCenter - didReceive")
    }
    
    // 포 그라운드 앱에 알림이 전달되면 호출됩니다
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("userNotificatonCenter - willPresent")
        center.getPendingNotificationRequests { (requests) in
            for req in requests {
                print(req.content.title+"호출됨")
                completionHandler(.alert)
            }
        }
    }
}

