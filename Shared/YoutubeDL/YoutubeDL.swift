//
//  YoutubeDL.swift
//  YoutubeDL
//
//  Created by mxa on 12.09.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Foundation
import Python

struct YoutubeDL {
    var module: Python.Module
    
    init() {
        Python.initialize()
        dprint("Initialized Python", Python.version);
        
        guard let resourcePath = Bundle.main.resourcePath else { fatalError() }
        let modulePath = resourcePath.appending("/python_libs")
        
        var pathAppendPyCode = "import sys\n"
        pathAppendPyCode += "sys.path.append('\(modulePath)')\n"
        Python.Run.string(pathAppendPyCode)

        guard let module = Python.Module(name: "youtube_dl") else { fatalError() }
        self.module = module
    }
    
    internal func getVideoInfo(pageURL: URL) -> VideoInfo? {
        guard
            let submodule = self.module.submodule(name: "YoutubeDL"),
            let extractInfoFunction = submodule.function(name: "extract_info")
        else {
            dprint("Can't obtain YoutubeDL.extract_info() function.")
            fatalError()
        }
        
        let argURL = Python.String(pageURL.absoluteString)
        let argDownload = Python.Bool(false)
        let argIEKey = Python.None()
        let argExtraInfo = Python.Dict([:])
        let argProcess = Python.Bool(false)
        let argForceGenericExtractor = Python.Bool(false)

        let pyVideoInfo: Python.Dict? = extractInfoFunction.call(with: argURL, argDownload, argIEKey, argExtraInfo, argProcess, argForceGenericExtractor)
        
        if let pyVideoInfo = pyVideoInfo {
            return VideoInfo(pyVideoInfo)
        }
        
        assertionFailure();
        return nil
    }
}
