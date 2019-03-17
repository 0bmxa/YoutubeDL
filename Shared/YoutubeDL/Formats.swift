//
//  Formats.swift
//  YoutubeDL
//
//  Created by mxa on 10.02.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Foundation

extension YoutubeDL {
    struct Format {
        let name: String?
        let formatID: String?
        let encoding: Encoding
        let fileExtension: String?
        let url: String?
        let fileSize: Int?
        let quality: Int?
        let downloaderOptions: [String: PythonRepresentable]?
        let playerURL: String?
        
        init(_ dict: [String: PythonRepresentable]) {
            self.name              = (dict["format_note"] as? Python.UnicodeString)?.swiftValue
            self.formatID          = (dict["format_id"] as? Python.UnicodeString)?.swiftValue
            self.fileExtension     = (dict["ext"] as? Python.UnicodeString)?.swiftValue
            self.url               = (dict["url"] as? Python.UnicodeString)?.swiftValue
            self.fileSize          = (dict["filesize"] as? Python.Int)?.swiftValue
            self.quality           = (dict["quality"] as? Python.Int)?.swiftValue
            self.downloaderOptions = (dict["downloader_options"] as? Python.Dict)?.swiftValue
            self.playerURL         = (dict["player_url"] as? Python.UnicodeString)?.swiftValue

            let audioCodec   = (dict["acodec"] as? Python.UnicodeString)?.swiftValue
            let videoCodec   = (dict["vcodec"] as? Python.UnicodeString)?.swiftValue
            let videoBitrate = (dict["tbr"] as? Python.Float)?.swiftFloatValue
            var audioBitrate: Float?
            if let abr = (dict["abr"] as? Python.Int)?.swiftValue {
                audioBitrate = Float(abr)
            }
            self.encoding = Encoding(audioCodec: audioCodec, videoCodec: videoCodec, audioBitrate: audioBitrate, videoBitrate: videoBitrate)
        }
    }
}


// MARK: - A/V Encoding & Codecs
extension YoutubeDL.Format {
    enum Encoding {
        case audioVideo(audio: Codec, video: Codec)
        case audioOnly(Codec)
        case videoOnly(Codec)
        case none
        
        init(audioCodec: String?, videoCodec: String?, audioBitrate: Float?, videoBitrate: Float?) {
            // Audio & Video
            if  let audio = audioCodec, audio != "none",
                let video = videoCodec, video != "none" {
                self = .audioVideo(audio: Codec(name: audio, bitrate: audioBitrate), video: Codec(name: video, bitrate: videoBitrate))

            // Audio only
            } else if let audio = audioCodec, audio != "none" {
                self = .audioOnly(Codec(name: audio, bitrate: audioBitrate))
                
            // Video only
            } else if let video = videoCodec, video != "none" {
                self = .videoOnly(Codec(name: video, bitrate: videoBitrate))
                
            // Neither
            } else {
                self = .none
            }
        }
    }
    
    struct Codec {
        let name: String
        let bitrate: Float? // probably kBit/s
    }
}

