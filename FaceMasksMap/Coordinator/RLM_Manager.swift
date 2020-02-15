//
//  RLM_Manager.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/15.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import RealmSwift

typealias RealmCompletionHander = (() -> Void)?
typealias RealmFailHandler = ((Error) -> Void)?

protocol RLM_Manageable {
    func fetch<T: Object>(type: T.Type) -> [T]
    func add<T: Object>(object: T,
                        completionHandler: RealmCompletionHander, failHandler: RealmFailHandler)
    func delete<T: Object>(object: T,
                           completionHandler: RealmCompletionHander, failHandler: RealmFailHandler)
    func delete<T: Object>(type: T.Type,
                           primaryKey: Any,
                           completionHandler: RealmCompletionHander, failHandler: RealmFailHandler)
    func delete<T: Object>(objects: [T],
                           completionHandler: RealmCompletionHander, failHandler: RealmFailHandler)
}

class RLM_Manager {
    static let shared = RLM_Manager()
    
    private var realm: Realm?
    
    private init() {
        do {
            var confiugre = Realm.Configuration()
            confiugre.fileURL = confiugre.fileURL?.deletingLastPathComponent().appendingPathComponent("faceMasksMap.realm")
            Realm.Configuration.defaultConfiguration = confiugre
            try self.realm = Realm()
            print("Realm database path: \(self.realm?.configuration.fileURL?.absoluteString ?? "無路徑")")
        } catch let error {
            print("Realm database initializer failed: \(error.localizedDescription)")
        }
    }
}

extension RLM_Manager: RLM_Manageable {
    private func execute(_ block: () -> Void, failHandler: RealmFailHandler) {
        do {
            try self.realm?.write(block)
        } catch {
            failHandler?(error)
        }
    }
    
    func fetch<T: Object>(type: T.Type) -> [T]  {
        guard let objects = self.realm?.objects(type) else { return [] }
        return Array(objects)
    }
    
    func add<T: Object>(object: T, completionHandler: RealmCompletionHander, failHandler: RealmFailHandler) {
        self.execute({
            self.realm?.add(object)
        }, failHandler: failHandler)
    }
    
    func delete<T: Object>(object: T, completionHandler: RealmCompletionHander, failHandler: RealmFailHandler) {
        self.execute({
            self.realm?.delete(object)
            completionHandler?()
        }, failHandler: failHandler)
    }
    
    func delete<T: Object>(type: T.Type, primaryKey: Any, completionHandler: RealmCompletionHander, failHandler: RealmFailHandler)  {
        guard let object = self.realm?.object(ofType: type, forPrimaryKey: primaryKey) else { return }
        self.delete(object: object, completionHandler: completionHandler, failHandler: failHandler)
    }
    
    func delete<T: Object>(objects: [T], completionHandler: RealmCompletionHander, failHandler: RealmFailHandler) {
        self.execute({
            self.realm?.delete(objects)
            completionHandler?()
        }, failHandler: failHandler)
    }
    
    
}
