//
//  CoreDataStore.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit
import CoreData

class CoreDataStore {

    private static let modelName: String = "FavoriteModel"
    
    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    init() {
        let container = NSPersistentContainer.init(name: CoreDataStore.modelName)
        container.loadPersistentStores { (storeDescriptoin, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        self.container = container
        self.context = container.newBackgroundContext()
    }
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
}

extension CoreDataStore {
    func insertItemEntityData(data: ItemTableViewCellConfigurable) throws {
        try performSync({ context in
            Result {
                
                if let _ = try ItemEntity.fetchFavoriteItems(malID: data.malID, in: context).first {
                    debugPrint("item \(data.malID) exist")
                } else {
                    let _ = ItemEntity.newInstance(malID: data.malID,
                                                   title: data.title ?? "",
                                                   url: data.videoURL?.absoluteString,
                                                   imageURL: data.imageURL?.absoluteString,
                                                   rank: data.rank,
                                                   start: data.start,
                                                   end: data.end,
                                                   in: context)
                    try context.save()
                }
            }
        })
    }
    
    func fetchItem(malID: Int) throws -> [ItemEntity] {
        try performSync({ context in
            Result {
                try ItemEntity.fetchFavoriteItems(malID: malID, in: context)
            }
        })
    }
    
    func fetchItems() throws -> [ItemEntity] {
        try performSync({ context in
            Result {
                try ItemEntity.fetchFavoriteItems(malID: nil, in: context)
            }
        })
    }
    
    func deleteItem(malID: Int) throws {
        try performSync({ context in
            Result {
                try ItemEntity.deleteItem(malID: malID, in: context)
            }
        })
    }
}
