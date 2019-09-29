//
//  BridgeTypes.swift
//  SwiftPython
//
//  Created by mxa on 17.03.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Python3_7

// MARK: - PythonRepresentable
protocol PythonRepresentable: CustomStringConvertible {
    var pyObject: PythonObjectPointer { get }
    init?(raw: PythonObjectPointer)
}

// MARK: CustomStringConvertible
extension PythonRepresentable {
    var description: Swift.String {
        let optionalPyObject: PythonObjectPointer? = self.pyObject
        return (optionalPyObject != nil) ? pyObject.description : "nil"
    }
}


// MARK: - PythonObjectPointer
typealias PythonObjectPointer = UnsafeMutablePointer<PyObject>

extension PythonObjectPointer {
    var type: PythonRepresentable.Type? {
        if self == &_Py_NoneStruct {
            return Python.None.self
        }
        
        let objectType = self.pointee.ob_type
        switch objectType {
        case &PyBool_Type:    return Python.Bool.self
        case &PyDict_Type:    return Python.Dict.self
        case &PyList_Type:    return Python.List.self
        case &PyLong_Type:    return Python.Int.self
        case &PyUnicode_Type: return Python.String.self
        case &PyTuple_Type:   return Python.Tuple.self
        case &PyFloat_Type:   return Python.Float.self
            
        default:
            dprint("\nType not supported:", self.typeName!, "\n")
            assertionFailure()
            return nil
        }
    }
    
    var typeName: Swift.String? {
        guard let typeName = self.pointee.ob_type.pointee.tp_name else { return nil }
        return Swift.String(cString: typeName)
    }
}

extension PythonObjectPointer: CustomStringConvertible {
    public var description: Swift.String {
        let stringRep = PyObject_Repr(self)!
        let content = Python.String(raw: stringRep)!.swiftValue
        return "Python.\(self.type!): \(content)"
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
