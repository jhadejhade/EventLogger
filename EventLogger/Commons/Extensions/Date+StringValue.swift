//
//  Date+StringValue.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

import Foundation

extension Date {
    enum Format: String {
        case mmddyyyy_hhmm_a = "MM/dd/yy hh:mm a"
    }
    
    func toStringValue(with format: Format = .mmddyyyy_hhmm_a) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self)
    }
}
