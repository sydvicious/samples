//
//  MySplitViewController.swift
//  MasterDetailSwift
//
//  Created by Syd Polk on 2/20/20.
//  Copyright © 2020 Bone Jarring Games and Software. All rights reserved.
//

import UIKit

class MySplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        preferredDisplayMode = .allVisible
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        return true
    }
}
