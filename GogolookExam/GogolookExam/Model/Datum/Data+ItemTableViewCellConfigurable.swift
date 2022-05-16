//
//  Data+ItemTableViewCellConfigurable.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

extension Datum: ItemTableViewCellConfigurable {
    var videoURL: URL? {
        URL(string: url)
    }
    
    var imageURL: URL? {
        
        guard let image = images["jpg"] else {
            return nil
        }
        return URL(string: image.imageURL)
    }
    
    var rate: String? {
        "\(rank)"
    }
    var start: String? {
        aired?.from?.dateTimeInStr
    }
    var end: String? {
        aired?.to?.dateTimeInStr
    }
}
