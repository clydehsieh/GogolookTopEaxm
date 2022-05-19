//
//  RequestType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

protocol ItemRequestType {
    var listType: ItemListType { get }
    var type: String? { get }
    var filter: String? { get }
    var page: Int { get }
}

extension ItemRequestType {
    func apiSuffixString() -> String {
        var suffixArray: [String] = []
        if let type = type {
            suffixArray.append("type=\(type)")
        }
        if let filter = filter {
            suffixArray.append("filter=\(filter)")
        }
        suffixArray.append("page=\(page)")
        
        let suffixString = suffixArray.joined(separator: "&")
        
        return suffixString
    }
}

protocol RequestTypePresentable {
    var value: String? { get }
}

protocol RequestFilterPresentable {
    var value: String? { get }
}
