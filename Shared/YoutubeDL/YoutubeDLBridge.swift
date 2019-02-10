//
//  YoutubeDLBridge.swift
//  YT Music Player CLI
//
//  Created by mxa on 12.09.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Foundation
import Python

struct YoutubeDLBridge {
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
    
    func getVideoURL(pageURL: String, format: String) -> URL? {
        let videoInfo = self.getVideoInfo(pageURL: pageURL)
        let videoFormats = videoInfo["formats"] as! [String: String]
        let urlString = videoFormats[format]!
        return URL(string: urlString)
    }
    
    func getVideoInfo(pageURL: String) -> [String: Any] {
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
        
        let videoInfo = pyVideoInfo!.swiftValue!
        
    //        videoInfo.keys.forEach { key in
    //            let val = videoInfo[key]!
    //            Swift.print("\(key):", Swift.type(of: val))
    //        }
        
        return videoInfo
    }
    
    func downloadVideo(url: String, format: String, to destination: String) {
        self.getVideoURL(pageURL: url, format: format)
    }

    
//    func downloadVideo(url: String, options: YoutubeDL.Options? = nil, to destination: String) {
////        let options = options ?? YoutubeDL.Options()
//
//        let options = YoutubeDL.Options(format: "bestaudio", progressCallback: progressCallback)
//        guard
//            let submodule = self.module.submodule(name: "YoutubeDL", with: options.dict),
//            let downloadFunction = submodule.function(name: "download")
//        else {
//            dprint("Can't obtain YoutubeDL.download() function.")
//            fatalError()
//        }
//        exit(0)
//
//        let url = Python.String("https://www.youtube.com/watch?v=BaW_jenozKc")
//        let urlList = Python.List([url])
////        let storagePath = Python.String("/Users/mxa/testvideo.mp4")
////        let progressCallback = Python.None
//
//        let _: Python.String? = downloadFunction.call(with: urlList)
////        let callResult: Python.String? = downloadFunction.call(with: urlList)
////        dprint(callResult?.description)
////        return (callResult != nil)
//    }
    
//    func testCSwiftAPIUsage() {
//        let apiTestModule = Python.Module(name: "c_api_test")!
//        let function = apiTestModule.function(name: "dump_var")!
//
//        let testCallResult: Python.String? = function.call(with: progressCallback)
//        print(testCallResult!.description)
//    }
}

func progressCallback(a: PythonObjectPointer?, b: PythonObjectPointer?) -> PythonObjectPointer? {
    dprint("a", Python.String(raw: PyObject_Repr(a)!)!.swiftValue)
    dprint("b", Python.String(raw: PyObject_Repr(b)!)!.swiftValue)
    
    return nil
}

