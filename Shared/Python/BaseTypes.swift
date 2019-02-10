//
//  Primitives.swift
//  YoutubeDL
//
//  Created by mxa on 23.09.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Python

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
        
        static func isNone(object: PythonObjectPointer) -> Swift.Bool {
            let nonePointer: PythonObjectPointer = withUnsafeMutablePointer(to: &_Py_NoneStruct) { $0 }
            return object == nonePointer
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
            let int = PyInt_AsLong(self.pyObject)
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
            self.pyObject = PyInt_FromLong(swiftInt)
        }
        
        // MARK: - PythonSwiftConvertible
        typealias SwiftType = Swift.Int
        var swiftValue: SwiftType {
            return PyInt_AsLong(self.pyObject)
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
            self.pyObject = PyString_FromString(cString)
        }
        
        // MARK: - PythonSwiftConvertible
        typealias SwiftType = Swift.String
        var swiftValue: SwiftType {
            let cString = PyString_AsString(self.pyObject)!
            return Swift.String(cString: cString)
        }
        
        var description: Swift.String {
            return "Python.String(\(self.swiftValue))"
        }
    }
    
    class UnicodeString: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init?(raw: PythonObjectPointer) {
            guard Python.type(of: raw) == Python.UnicodeString.self else { assertionFailure(); return nil }
            self.pyObject = raw
        }
        deinit { Py_DecRef(self.pyObject) }
        
        init(_ value: Swift.String) {
            let cString = value.withCString { $0 }
            self.pyObject = PyUnicodeUCS2_FromString(cString)
        }
        
        // MARK: - PythonSwiftConvertible
        typealias SwiftType = Swift.String
        var swiftValue: SwiftType {
            let pyString = PyUnicodeUCS2_AsUTF8String(self.pyObject)!
            let cString = PyString_AsString(pyString)!
            return Swift.String(cString: cString)
        }
        
        var description: Swift.String {
            return "Python.String(\(self.swiftValue))"
        }
    }}


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
//            fatalError("Not implemented")

            guard let keysPointer = PyDict_Keys(self.pyObject) else { assertionFailure(); return nil }
            guard let keys = Python.List(raw: keysPointer)     else { assertionFailure(); return nil }
            
            var swiftDict = SwiftType()
            
            for i in (0..<keys.count) {
                let pyKey = Python.UnicodeString(raw: keys[i].pyObject)!
                let val = self[pyKey]
                swiftDict[pyKey.swiftValue] = val
            }
            
            return swiftDict
        }
        
        subscript(key: Swift.String) -> PythonRepresentable! {
            let pyKey = Python.UnicodeString(key)
            return self[pyKey]
        }

        subscript(key: Python.UnicodeString) -> PythonRepresentable! {
            let pyItem = PyDict_GetItem(self.pyObject, key.pyObject)!
            let pyItemType = Python.type(of: pyItem)
            let item = pyItemType.init(raw: pyItem)!
            return item
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
        
        subscript(index: Swift.Int) -> PythonRepresentable! {
            let pyItem = PyList_GetItem(self.pyObject, index)!
            let pyItemType = Python.type(of: pyItem)
            let item = pyItemType.init(raw: pyItem)!
            return item
        }
        
        // MARK: - PythonSwiftConvertible
        typealias SwiftType = [PythonRepresentable]
        var swiftValue: SwiftType {
            let length = PyList_Size(self.pyObject)
            let array = (0..<length).reduce(SwiftType()) { (previous, index) in
                guard let pyItem = PyList_GetItem(self.pyObject, index) else { assertionFailure(); return previous }
                let pyItemType = Python.type(of: pyItem)
                guard let item = pyItemType.init(raw: pyItem) else { assertionFailure(); return previous }
                return previous + [item]
            }
            return array
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
    static func type(of pyObject: PythonObjectPointer) -> PythonRepresentable.Type {
        let tpFlags = pyObject.pointee.ob_type.pointee.tp_flags

        if tpFlags & Py_TPFLAGS_INT_SUBCLASS != 0 {
            return Python.Int.self
        } else if tpFlags & Py_TPFLAGS_UNICODE_SUBCLASS != 0 {
            return Python.UnicodeString.self
        } else if tpFlags & Py_TPFLAGS_STRING_SUBCLASS != 0 {
            return Python.String.self
        } else if tpFlags & Py_TPFLAGS_LIST_SUBCLASS   != 0 {
            return Python.List.self
        } else if tpFlags & Py_TPFLAGS_TUPLE_SUBCLASS  != 0 {
            return Python.Tuple.self
        } else if tpFlags & Py_TPFLAGS_DICT_SUBCLASS   != 0 {
            return Python.Dict.self
        } else if Python.None.isNone(object: pyObject) {
            return Python.None.self
        } else {
            // Unsupported:
            // - "None" !?!
            // - Py_TPFLAGS_LONG_SUBCLASS,
            // - Py_TPFLAGS_STRING_SUBCLASS
            // - Py_TPFLAGS_BASE_EXC_SUBCLASS
            // - Py_TPFLAGS_TYPE_SUBCLASS
            if tpFlags & Py_TPFLAGS_LONG_SUBCLASS != 0 {
                fatalError()
//            } else if tpFlags & Py_TPFLAGS_STRING_SUBCLASS != 0 {
//                fatalError()
            } else if tpFlags & Py_TPFLAGS_BASE_EXC_SUBCLASS != 0 {
                fatalError()
            } else if tpFlags & Py_TPFLAGS_TYPE_SUBCLASS != 0 {
                fatalError()
            }
            fatalError()
        }
        
    }
}

////// MARK: - Macros
//extension Python {
//    static func checkType(op: PythonObjectPointer, for typeFlag: Swift.Int) -> Bool {
//        return (op.pointee.ob_type.pointee.tp_flags & typeFlag != 0)
//    }
//
////    static func PyInt_Check(op: PythonObjectPointer) -> Bool {
////        return PyType_HasFeature(op.pointee.ob_type, Py_TPFLAGS_INT_SUBCLASS)
////    }
////
////    static func PyType_HasFeature(_ type: UnsafeMutablePointer<_typeobject>, _ flags: Swift.Int) -> Bool {
////        return type.pointee.tp_flags & flags != 0
////    }
//}

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
