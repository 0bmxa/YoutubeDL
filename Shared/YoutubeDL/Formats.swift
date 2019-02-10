//
//  Formats.swift
//  macOS
//
//  Created by mxa on 10.02.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Foundation

extension YoutubeDL {
    struct Format {
        let url: String?
        let audioCodec: String?
        let videoCodec: String?
        let name: String?
        let fileSize: Int?
        let fileExt: String?
        let formatID: String?
        let quality: Int?
        
        // Maybe irrelvant?
        let downloaderOptions: [String: PythonRepresentable]?
        let abr: Int?
        let tbr: Double?
        let playerURL: String?
        
        init(_ dict: [String: PythonRepresentable]) {
            self.url               = (dict["url"] as? Python.UnicodeString)?.swiftValue
            self.audioCodec        = (dict["acodec"] as? Python.String)?.swiftValue
            self.videoCodec        = (dict["vcodec"] as? Python.UnicodeString)?.swiftValue
            self.name              = (dict["format_note"] as? Python.UnicodeString)?.swiftValue
            self.fileSize          = (dict["filesize"] as? Python.Int)?.swiftValue
            self.fileExt           = (dict["ext"] as? Python.UnicodeString)?.swiftValue
            self.formatID          = (dict["format_id"] as? Python.UnicodeString)?.swiftValue
            self.quality           = (dict["quality"] as? Python.Int)?.swiftValue
            
            // Maybe irrelvant?
            self.downloaderOptions = (dict["downloader_options"] as? Python.Dict)?.swiftValue
            self.abr               = (dict["abr"] as? Python.Int)?.swiftValue
            self.tbr               = (dict["tbr"] as? Python.Float)?.swiftValue
            self.playerURL         = (dict["player_url"] as? Python.UnicodeString)?.swiftValue
        }
    }
}
