//
//  Date+String.swift
//  SilverCloud
//
//  Created by Maria Ortega on 05/06/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

extension Date {
     
     static func ISOStringFromDate(date: Date) -> String {
          let options: ISO8601DateFormatter.Options = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone]
          return ISO8601DateFormatter.string(from: date, timeZone: TimeZone(abbreviation: "UTC")!, formatOptions: options)
     }
    
     static func dateFromISOString(string: String) -> Date? {
          let formatter = ISO8601DateFormatter()
          return formatter.date(from: string)
     }

     static func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
          return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
     }
}
