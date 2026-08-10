//
//  ___TABLE___ListForm.swift
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___
//  ___COPYRIGHT___

import UIKit
import QMobileUI

/// Generated list form for ___TABLE___ table.
@IBDesignable
class ___TABLE___ListForm: ListForm___LISTFORMTYPE___ {

    // Do not edit name or override tableName
    public override var tableName: String {
        return "___TABLE___"
    }

    // MARK: Events
    override func onLoad() {
        // Do any additional setup after loading the view.
    }

    override func onWillAppear(_ animated: Bool) {
        // Called when the view is about to made visible. Default does nothing
    }

    override func onDidAppear(_ animated: Bool) {
        // Called when the view has been fully transitioned onto the screen. Default does nothing
    }

    override func onWillDisappear(_ animated: Bool) {
        // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
    }

    override func onDidDisappear(_ animated: Bool) {
        // Called after the view was dismissed, covered or otherwise hidden. Default does nothing
    }

    // Temporary fix color of swipe action text by forcing one
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        super.tableView(tableView, willBeginEditingRowAt: indexPath)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            tableView.cellForRow(at: indexPath)?.layoutIfNeeded()
        }
    }
}

import IBAnimatable
class ___TABLE___ViewCell: AnimatableTableViewCell {
    
    /* open override func layoutSubviews() {
        super.layoutSubviews()
        cellActionButtonLabel?.forEach { $0.textColor = .black } // you color goes here
    } */
    open override func layoutIfNeeded() {
        super.layoutIfNeeded()
        cellActionButton?.forEach { $0.tintColor = .black }
        cellActionButtonLabel?.forEach { $0.textColor = .black } // you color goes here
    }
}
fileprivate extension UITableViewCell {
    var cellActionButtonLabel: [UILabel]? {
        superview?.subviews
            .filter { String(describing: $0).range(of: "UISwipeActionPullView") != nil }
            .flatMap { $0.subviews }
            .filter { String(describing: $0).range(of: "UISwipeActionStandardButton") != nil }
            .flatMap { $0.subviews }
            .compactMap { $0 as? UILabel }
    }
    var cellActionButton: [UIButton]? {
        superview?.subviews
            .filter { String(describing: $0).range(of: "UISwipeActionPullView") != nil }
            .flatMap { $0.subviews }
            .compactMap { $0 as? UIButton }
    }
}
