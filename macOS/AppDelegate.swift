//
//  AppDelegate.swift
//  YoutubeDL
//
//  Created by mxa on 31.01.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let youtubeDL = YoutubeDL()


    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let url = URL(string: "https://www.youtube.com/watch?v=BaW_jenozKc")!
        self.youtubeDL.downloadVideo(from: url, formatID: "bestaudio", to: "nil")

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

