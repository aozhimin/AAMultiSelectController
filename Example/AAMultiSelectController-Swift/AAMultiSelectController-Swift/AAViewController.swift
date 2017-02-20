//
//  AAViewController.swift
//  AAMultiSelectController-Swift
//
//  Created by dev-aozhimin on 17/2/20.
//  Copyright © 2017年 aozhimin. All rights reserved.
//

import UIKit

private struct TableViewRow {
    static let AATableViewCellTypeNone: Int               = 0
    static let AATableViewCellTypeFadeIn: Int             = 1
    static let AATableViewCellTypeGrowIn: Int             = 2
    static let AATableViewCellTypeShrinkIn: Int           = 3
    static let AATableViewCellTypeSlideInFromTop: Int     = 4
    static let AATableViewCellTypeSlideInFromBottom: Int  = 5
    static let AATableViewCellTypeSlideInFromLeft: Int    = 6
    static let AATableViewCellTypeSlideInFromRight: Int   = 7
    static let AATableViewCellTypeBounceIn: Int           = 8
    static let AATableViewCellTypeBounceInFromTop: Int    = 9
    static let AATableViewCellTypeBounceInFromBottom: Int = 10
    static let AATableViewCellTypeBounceInFromLeft: Int   = 11
    static let AATableViewCellTypeBounceInFromRight: Int  = 12
}

private let TableRowTitles: [Int : String] = [
    TableViewRow.AATableViewCellTypeNone               : "None",
    TableViewRow.AATableViewCellTypeFadeIn             : "FadeIn",
    TableViewRow.AATableViewCellTypeGrowIn             : "GrowIn",
    TableViewRow.AATableViewCellTypeShrinkIn           : "ShrinkIn",
    TableViewRow.AATableViewCellTypeSlideInFromTop     : "SlideInFromTop",
    TableViewRow.AATableViewCellTypeSlideInFromBottom  : "SlideInFromBottom",
    TableViewRow.AATableViewCellTypeSlideInFromLeft    : "SlideInFromLeft",
    TableViewRow.AATableViewCellTypeSlideInFromRight   : "SlideInFromRight",
    TableViewRow.AATableViewCellTypeBounceIn           : "BounceIn",
    TableViewRow.AATableViewCellTypeBounceInFromTop    : "BounceInFromTop",
    TableViewRow.AATableViewCellTypeBounceInFromBottom : "BounceInFromBottom",
    TableViewRow.AATableViewCellTypeBounceInFromLeft   : "BounceInFromLeft",
    TableViewRow.AATableViewCellTypeBounceInFromRight  : "BounceInFromRight"
]

private let OrderTypeDescription = [
    "Objective-C",
    "Swift",
    "Java",
    "Python",
    "PHP",
    "Ruby",
    "JavaScript",
    "Go",
    "Erlang",
    "C",
    "C++",
    "C#",
]

private let kTableViewRowIdentifier: String     = "tableViewCellIdentifier"
private let kMultiSelectViewHeight: CGFloat     = 250
private let kMultiSelectViewWidthRatio: CGFloat = 0.8

public class AAViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var dataArray:[AAMultiSelectModel]! {
        get {
            var data:[AAMultiSelectModel] = []
            
            for (index, element) in OrderTypeDescription.enumerate() {
                let model = AAMultiSelectModel.init()
                model.title = element
                model.multiSelectId = index
                data.append(model)
            }
            return data
        }
    }
    
    private lazy var multiSelectVC: AAMultiSelectViewController = {
        var vc = AAMultiSelectViewController.init()
        vc.title = "Please select a language"
        vc.view.frame = CGRectMake(0, 0,
                                   CGRectGetWidth(self.view.frame) * kMultiSelectViewWidthRatio,
                                   kMultiSelectViewHeight)
        vc.itemTitleColor = UIColor.redColor()
        vc.dataArray = self.dataArray
        vc.confirmBlock = { selectedObjects in
            var message = "You chose:"
            for obj in selectedObjects as! [AAMultiSelectModel] {
                message += "\(obj.title),"
            }
            let alertView: UIAlertView = UIAlertView.init(title: "", message: message, delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "confirm")
            alertView.show()
        }
        return vc
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "AAMultiSelectController-Swift"
    }
    
    // MARK: UITableViewDelegate & UITableViewDataSource
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableRowTitles.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCellWithIdentifier(kTableViewRowIdentifier) as UITableViewCell!
        cell.textLabel?.text = TableRowTitles[indexPath.row]
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.multiSelectVC.popupShowType = AAPopupViewShowType(rawValue: indexPath.row)!
        self.multiSelectVC.popupDismissType = AAPopupViewDismissType(rawValue: indexPath.row)!
        self.multiSelectVC.show()
    }
}
