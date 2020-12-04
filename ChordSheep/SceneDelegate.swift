//
//  SceneDelegate.swift
//  ChordSheep
//
//  Created by Lennart Wisbar on 09.01.20.
//  Copyright © 2020 Lennart Wisbar. All rights reserved.
//

import UIKit
import FirebaseUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate, FUIAuthDelegate {

    var window: UIWindow?
    let store = DBStore()
    // var user: User?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // guard let _ = (scene as? UIWindowScene) else { return }
        
        if let windowScene = scene as? UIWindowScene {

            let window = UIWindow(windowScene: windowScene)
            
            if Auth.auth().currentUser == nil {
                guard let authUI = FUIAuth.defaultAuthUI() else { print("AuthUI couldn't be created"); fatalError() }
                authUI.delegate = self
                let providers: [FUIAuthProvider] = [
                    FUIEmailAuth()
                ]
                authUI.providers = providers
                let authVC = authUI.authViewController()
                window.rootViewController = authVC
            } else {
                // try! Auth.auth().signOut()
                window.rootViewController = MainVC(store: store)
            }

            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        guard let userAuth = authDataResult?.user else { fatalError("Sign in didn't work. No user returned.") }  // TODO: Notify user and go back to sign in page to try again
        
        // Store user in database if it's a new user
        if let isNewUser = authDataResult?.additionalUserInfo?.isNewUser, isNewUser {
            store.store(user: User(id: userAuth.uid, name: userAuth.displayName ?? ""))
        }
//        _ = User(
//                name: userAuth.displayName ?? "",
//                uid: userAuth.uid,
//                isNew: authDataResult?.additionalUserInfo?.isNewUser ?? false
//            )  // This also creates the user in the DB if new.
            // TODO: Prompt user to enter display name if there is none
        
        // Show MainVC
        window!.rootViewController = MainVC(store: store)
        window!.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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

