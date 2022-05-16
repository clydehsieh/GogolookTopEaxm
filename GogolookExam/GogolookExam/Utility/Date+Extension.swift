//
//  Date+Extension.swift
//  GogolookExam
//
//  Created by ClydeHsieh on 2022/5/16.
//

import UIKit

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.timeZone = .current
    df.calendar = Calendar(identifier: .gregorian)
    df.locale = .current
    return df
}()

extension Date {
    /// 2016-04-12 18:30
    var dateTimeInStr: String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: self)
    }
}

class OptionalFractionalSecondsDateFormatter: DateFormatter {
    
    private let iso8601DateFormatterWithoutFractionalSeconds = ISO8601DateFormatter()
    
    private let iso8601DateFormatterWithFractionalSeconds: ISO8601DateFormatter = {
        let df = ISO8601DateFormatter()
        df.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return df
    }()
    
    override func date(from string: String) -> Date? {
        return iso8601DateFormatterWithoutFractionalSeconds.date(from: string) ?? iso8601DateFormatterWithFractionalSeconds.date(from: string)
    }
    
}
