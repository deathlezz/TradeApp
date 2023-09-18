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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        print("URL: \(url)")
        
//        if UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//
//            print("URL: \(url)")
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let navController = UINavigationController(rootViewController: ViewController())
//            if let vc = storyboard.instantiateViewController(withIdentifier: "CategoryView") as? CategoryView {
//                navController.pushViewController(vc, animated: true)
//            }
//
////            let customURL = "com.TradeApp://show/\(1234567)"
//            let customURL = try? String(contentsOf: url)
//            let id = customURL?.components(separatedBy: "show/")[1]
//
//            print("ID: \(id)")
//
////            let navController = UINavigationController(rootViewController: ViewController())
////            let storyboard = UIStoryboard(name: "Main", bundle: nil)
////            if let vc = storyboard.instantiateViewController(withIdentifier: "detailView") as? DetailView {
////                vc.item = AppStorage.shared.filteredItems.first(where: {$0.id == Int(id!)})
////                vc.hidesBottomBarWhenPushed = true
////                navController.pushViewController(vc, animated: true)
////            }
//        } else {
//            print("App scheme not found")
//        }
        
        
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // retrieve the root view controller (which is a tab bar controller)
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
      
        let userInfo = response.notification.request.content.userInfo
        
        if let chatInfo = userInfo["info"] as? String {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            if  let vc = storyboard.instantiateViewController(withIdentifier: "ChatView") as? ChatView,
                let tabBarController = rootViewController as? UITabBarController,
                let navController = tabBarController.selectedViewController as? UINavigationController {
                vc.isPushedByChats = false
                navController.pushViewController(vc, animated: true)
            }
        }
        
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

