//
//  CoreDataStoreType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/18.
//

import UIKit

protocol CoreDataStoreType {
    func insertItemEntityData(data: ItemTableViewCellConfigurable) throws
    
    func fetchItem(malID: Int) throws -> [ItemEntity]
    
    func fetchItems() throws -> [ItemEntity]
    
    func deleteItem(malID: Int) throws
}

