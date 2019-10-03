//
//  List.swift
//  macOS
//
//  Created by mxa on 03.10.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Python3_7

extension Python {
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

    
// MARK: Sequence
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
