//
//  SceneDelegate.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 30/05/21.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var hvc : HomeVC?
    
    let dataController = DataController(modelName: "DataModel")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        print("willConnectTo")
        
        dataController.load {
            print("dataController called")
        }
        
        let rootVC = window?.rootViewController as! UINavigationController
        let homeVC = rootVC.topViewController as! HomeVC
        hvc = homeVC
        homeVC.dataController = dataController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect")
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneDidBecomeActive")
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneWillResignActive")
       
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneWillEnterForeground")
        if let navigationController = window?.rootViewController as? UINavigationController {
            print("safely unwrapped")
            print(navigationController.viewControllers.count)
            if let vc = navigationController.topViewController {
                if vc.isKind(of: SauceFundingVC.self){
                    print("seflCalled")
                    return }
                if vc.isKind(of: SauceFundingPaymentVC.self){
                    print("seflCalled")
                    return }
            }
//            if navigationController.topViewController?.isKind(of: SauceFundingPaymentVC){ return }
            switch navigationController.viewControllers.count {
            case 3:
                window?.rootViewController?.dismiss(animated: true, completion: nil)
                navigationController.popViewController(animated: false)
                navigationController.popViewController(animated: true)
            default:
                navigationController.popViewController(animated: true)
            }
        }
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("sceneDidEnterBackground")
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
        // MARK: - Core Data stack
        lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "DataModel")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
    
        // MARK: - Core Data Saving support
        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
//         MARK: - Saving application state
        func saveModel(){
            do{
                try dataController.viewContext.save()
                print("saved")
            } catch {
                print(error.localizedDescription)
                print("notsaved")
            }
        }

}

