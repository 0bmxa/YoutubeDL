//
//  BridgeTypes.swift
//  SwiftPython
//
//  Created by mxa on 17.03.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Python2_7

typealias PythonObjectPointer = UnsafeMutablePointer<PyObject>

protocol PythonRepresentable: CustomStringConvertible {
    var pyObject: PythonObjectPointer { get }
    init?(raw: PythonObjectPointer)
}

// MARK: - CustomStringConvertible
extension PythonRepresentable {
    var description: Swift.String {
        let optionalPyObject: PythonObjectPointer? = self.pyObject
        guard let pyObject = optionalPyObject else {
            return "nil"
        }
        let stringRep = PyObject_Repr(pyObject)!
        let content = Python.String(raw: stringRep)!.swiftValue
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
