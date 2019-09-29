//
//  Module.swift
//  SwiftPython
//
//  Created by mxa on 23.09.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Python3_7

// MARK: - Python Module wrapper
extension Python {
    typealias Function = Module
    typealias Submodule = Module

    class Module: PythonRepresentable {
        let pyObject: PythonObjectPointer
        let name: Swift.String?
        deinit { Py_DecRef(self.pyObject) }

        init?(name: Swift.String) {
            let moduleName = Python.String(name)
            
            guard let module = PyImport_Import(moduleName.pyObject) else {
                dprint("Couldn't find module " + name)
                return nil
            }
            
            self.pyObject = module
            self.name = name
        }

        init?(in module: Python.Module, name: Swift.String) {
            let submoduleName = Python.String(name)
            
            guard let submodule = PyObject_GetAttr(module.pyObject, submoduleName.pyObject) else {
                dprint("Couldn't find function '\(name)' in module \(module.name ?? "[unknown]")")
                return nil
            }
            
            self.pyObject = submodule
            self.name = name
        }

        required init?(raw: PythonObjectPointer) {
            self.pyObject = raw
            self.name = nil
        }
        
        var dict: Python.Dict? {
            guard let pyObject = PyModule_GetDict(self.pyObject) else { return nil }
            return Python.Dict(raw: pyObject)
        }

        

        // MARK: -

        func submodule(name: Swift.String, with arg: PythonRepresentable? = nil, instantiate: Swift.Bool = true) -> Python.Submodule? {
            let submodule = Python.Submodule(in: self, name: name)
            if !instantiate {
                return submodule
            }

            let args = (arg != nil) ? [arg!] : [PythonRepresentable]()
            let instance: Python.Submodule? = submodule?._call(with: args)
            return instance
        }

        func function(name: Swift.String) -> Python.Function? {
            return Python.Function(in: self, name: name)
        }
        
        func call(with args: PythonRepresentable ...) {
            let _: Python.String? = self._call(with: args)
        }

        func call<R: PythonRepresentable>(with args: PythonRepresentable ...) -> R? {
            return self._call(with: args)
        }
        
        private func _call<R: PythonRepresentable>(with args: [PythonRepresentable]) -> R? {
            let _args = Python.Tuple(args)
            //let keywords = PyDict([:])
            let keywords: PythonObjectPointer! = nil
            let result = PyObject_Call(self.pyObject, _args.pyObject, keywords)

            if let result = result {
                return R.init(raw: result)
            }
            return nil
        }
    }
}
