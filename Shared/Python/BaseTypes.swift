//
//  BaseTypes.swift
//  SwiftPython
//
//  Created by mxa on 23.09.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Python3_7

// MARK: - Simple Types
extension Python {
    class None: PythonRepresentable {
        var pyObject: PythonObjectPointer
        required convenience init?(raw: PythonObjectPointer) { self.init() }
        deinit { Py_DecRef(self.pyObject) }
        
        init() {
            self.pyObject = withUnsafeMutablePointer(to: &_Py_NoneStruct) { $0 }
            Py_IncRef(self.pyObject)
        }
    }
    
    class Bool: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init?(raw: PythonObjectPointer) {
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ swiftBool: Swift.Bool) {
            self.pyObject = PyBool_FromLong(swiftBool ? 1 : 0)
        }
        
        // MARK: - PythonSwiftConvertible
        typealias SwiftType = Swift.Bool
        var swiftValue: SwiftType {
            let int = PyLong_AsLong(self.pyObject)
            return (int != 0)
        }
    }
    
    class Int: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init?(raw: PythonObjectPointer) {
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ swiftInt: Swift.Int) {
            self.pyObject = PyLong_FromLong(swiftInt)
        }
        
        // MARK: - PythonSwiftConvertible
        typealias SwiftType = Swift.Int
        var swiftValue: SwiftType {
            return PyLong_AsLong(self.pyObject)
        }
    }
    
    typealias Double = Float
    class Float: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init?(raw: PythonObjectPointer) {
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ swiftDouble: Swift.Double) {
            self.pyObject = PyFloat_FromDouble(swiftDouble)
        }
        
        // MARK: - PythonSwiftConvertible
        typealias SwiftType = Swift.Double
        var swiftValue: SwiftType {
            return PyFloat_AsDouble(self.pyObject)
        }
        
        var swiftFloatValue: Swift.Float {
            return Swift.Float(self.swiftValue)
        }
        
    }

    class String: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init?(raw: PythonObjectPointer) {
            guard Python.type(of: raw) == Python.String.self else { assertionFailure(); return nil }
            self.pyObject = raw
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ value: Swift.String) {
            let cString = value.withCString { $0 }
            self.pyObject = PyUnicode_FromString(cString)
        }
        
        // MARK: - PythonSwiftConvertible
        typealias SwiftType = Swift.String
        var swiftValue: SwiftType {
            let cString = PyUnicode_AsUTF8(self.pyObject)!
            return Swift.String(cString: cString)
        }
    }
    
    typealias UnicodeString = Python.String
}


