//
//  BaseTypes.swift
//  SwiftPython
//
//  Created by mxa on 23.09.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Python3_7

// MARK: - None
extension Python {
    class None: PythonRepresentable {
        var pyObject: PythonObjectPointer
        required convenience init(raw: PythonObjectPointer) { self.init() }
        deinit { Py_DecRef(self.pyObject) }
        
        init() {
            self.pyObject = withUnsafeMutablePointer(to: &_Py_NoneStruct) { $0 }
            Py_IncRef(self.pyObject)
        }
    }
}


// MARK: - Bool
extension Python {
    class Bool: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init(raw: PythonObjectPointer) {
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ swiftBool: Swift.Bool) {
            self.pyObject = PyBool_FromLong(swiftBool ? 1 : 0)
        }
        
        // MARK: PythonSwiftConvertible
        typealias SwiftType = Swift.Bool
        var swiftValue: SwiftType {
            let int = PyLong_AsLong(self.pyObject)
            return (int != 0)
        }
    }
}


// MARK: - Int
extension Python {
    class Int: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init(raw: PythonObjectPointer) {
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ swiftInt: Swift.Int) {
            self.pyObject = PyLong_FromLong(swiftInt)
        }
        
        // MARK: PythonSwiftConvertible
        typealias SwiftType = Swift.Int
        var swiftValue: SwiftType {
            return PyLong_AsLong(self.pyObject)
        }
    }
}


// MARK: - Float
extension Python {
    class Float: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init(raw: PythonObjectPointer) {
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ swiftDouble: Swift.Double) {
            self.pyObject = PyFloat_FromDouble(swiftDouble)
        }
        
        // MARK: PythonSwiftConvertible
        typealias SwiftType = Swift.Double
        var swiftValue: SwiftType {
            return PyFloat_AsDouble(self.pyObject)
        }
        
        var swiftFloatValue: Swift.Float {
            return Swift.Float(self.swiftValue)
        }
        
    }
}


// MARK: - String
extension Python {
    class String: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init(raw: PythonObjectPointer) {
            guard raw.type == Python.String.self else { fatalError() }
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ value: Swift.String) {
            let cString = value.withCString { $0 }
            self.pyObject = PyUnicode_FromString(cString)!
        }
        
        // MARK: PythonSwiftConvertible
        typealias SwiftType = Swift.String
        var swiftValue: SwiftType {
            let cString = PyUnicode_AsUTF8(self.pyObject)!
            return Swift.String(cString: cString)
        }
    }
}


// MARK: - Tuple
extension Python {
    class Tuple: PythonRepresentable {
        let pyObject: PythonObjectPointer
        required init(raw: PythonObjectPointer) {
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit { Py_DecRef(self.pyObject) }
        
        convenience init() {
            self.init([])
        }
        
        init(_ values: [PythonRepresentable]) {
            self.pyObject = PyTuple_New(values.count)!
            
            values.enumerated().forEach {
                PyTuple_SetItem(self.pyObject, $0.offset, $0.element.pyObject)
            }
        }
    }
}
