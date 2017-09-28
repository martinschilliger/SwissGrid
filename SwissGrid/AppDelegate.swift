//
//  AppDelegate.swift
//  SwissGrid
//
//  Created by Martin Schilliger on 14.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func fastForward() -> Bool {
        // Check if FastForward is enabled in settings
        let fastForward = UserDefaults.standard.object(forKey: "FFW") as? Bool ?? BooleanSetting.name("FFW").getDefaults()
        if fastForward {
            // Check if there is a string to paste
            if let pasteString = UIPasteboard.general.string {
                // Check if last open was also from same paste
                let pastedCoordinates = UserDefaults.standard.object(forKey: "FFWpasted") as? String
                if pasteString == pastedCoordinates {
                    // Inform the user that fastForward was terminated because of same string
                    return false;
                }
                
                let coordinatesClass = Coordinates()
                let viewControllerClass = ViewController()
                
                
                let parsed = coordinatesClass.parseCoordinates(coordinates: pasteString);
                if parsed.Ey != 0 && parsed.Nx != 0 { // 0 means invalid coordinates
                    // save coordinates
                    UserDefaults.standard.set(pasteString, forKey: "FFWpasted")
                    
                    let Calc1903 = CLLocation1903() //TODO: Make function reusable, is now just copy of line from ViewController.swift!
                    let lat = Calc1903.CHtoWGSlat(x: Double(parsed.Nx), y: Double(parsed.Ey))
                    let long = Calc1903.CHtoWGSlong(x: Double(parsed.Nx), y: Double(parsed.Ey))
                    
                    viewControllerClass.openMaps(lat: lat, long: long, clear: true)
                    return true
                }
            }
        }
        return false
     }
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // TODO: View gets loaded anyway in background
        _ = fastForward()
        
        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        _ = fastForward()
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
