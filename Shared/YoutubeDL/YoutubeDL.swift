//
//  YoutubeDL.swift
//  YoutubeDL
//
//  Created by mxa on 23.09.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

//import Foundation

class YoutubeDL {
    init() {
        let youtubeDL = YoutubeDLBridge()
        youtubeDL.downloadVideo(url: "https://www.youtube.com/watch?v=BaW_jenozKc", format: "bestaudio", to: "nil")
    }
    
    
    func progressUpdate(data: [AnyHashable: Any]?) {
        dprint("PROGRESS:", data?.reduce("", { $0 + "\($1.key): \($1.value)" }))
    }
}
