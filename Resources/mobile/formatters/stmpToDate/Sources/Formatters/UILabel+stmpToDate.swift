//
//  UILabel+phone.swift
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___
//  ___COPYRIGHT___

import UIKit
import QMobileUI

extension UILabel {

    @objc dynamic var stmpToDate: NSNumber? {
        get {
            return nil
        }
        set {
            guard let number = newValue else {
                self.text = nil
                return
            }
            var dateComponents = DateComponents()
            dateComponents.year = 2003
            dateComponents.second = number.intValue

            let date = Calendar(identifier: .gregorian).date(from: dateComponents)

            let dateFormatter = DateFormatter()
            // dateFormatter.dateStyle = .medium // .full .short
            // dateFormatter.timeStyle = .medium // .full .short

            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale.init(identifier: Locale.preferredLanguages.first!)
            dateFormatter.setLocalizedDateFormatFromTemplate("ddMMMMyyyy HH:mm")

            self.text = dateFormatter.string(for: date)
            
        }
    }
}
