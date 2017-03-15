//
//  AppDelegate.swift
//  Belajar
//
//  Created by Jim Cramer on 07/06/16.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import UIKit
import FMDB

//private let signInEndPoint = "https://www.belajar.nl/auth/google/idtoken/"
private let signInEndPoint = "http://192.168.178.39:9000/auth/google/idtoken/"
private let silentSignIn = "silentSignIn"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Google sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self // BackendClient.shared
        
        //        UserDefaults.standard.register(defaults: [silentSignIn: false])
        //
        //        if UserDefaults.standard.bool(forKey: silentSignIn) {
        //            GIDSignIn.sharedInstance().signInSilently()
        //        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        // opt-in to state restoration
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        // opt-in to state restoration
        return true
    }
    
    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        //        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        //        guard let topAsDetailController = secondaryAsNavController.topViewController as? ArticleViewController else { return false }
        //        if topAsDetailController.topic == nil {
        //            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        //            return true
        //        }
        //        return false
        return true
    }
    
    // called on initial Google authentication, not on subsequent sign-ins
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance()
            .handle(url,
                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                    annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
}

extension AppDelegate: GIDSignInDelegate {
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            print("didSignInFor user \(user.profile.name)")
            NotificationCenter.default.post(name: Constants.didSignInNotification,
                                            object: self,
                                            userInfo: [Constants.googleUser: user])
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
        
        // Perform any operations when the user disconnects from app here.
    }
    
}
