//
//  Tools.swift
//  YoutubeDL
//
//  Created by mxa on 25.12.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Foundation

func dprint(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = file.split(separator: "/").last!
    let functionName = function.split(separator: "(")[0]
    let prefix = "\(fileName)/\(functionName):\(line):"
    let message = items.reduce(prefix) { $0 + separator + String(describing: $1) }
    Swift.print(message, terminator: terminator)
    //    NSLog("%@", message)
    #endif
}

@available(*, unavailable)
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {}

