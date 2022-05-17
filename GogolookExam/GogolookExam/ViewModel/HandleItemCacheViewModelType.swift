//
//  HandleItemCacheViewModelType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit

enum HandleItemCacheResult {
    case saved(malID: Int)
    case deleted(malID: Int)
    case failure(error: Error)
}

protocol HandleItemCacheViewModelType {
    func handle(data: ItemTableViewCellConfigurable, completion: @escaping ((HandleItemCacheResult)->Void)) throws
}
