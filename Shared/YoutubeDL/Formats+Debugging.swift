//
//  Formats+Debugging.swift
//  YoutubeDL
//
//  Created by mxa on 17.03.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

#if DEBUG
extension YoutubeDL.Format.Encoding: CustomStringConvertible {
    var description: String {
        switch self {
        case .audioVideo(let audio, let video):
            return "V: " + video.description + ", A: " + audio.description
        case .audioOnly(let audio):
            return "Audio only: " + audio.description
        case .videoOnly(let video):
            return "Video only: " + video.description
        case .none:
            return "No codec"
        }
    }
}


extension YoutubeDL.Format.Codec: CustomStringConvertible {
    var description: String {
        guard let bitrate = self.bitrate else { return self.name }
        let brString = String(format: "%.0f", bitrate)
        return self.name + " (\(brString) kb/s)"
    }
}
#endif
