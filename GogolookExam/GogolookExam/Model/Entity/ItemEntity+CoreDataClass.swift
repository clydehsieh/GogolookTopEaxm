//
//  ItemEntity+CoreDataClass.swift
//  
//
//  Created by ClydeHsieh on 2022/5/17.
//
//

import Foundation
import CoreData

@objc(ItemEntity)
public class ItemEntity: NSManagedObject {
    static func newInstance(malID: Int,
                            title: String?,
                            url: String?,
                            imageURL: String?,
                            rank: Int?,
                            start: Date?,
                            end: Date?, in context: NSManagedObjectContext) -> ItemEntity {
        let item = ItemEntity(context: context)
        item.malID = Int64(malID)
        item.title = title
        item.url   = url
        item.imageURL = imageURL
        item.rank = Int16(rank ?? 0)
        item.start = start
        item.end = end
        return item
    }
    
    static func fetchFavoriteItems(malID: Int?, in context: NSManagedObjectContext) throws -> [ItemEntity] {
        let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        if let malID = malID {
            let predicate = NSPredicate(format: "malID == %d", malID)
            request.predicate = predicate
        }

        return try context.fetch(request)
    }
    
    static func deleteItem(malID: Int?, in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<NSFetchRequestResult> = ItemEntity.fetchRequest()
        if let malID = malID {
            let predicate = NSPredicate(format: "malID == %d", malID)
            request.predicate = predicate
        }
        
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(delete)
    }
}
