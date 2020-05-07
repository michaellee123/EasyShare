//
//  AppDelegate.swift
//  EasyShare
//
//  Created by Michael Lee on 2020/5/2.
//  Copyright © 2020 Michael Lee. All rights reserved.
//

import Cocoa
import SwiftUI
import ShareExtension

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        Window(windowNibName: "Window").showWindow(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

