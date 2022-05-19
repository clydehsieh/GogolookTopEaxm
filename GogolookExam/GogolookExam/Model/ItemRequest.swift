//
//  ItemRequest.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

struct ItemRequest: ItemRequestType {
    var listType: ItemListType
    var type: String?
    var filter: String?
    var page: Int
}

extension ItemRequest {
    static var defaultConfig: ItemRequest {
        ItemRequest(listType: .defaultType,
                    type: nil,
                    filter: nil,
                    page: 0)
    }
}
