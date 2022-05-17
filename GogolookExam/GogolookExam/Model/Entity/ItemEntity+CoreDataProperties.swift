//
//  ItemEntity+CoreDataProperties.swift
//  
//
//  Created by ClydeHsieh on 2022/5/17.
//
//

import Foundation
import CoreData


extension ItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemEntity> {
        return NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
    }

    @NSManaged public var malID: Int64
    @NSManaged public var url: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var rank: Int16
    @NSManaged public var start: Date?
    @NSManaged public var end: Date?
    @NSManaged public var title: String?

}
