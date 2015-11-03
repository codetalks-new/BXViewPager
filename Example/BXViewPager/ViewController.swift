//
//  ViewController.swift
//  BXViewPager
//
//  Created by banxi1988 on 11/03/2015.
//  Copyright (c) 2015 banxi1988. All rights reserved.
//

import UIKit
import BXViewPager
import PinAutoLayout

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabs = [
            BXTab(text:"Tab 1"),
            BXTab(text:"Tab 2"),
            BXTab(text:"Tab 3"),
            BXTab(text:"Tab 4"),
        ]
        let tabLayout = BXTabLayout(tabs: tabs)
        tabLayout.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tabLayout)
        self.pinTopLayoutGuide(tabLayout)
        tabLayout.pinHorizontal(0)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

