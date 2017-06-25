//
//  AppDelegate.swift
//  Tricky
//
//  Created by Pillar on 2017/6/11.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import FontAwesomeKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        self.themeAppearanceConfigure()
        self.getNovelFormCache()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let homepage = TKHomepageViewController(nibName: "TKHomepageViewController", bundle: nil);
        let navigation = TKNavigationController(rootViewController: homepage)
        
        self.window?.rootViewController = navigation;
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = UIColor.white
        
        
        
        return true
    }
    
    func getNovelFormCache(){
        TKBookshelfService.sharedInstance.booksFromCache { (oldBooks) in
            if oldBooks != nil{
                print(oldBooks!)
                TKBookshelfService.sharedInstance.books = oldBooks!
                print("读取完毕")
            }else{
                print("失败 。。。")
            }
            
        }
    }
    func themeAppearanceConfigure() -> Void {
        UINavigationBar.appearance().barTintColor = themeBackgroundColor
        UINavigationBar.appearance().tintColor = themeTextColor
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().titleTextAttributes = themeTitleAttributes
        UIBarButtonItem.appearance().setTitleTextAttributes(themeItemTitleAttributes, for: .normal)
        
        let arrowLeftIcon = FAKFontAwesome.angleLeftIcon(withSize: 30)
        arrowLeftIcon?.addAttribute(NSForegroundColorAttributeName, value: themeTextColor)
        
        let arrowLeftImage = arrowLeftIcon?.image(with: CGSize(width: 22, height: 30)).withRenderingMode(UIImageRenderingMode.alwaysOriginal).resizableImage(withCapInsets: UIEdgeInsetsMake(15, 20, 15, 2))

        UIBarButtonItem.appearance().setBackButtonBackgroundImage(arrowLeftImage, for: .normal, barMetrics: .default)
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
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }


}

