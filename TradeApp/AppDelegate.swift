//
//  AppDelegate.swift
//  TradeApp
//
//  Created by deathlezz on 17/11/2022.
//

import Firebase
import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate, UNUserNotificationCenterDelegate {

    // core data initialization
    lazy var coreDataStack: CoreDataStack = .init(modelName: "SavedAd")

        static let sharedAppDelegate: AppDelegate = {
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("Unexpected app delegate type, did it change? \(String(describing: UIApplication.shared.delegate))")
            }
            return delegate
        }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        <#code#>
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // retrieve the root view controller (which is a tab bar controller)
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
      
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // instantiate the view controller we want to show from storyboard
        // root view controller is tab bar controller
        // the selected tab is a navigation controller
        // then we push the new view controller to it
        if  let vc = storyboard.instantiateViewController(withIdentifier: "ChatView") as? ChatView,
            let tabBarController = rootViewController as? UITabBarController,
            let navController = tabBarController.selectedViewController as? UINavigationController {

                // we can modify variable of the new view controller using notification data
                // (eg: title of notification)
//                vc.senderDisplayName = response.notification.request.content.title
            vc.isPushedByChats = false
                // you can access custom data of the push notification by using userInfo property
                // response.notification.request.content.userInfo
            navController.pushViewController(vc, animated: true)
        }
        
        // tell the app that we have finished processing the user’s action / response
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Update the app interface directly.
        
        // Show a banner
        completionHandler([.banner, .badge, .sound])
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

