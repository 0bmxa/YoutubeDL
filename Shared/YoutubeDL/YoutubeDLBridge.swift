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
    
    internal func getVideoInfo(pageURL: String) -> [String: PythonRepresentable]? {
        guard
            let submodule = self.module.submodule(name: "YoutubeDL"),
            let extractInfoFunction = submodule.function(name: "extract_info")
        else {
            dprint("Can't obtain YoutubeDL.extract_info() function.")
            fatalError()
        }
        
        let pURL = Python.String(pageURL)
        let pDownload = Python.Bool(false)
        let pIEKey = Python.None()
        let pExtraInfo = Python.Dict([:])
        let pProcess = Python.Bool(false)
        let pForceGenericExtractor = Python.Bool(false)

        let pyVideoInfo: Python.Dict? = extractInfoFunction.call(with: pURL, pDownload, pIEKey, pExtraInfo, pProcess, pForceGenericExtractor)
        return pyVideoInfo?.swiftValue
    }
    
    private func getFormats(from videoInfo: [String: PythonRepresentable]) -> [YoutubeDL.Format]? {
        // Get formats list from video info as Swift array
        let pyVideoFormatsList = videoInfo["formats"] as? Python.List
        let videoFormatsDicts = pyVideoFormatsList?.swiftValue as? [Python.Dict]
        
        // Convert to format structures
        let formats: [YoutubeDL.Format]? = videoFormatsDicts?.compactMap {
            guard let dict = $0.swiftValue else { assertionFailure(); return nil }
            return YoutubeDL.Format(dict)
        }
        
        return formats
    }
    
    internal func downloadVideo(from url: URL, formatID: String, to destination: String) {
        // Get video info from youtube-dl for specified webpage
        guard let videoInfo = self.getVideoInfo(pageURL: url.absoluteString) else { fatalError() }
        
        let formats = self.getFormats(from: videoInfo)
        
        formats?.forEach{
            Swift.print("Format", $0.name!, "(", $0.fileExt!, ")\thas ID:", $0.formatID!)
        }
        
//        // Find requested format
//        let matchedFormat = formats?.first { $0.formatID == formatID }
//
//        // Return URL, if found
//        guard let matchedFormatURL = matchedFormat?.url else { return nil }
//        URL(string: matchedFormatURL)
//        dprint(url)
    }


    
//    func testCSwiftAPIUsage() {
//        let apiTestModule = Python.Module(name: "c_api_test")!
//        let function = apiTestModule.function(name: "dump_var")!
//
//        let testCallResult: Python.String? = function.call(with: progressCallback)
//        print(testCallResult!.description)
//    }
}

//func progressCallback(a: PythonObjectPointer?, b: PythonObjectPointer?) -> PythonObjectPointer? {
//    dprint("a", Python.String(raw: PyObject_Repr(a)!)!.swiftValue)
//    dprint("b", Python.String(raw: PyObject_Repr(b)!)!.swiftValue)
//
//    return nil
//}
