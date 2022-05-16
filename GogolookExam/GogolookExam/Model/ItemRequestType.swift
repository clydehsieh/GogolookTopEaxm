//
//  RequestType.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

protocol ItemRequestType {
    var type: String? { get }
    var filter: String? { get }
    var page: Int { get }
}

protocol RequestTypePresentable {
    var value: String? { get }
}

protocol RequestFilterPresentable {
    var value: String? { get }
}
