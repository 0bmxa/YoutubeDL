//
//  Py.swift
//  YoutubeDL
//
//  Created by mxa on 23.09.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Python

typealias PythonObjectPointer = UnsafeMutablePointer<PyObject>

enum Python {
    enum Run {
        @discardableResult
        static func string(_ pythonCodeString: Swift.String) -> Int32 {
            let cString = pythonCodeString.withCString { $0 }
            let compilerFlags: UnsafeMutablePointer<PyCompilerFlags>! = nil
            let success = PyRun_SimpleStringFlags(cString, compilerFlags)
            assert(success == 0)
            return success
        }
    }
    
    static var version: Swift.String {
        return Swift.String(cString: Py_GetVersion())
    }
}



protocol PythonRepresentable: CustomStringConvertible {
    var pyObject: PythonObjectPointer { get }
    init?(raw: PythonObjectPointer)
}

// MARK: - CustomStringConvertible
extension PythonRepresentable {
    var description: Swift.String {
        let optionalPyObject: PythonObjectPointer? = self.pyObject
        guard let pyObject = optionalPyObject else {
//            return "[Python.Null Object]"
            return "nil"
        }
        let stringRep = PyObject_Repr(self.pyObject)!
        
        let content = Python.String(raw: stringRep)!.swiftValue ?? "?"
        let name = "Python.\(type(of: self))"
        return name + ": " + content
    }
}

protocol PythonSwiftConvertible {
    associatedtype SwiftType
    var swiftValue: SwiftType { get }
}

protocol PythonSwiftOptionalConvertible {
    associatedtype SwiftType
    var swiftValue: SwiftType? { get }
}


