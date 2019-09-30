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
        required convenience init(raw: PythonObjectPointer) { self.init() }
        deinit { Py_DecRef(self.pyObject) }
        
        init() {
            self.pyObject = withUnsafeMutablePointer(to: &_Py_NoneStruct) { $0 }
            Py_IncRef(self.pyObject)
        }
    }
    
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
    
    typealias Double = Float
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


// MARK: - Collection types
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
    
    class Dict: PythonRepresentable, PythonSwiftOptionalConvertible {
        let pyObject: PythonObjectPointer
        required init(raw: PythonObjectPointer) {
            self.pyObject = raw
            Py_IncRef(self.pyObject)
        }
        deinit {
            guard self.pyObject.pointee.ob_refcnt > 0 else { return }
            Py_DecRef(self.pyObject)
        }
        
        init(_ values: [Swift.String: PythonRepresentable]) {
            self.pyObject = PyDict_New()
            
            values.forEach {
                PyDict_SetItemString(self.pyObject, $0.key, $0.value.pyObject)
            }
        }
        
        var keys: List {
            let keys = PyDict_Keys(self.pyObject)!
            return Python.List(raw: keys)
        }
        
        
        // MARK: PythonSwiftConvertible
        typealias SwiftType = [Swift.String: PythonRepresentable]
        var swiftValue: SwiftType? {
            let pairs: [(Swift.String, PythonRepresentable)] = self.keys.map {
                let key = Python.String(raw: $0.pyObject)
                let val = self[key] ?? Python.String("[ERROR]")
                return (key.swiftValue, val)
            }
            return SwiftType(uniqueKeysWithValues: pairs)
        }
        
        subscript(key: Swift.String) -> PythonRepresentable? {
            guard let pyItem = PyDict_GetItemString(self.pyObject, key) else { assertionFailure(); return nil }
            return pyItem.representable
        }

        subscript(key: Python.String) -> PythonRepresentable? {
            guard let pyItem = PyDict_GetItem(self.pyObject, key.pyObject) else { assertionFailure(); return nil }
            return pyItem.representable
        }
    }
    
    class List: PythonRepresentable, PythonSwiftConvertible {
        let pyObject: PythonObjectPointer
        required init(raw: PythonObjectPointer) {
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
            return pyItem.representable
        }
        
        // MARK: PythonSwiftConvertible
        typealias SwiftType = [PythonRepresentable?]
        var swiftValue: SwiftType {
            let length = PyList_Size(self.pyObject)
            let indices = (0..<length)
            
            return indices.map { self[$0] }
        }
    }
}

extension Python.List: Sequence {
    typealias Element = PythonRepresentable
    
    func makeIterator() -> Python.List.Iterator {
        return Python.List.Iterator(for: self)
    }

    class Iterator: IteratorProtocol {
        typealias Element = Python.List.Element
        
        private let list: Python.List
        private let listSize: Int
        private var currentIndex: Int = -1
        
        init(for list: Python.List) {
            self.list = list
            self.listSize = list.count
        }
        
        func next() -> Python.List.Element? {
            currentIndex += 1
            guard currentIndex < self.listSize else { return nil }
            return self.list[currentIndex]
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
