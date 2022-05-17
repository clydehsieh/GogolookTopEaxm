//
//  MainCoordinator.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/15.
//

import UIKit
import SafariServices

enum FlowError: Error {
    case invalidateURL
}

class MainCoordinator: Coordinator {
    var childs: [Coordinator] = []
    var navigationController: UINavigationController

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ItemListViewControllerProvider.viewController
        vc.coordinator = self
        navigationController.viewControllers = [vc]
    }
}

extension MainCoordinator {
    func openURL(url: URL?) throws {
        guard let url = url else {
            throw FlowError.invalidateURL
        }
        
        if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            let vc = SFSafariViewController(url: url)
            navigationController.present(vc, animated: true, completion: nil)
        } 
    }
}
