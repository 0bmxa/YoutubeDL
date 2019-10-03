//
//  Dictionary.swift
//  macOS
//
//  Created by mxa on 30.09.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Python3_7

extension Python {
    class Dict: PythonRepresentable {
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
    }
}

extension Python.Dict: PythonSwiftOptionalConvertible {
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
