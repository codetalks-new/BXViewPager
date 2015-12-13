//
//  DemoListTableViewController.swift
//  BXViewPager
//
//  Created by Haizhen Lee on 15/11/4.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit
import BXViewPager

class DemoListTableViewController: UITableViewController {
    @IBOutlet weak var simpleDemo: UITableViewCell!
    @IBOutlet weak var simpleTabLayout: UITableViewCell!
   

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        switch cell{
        case simpleDemo:
            showSimpleDemo()
            break
        default:
            break
        }
    }
    
    
    func showSimpleDemo(){
        var vcs = [UIViewController]()
        for index in 1...5 {
           let vc = ShowTitleViewController(title: "Tab \(index)")
            vcs.append(vc)
        }
        let viewPagerVC = BXViewPagerViewController()
      viewPagerVC.setViewControllers(vcs, animated: true)
        showViewController(viewPagerVC, sender: self)
        
    }
}

class ShowTitleViewController: UIViewController{
    
    init(title:String){
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRectZero)
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        } else {
            label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        }
        self.view.addSubview(label)
        label.pinCenter()
    }
}