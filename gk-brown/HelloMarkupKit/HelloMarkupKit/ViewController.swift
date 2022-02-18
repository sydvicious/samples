//
//  ViewController.swift
//  HelloMarkupKit
//
//  Created by Syd Polk on 7/5/17.
//  Copyright © 2017 Bone Jarring Games and Software. All rights reserved.
//

import UIKit
import MarkupKit

class ViewController: UIViewController {
    
    @IBOutlet var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        LMViewBuilder.view(withName: "ViewController", owner: self, root: view)
    }

    @IBAction func sayHello() {
        greetingLabel.text = "Hello, World!"
    }

}

