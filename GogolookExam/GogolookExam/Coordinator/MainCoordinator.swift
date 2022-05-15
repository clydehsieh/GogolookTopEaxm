//
//  MainCoordinator.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit

class MainCoordinator: Coordinator {
    var childs: [Coordinator] = []
    var navigationController: UINavigationController

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = AnimeListViewControllerProvider.viewcontroller
        navigationController.viewControllers = [vc]
//        navigationController.pushViewController(vc, animated: false)
    }
}
