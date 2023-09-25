//
//  SceneDelegate.swift
//  TradeApp
//
//  Created by deathlezz on 17/11/2022.
//

import UIKit
import NotificationCenter

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UINavigationControllerDelegate {

    var window: UIWindow?
    static var id: Int?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        guard let _ = (scene as? UIWindowScene) else { return }
        guard let url = connectionOptions.urlContexts.first?.url else { return }
        let id = url.absoluteString.components(separatedBy: "show/")[1]
        SceneDelegate.id = Int(id)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url.absoluteString else { return }
        let id = url.components(separatedBy: "show/")[1]
        
        // retrieve the root view controller (which is a tab bar controller)
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
        
        guard let item = AppStorage.shared.items.first(where: {$0.id == Int(id)}) else {
            let tabBarController = rootViewController as? UITabBarController
            let navController = tabBarController?.selectedViewController as? UINavigationController
                
            let ac = UIAlertController(title: "Item unavailable", message: "Try again later", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            navController?.present(ac, animated: true)
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let vc = storyboard.instantiateViewController(withIdentifier: "detailView") as? DetailView,
            let tabBarController = rootViewController as? UITabBarController,
            let navController = tabBarController.selectedViewController as? UINavigationController {
            
//            if DetailView().isBeingPresented || ItemView().isBeingPresented {
//                navController.popToRootViewController(animated: true)
//            }
            
            vc.item = item
            vc.hidesBottomBarWhenPushed = true
            navController.pushViewController(vc, animated: true)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

