//
//  Coordinator.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit

protocol Coordinator: AnyObject {
    var childs: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func add(child: Coordinator)
    func remove(child: Coordinator)
    func removeAll()
    
    init(_ navigationController: UINavigationController)
    func start()
}


extension Coordinator {
    func add(child: Coordinator) {
        guard !childs.contains(where: { $0 === child }) else {
            return
        }
        childs.append(child)
    }

    func remove(child: Coordinator) {
        guard let index = childs.firstIndex(where: { $0 === child }) else {
            return
        }
        childs.remove(at: index)
    }

    func removeAll() {
        childs.removeAll()
    }
}
