//
//  Options.swift
//  YoutubeDL
//
//  Created by mxa on 29.01.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Foundation
import Python


extension YoutubeDL {
    struct Options {
        let format: String?
        let progressCallback: PyCFunction?
        let printURL: Bool?
        let skipDownload: Bool?
        
        init(format: String? = nil, progressCallback: PyCFunction? = nil, printURL: Bool? = nil, skipDownload: Bool? = nil) {
            self.format = format
            self.progressCallback = progressCallback
            self.printURL = printURL
            self.skipDownload = skipDownload
        }
        
        /// Returns the set options as a Python dictionary,
        /// as required by youtube-dl.
        var dict: Python.Dict {
            var dict = [String: PythonRepresentable]()
            
            if let format = self.format {
                dict["format"] = Python.String(format)
            }
            
            if let progressCallback = self.progressCallback {
                let function = Python.CFunction(name: "progress_callback", function: progressCallback)!
                dict["progress_hooks"] = Python.List([function])
            }
            
            if let printURL = self.printURL {
                dict["forceurl"] = Python.Bool(printURL)
            }
            
            if let skipDownload = self.skipDownload {
                dict["skip_download"] = Python.Bool(skipDownload)
            }
            
            return Python.Dict(dict)
        }
    }
}