// MARK: - Collection types
extension Python {
    class Tuple: PythonRepresentable {
        let pyObject: PythonObjectPointer
        required init?(raw: PythonObjectPointer) {
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
    
    class Dict: PythonRepresentable, PythonSwiftOptionalConvertible {
        let pyObject: PythonObjectPointer
        required init?(raw: PythonObjectPointer) {
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ values: [Swift.String: PythonRepresentable]) {
            self.pyObject = PyDict_New()
            
            values.forEach {
                PyDict_SetItemString(self.pyObject, $0.key, $0.value.pyObject)
            }
        }
        
        // MARK: - PythonSwiftConvertible
        typealias SwiftType = [Swift.String: PythonRepresentable]
        var swiftValue: SwiftType? {
            guard
                let keysPointer = PyDict_Keys(self.pyObject),
                let keys = Python.List(raw: keysPointer)
            else { assertionFailure(); return nil }
            
            var swiftDict = SwiftType()
            for index in (0..<keys.count) {
                guard
                    let key = keys[index],
                    let keyString = Python.UnicodeString(raw: key.pyObject)
                else { assertionFailure(); continue }
                let val = self[keyString]
                swiftDict[keyString.swiftValue] = val
            }
            
            return swiftDict
        }
        
        subscript(key: Swift.String) -> PythonRepresentable! {
            let pyKey = Python.UnicodeString(key)
            return self[pyKey]
        }

        subscript(key: Python.UnicodeString) -> PythonRepresentable? {
            guard let pyItem = PyDict_GetItem(self.pyObject, key.pyObject) else {
                assertionFailure(); return nil
            }
            let pyItemType = Python.type(of: pyItem)
            return pyItemType?.init(raw: pyItem)
        }
    }
    
    typealias Array = List
    class List: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init?(raw: PythonObjectPointer) {
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ values: [PythonRepresentable]) {
            self.pyObject = PyList_New(values.count)
            
            values.enumerated().forEach {
                PyList_SetItem(self.pyObject, $0.offset, $0.element.pyObject)
            }
        }
        
        var count: Swift.Int {
            return PyList_Size(self.pyObject)
        }
        
        subscript(index: Swift.Int) -> PythonRepresentable? {
            guard let pyItem = PyList_GetItem(self.pyObject, index) else {
                assertionFailure(); return nil
            }
            let pyItemType = Python.type(of: pyItem)
            return pyItemType?.init(raw: pyItem)!
        }
        
        // MARK: - PythonSwiftConvertible
        typealias SwiftType = [PythonRepresentable?]
        var swiftValue: SwiftType {
            let length = PyList_Size(self.pyObject)
            let indices = (0..<length)
            
            return indices.map { index -> PythonRepresentable? in
                guard let pyItem = PyList_GetItem(self.pyObject, index) else { assertionFailure(); return nil }
                let pyItemType = Python.type(of: pyItem)
                return pyItemType?.init(raw: pyItem)
            }
        }
    }
}

/*
func PyList_SET_ITEM(op: PythonObjectPointer, i: Py_ssize_t, v: PythonObjectPointer) {
    let listOP = op.withMemoryRebound(to: PyListObject.self, capacity: 1) { $0 }
    listOP.pointee.ob_item[i] = v
}
*/

extension Python {
    static func type(of pyObject: PythonObjectPointer) -> PythonRepresentable.Type? {
        if pyObject == &_Py_NoneStruct {
            return Python.None.self
        }
        

        
        let objectType = pyObject.pointee.ob_type
        switch objectType {
        case &PyBool_Type:    return Python.Bool.self
        case &PyDict_Type:    return Python.Dict.self
        case &PyList_Type:    return Python.List.self
        case &PyLong_Type:    return Python.Int.self
        case &PyUnicode_Type: return Python.String.self
        case &PyTuple_Type:   return Python.Tuple.self
        case &PyFloat_Type:   return Python.Float.self
            
        default:
            let name = Swift.String(cString: pyObject.pointee.ob_type.pointee.tp_name!)
            dprint("Type not supported:", name)
            assertionFailure()
            return nil
        }
    }
}


extension Python {
//    typealias PyCFunction =
//        @convention(c) (PythonObjectPointer?, PythonObjectPointer?) -> PythonObjectPointer?

    static func callback(name: Swift.String, function: @escaping PyCFunction) -> PyMethodDef {
        let name = name.withCString { return $0 }
        return PyMethodDef(
            ml_name: name,
            ml_meth: function,
            ml_flags: METH_VARARGS,
            ml_doc: nil
        )
    }
    
    
    class CFunction: PythonRepresentable {
        var pyObject: PythonObjectPointer
        required init?(raw: PythonObjectPointer) { self.pyObject = raw }
        deinit { Py_DecRef(self.pyObject) }
        
        init?(name: Swift.String, function: @escaping PyCFunction) {
            let name = name.withCString { return $0 }
            var pyMethod = PyMethodDef(
                ml_name: name,
                ml_meth: function,
                ml_flags: METH_VARARGS,
                ml_doc: nil
            )
            guard let pyFunction = PyCFunction_NewEx(&pyMethod, nil, nil) else { return nil }
            self.pyObject = pyFunction
        }
    }
}
