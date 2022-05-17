//
//  String+Extension.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/17.
//

import UIKit

extension String {
    var url: URL? {
        URL(string: self)
    }
}
