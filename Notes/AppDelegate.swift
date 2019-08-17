//
//  AppDelegate.swift
//  Notes
//
//  Copyright © 2019 VIS Apps. All rights reserved.
//

import UIKit
import CocoaLumberjack

let client_id = "insert Client ID here"
let client_secret = "insert Client Secret here"

//имя параметра для хранения токена в UserDefaults
let tokenKey = "token"
let offlineToken = "offline"

#if DEBUG
let logLevel = DDLogLevel.debug
let analytics = false
#elseif QA
let logLevel = DDLogLevel.debug
let analytics = true
#else
let logLevel = DDLogLevel.info
let analytics = true
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupLogging()
        setupAnalytics()
        logGoogleAds()
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
    
    func setupLogging() {
        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        DDLogInfo("Logging setted up", level: logLevel)
        DDLogDebug("Detail logging enabled", level: logLevel)
    }
    
    func setupAnalytics() {
        if(analytics) {
            //Возможная инциализация Mixpanel (средства аналитики
            //if let MIXPANEL_TOKEN = Bundle.main.infoDictionary?["GoogleAds"] as? String {
            //    Mixpanel.initialize(token: MIXPANEL_TOKEN)
            //}
        }
    }
    
    func logGoogleAds() {
        //BannerID и InterstitialID возможно в дальнейшем использовать для показа рекламы
        if let GOOGLE_ADS = Bundle.main.infoDictionary?["GoogleAds"]
            as? Dictionary<String, String> {
            let bannerID = GOOGLE_ADS["BannerID"] ?? ""
            let interstitialID = GOOGLE_ADS["InterstitialID"] ?? ""
            DDLogInfo("Google Ads BannerID: " + bannerID, level: logLevel)
            DDLogInfo("Google Ads InterstitialID: " + interstitialID, level: logLevel)
        }
    }


}

