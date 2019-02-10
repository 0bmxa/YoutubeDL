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
    
    func getVideoInfo(pageURL: String) -> [String: PythonRepresentable]? {
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
    
    func getFormats(from videoInfo: [String: PythonRepresentable]) -> [YoutubeDL.Format]? {
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
    
    func downloadVideo(from url: URL, formatID: String, to destination: String) {
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

func progressCallback(a: PythonObjectPointer?, b: PythonObjectPointer?) -> PythonObjectPointer? {
    dprint("a", Python.String(raw: PyObject_Repr(a)!)!.swiftValue)
    dprint("b", Python.String(raw: PyObject_Repr(b)!)!.swiftValue)
    
    return nil
}

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
