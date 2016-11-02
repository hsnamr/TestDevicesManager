//
//  AppDelegate.swift
//  JnJCCA
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//

import UIKit
import DATAStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var dataStack: DATAStack = {
        let dataStack = DATAStack(modelName: "JnJCCA")
        
        return dataStack
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let window = self.window {
            let homePage = HomePage(dataStack: self.dataStack)
            window.rootViewController = UINavigationController(rootViewController: homePage)
            window.makeKeyAndVisible()
        }
        
        return true
    }

}

