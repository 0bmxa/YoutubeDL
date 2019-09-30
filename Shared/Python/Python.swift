//
//  Python.swift
//  SwiftPython
//
//  Created by mxa on 23.09.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Python3_7


/// A new "Python" namespace
enum Python {
    static var version: Swift.String {
        return Swift.String(cString: Py_GetVersion())
    }
    
    static func initialize() {
        Py_Initialize()
    }
    
    static func finalize() {
        Py_Finalize()
    }
    
    static func extendSysPath(path newPath: Swift.String) {
        let sys = PyImport_ImportModule("sys")
        let sysPath = PyObject_GetAttrString(sys, "path")
        PyList_Append(sysPath, PyUnicode_FromString(newPath))
    }

    /// Executes Python code passed as string in the main module.
    ///
    /// - Parameter string: The string to be executed as Python code.
    /// - Returns: 0 on success, -1 otherwise.
    @discardableResult
    static func run(string pythonCodeString: Swift.String) -> Int32 {
        let cString = pythonCodeString.withCString { $0 }
        let compilerFlags: UnsafeMutablePointer<PyCompilerFlags>! = nil
        return PyRun_SimpleStringFlags(cString, compilerFlags)
    }
}
