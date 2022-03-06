//
//  AppDelegate.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 30/05/21.
//

import UIKit
import CoreData
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var userArray = [AppUser]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //        dataController.load {
        //            print("dataModel loaded")
        //        }
        print("didFinishLaunchingWithOptions")
//        print("Application directory: \(NSHomeDirectory())")
        // Remove this method to stop OneSignal Debugging
        //OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        // OneSignal initialization
        print(ONE_SIGNAL_APP_ID)
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(String(ONE_SIGNAL_APP_ID))
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleVersion"] as AnyObject
        if let version = nsObject {
            BUNDLE_VERSION = "\(version)"
        }else{
            BUNDLE_VERSION = "1.0"
        }

        
        
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("configurationForConnecting")
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("didDiscardSceneSessions")
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        //        saveContext()
    }
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        //        saveModel()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        //        saveModel()
    }
    
    //    // MARK: - Core Data stack
    //    lazy var persistentContainer: NSPersistentContainer = {
    //        let container = NSPersistentContainer(name: "DataModel")
    //        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
    //            if let error = error as NSError? {
    //                fatalError("Unresolved error \(error), \(error.userInfo)")
    //            }
    //        })
    //        return container
    //    }()
    //
    //    // MARK: - Core Data Saving support
    //    func saveContext () {
    //        let context = persistentContainer.viewContext
    //        if context.hasChanges {
    //            do {
    //                try context.save()
    //            } catch {
    //                let nserror = error as NSError
    //                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    //            }
    //        }
    //    }
    // MARK: - Saving application state
    //    func saveModel(){
    //        do{
    //            try dataController.viewContext.save()
    //            print("saved")
    //        } catch {
    //            print(error.localizedDescription)
    //            print("notsaved")
    //        }
    //    }
}

