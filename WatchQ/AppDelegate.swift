//
//  AppDelegate.swift
//  WatchQ
//
//  Created by H1-2 on 24/09/2015.
//  Copyright © 2015 Ninja Egg. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var generalResultViewController:GeneralResultViewController?
    var generalResultViewController2:GeneralResultViewController2?
    var petViewController:PetViewController?
    var mainNavigationController : UINavigationController?;
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // 満腹度が０の通知設定
        var notificationActionOk :UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        notificationActionOk.identifier = "challenge"
        notificationActionOk.title = "ペットと遊ぶ"
        notificationActionOk.destructive = false
        notificationActionOk.authenticationRequired = false
        notificationActionOk.activationMode = UIUserNotificationActivationMode.Foreground
        
        
        var notificationActionCancel :UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        notificationActionCancel.identifier = "notnow"
        notificationActionCancel.title = "あとで"
        notificationActionCancel.destructive = true
        notificationActionCancel.authenticationRequired = false
        notificationActionCancel.activationMode = UIUserNotificationActivationMode.Background
        
        var notificationCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        
        notificationCategory.identifier = "WatchQNotification"
        notificationCategory .setActions([notificationActionOk,notificationActionCancel], forContext: UIUserNotificationActionContext.Default)
        notificationCategory .setActions([notificationActionOk,notificationActionCancel], forContext: UIUserNotificationActionContext.Minimal)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: NSSet(array:[notificationCategory]) as? Set<UIUserNotificationCategory> ))
        
        // アプリを終了していた際に、通知からの復帰をチェック
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            
            UIApplication.sharedApplication().cancelAllLocalNotifications();
        }
        
        return true
    }


    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
       /* let alert = UIAlertView();
        alert.title = "WatchQ";
        alert.message = notification.alertBody;
        alert.addButtonWithTitle(notification.alertAction!);
        alert.show();*/
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // アプリがActiveな状態で通知を発生させた場合にも呼ばれるのでActiveでない場合のみ実行するように
        if application.applicationState != .Active {
            UIApplication.sharedApplication().cancelAllLocalNotifications();
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
  
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DataSaver.sharedInstance.saveContext()
    }


}

