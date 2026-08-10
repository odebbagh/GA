//
//  UILabel+phone.swift
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___
//  ___COPYRIGHT___

import UIKit
import QMobileUI

extension UILabel {

    @objc dynamic var secondeToTime: NSNumber? {
        get {
            return nil
        }
        set {
            guard let number = newValue else {
                self.text = nil
                return
            }
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute]
            formatter.unitsStyle = .full

            self.text = formatter.string(from: TimeInterval(number))
        }
    }
}
