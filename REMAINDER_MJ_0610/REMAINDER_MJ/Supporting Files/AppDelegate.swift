//
//  AppDelegate.swift
//  REMAINDER_MJ
//
//  Created by 구민정 on 30/05/2019.
//  Copyright © 2019 구민정. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if #available(iOS 10.0, *) {
            // 시스템에서 제공하는 인스턴스를 받아옴 - 경고창, 배지, 사운드를 사용하는 알림 정보를 생성, 사용자 동의 여부 창 실행
            let notiCenter = UNUserNotificationCenter.current()
            notiCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (didAllow, e) in } // 알림 설정에 대한 동의
        } else {
            // 경고창, 배지, 사운드를 사용하는 알림 정보를 생성, 애플리케이션에 저장
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(setting)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        CoreDataStack.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CoreDataStack.saveContext()
    }

    
    


}

/*
 // MARK: - Core Data stack
 // 프로젝트 만들때, use core data를 클릭하자^^
 
 lazy var persistentContainer: NSPersistentContainer = {
 /*
 The persistent container for the application. This implementation
 creates and returns a container, having loaded the store for the
 application to it. This property is optional since there are legitimate
 error conditions that could cause the creation of the store to fail.
 */
 let container = NSPersistentContainer(name: "REMAINDER_MJ")
 container.loadPersistentStores(completionHandler: { (storeDescription, error) in
 if let error = error as NSError? {
 // Replace this implementation with code to handle the error appropriately.
 // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
 
 /*
 Typical reasons for an error here include:
 * The parent directory does not exist, cannot be created, or disallows writing.
 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
 * The device is out of space.
 * The store could not be migrated to the current model version.
 Check the error message to determine what the actual problem was.
 */
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
 // Replace this implementation with code to handle the error appropriately.
 // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
 let nserror = error as NSError
 fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
 }
 }
 }
 */
