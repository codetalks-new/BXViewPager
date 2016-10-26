//
//  DemoListTableViewController.swift
//  BXViewPager
//
//  Created by Haizhen Lee on 15/11/4.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit
import BXViewPager
import BXForm
import BXModel

class DemoListTableViewController: UITableViewController {
  var simplePageCell: UITableViewCell = {
    let cell = StaticTableViewCell(style: .default, reuseIdentifier: nil)
    cell.textLabel?.text = "简单的 Tab 样式加 ViewPager 滑动"
    cell.accessoryType = .disclosureIndicator
    return cell
  }()
  
  var withBadgeCell: UITableViewCell = {
    let cell = StaticTableViewCell(style: .default, reuseIdentifier: nil)
    cell.textLabel?.text = "带 Badge 的 Tab"
    cell.accessoryType = .disclosureIndicator
    return cell
  }()
  
  var simpleTabCell: UITableViewCell = {
    let cell = StaticTableViewCell(style: .default, reuseIdentifier: nil)
    cell.textLabel?.text = "Tab 风格 Content 不能滑动"
    cell.accessoryType = .disclosureIndicator
    return cell
  }()
 
  var allCells:[UITableViewCell]{
   return [simplePageCell,withBadgeCell,simpleTabCell]
  }
 
  let adapter = StaticTableViewAdapter()
  override func viewDidLoad() {
    super.viewDidLoad()
    adapter.appendContentsOf(allCells)
    tableView.dataSource = adapter
    tableView.rowHeight = 44
    tableView.tableFooterView = UIView()
  }
  
  func didTapCell(_ cell:UITableViewCell){
        switch cell{
        case simplePageCell:
            showSimpleDemo()
        case withBadgeCell:
          showWithBadgeDemo()
        case simpleTabCell:
          showSimpleTabVC()
        default:
            break
        }
  }
  


  func createTitleVCS(_ count:Int=5) -> [UIViewController]{
    return (1...count).map{ ShowTitleViewController(title: "TAB \($0)") }
  }
  
    
  func showSimpleTabVC(){
    let viewPagerVC = BXTabViewController()
    viewPagerVC.setViewControllers(createTitleVCS(), animated: true)
    show(viewPagerVC, sender: self)
  }
  
  func showSimpleDemo(){
    let viewPagerVC = BXViewPagerViewController()
    viewPagerVC.setViewControllers(createTitleVCS(), animated: true)
      show(viewPagerVC, sender: self)
  }
  
  func showWithBadgeDemo(){
    let viewPagerVC = BXViewPagerViewController()
    let vcs = createTitleVCS()
    viewPagerVC.setViewControllers(vcs, animated: true)
    let tabs = vcs.map{ BXTab(text: $0.title) }
    tabs[2].badgeValue = "63"
    viewPagerVC.updateTabs(tabs)
    show(viewPagerVC, sender: self)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)!
    self.didTapCell(cell)
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
        
        let label = UILabel(frame: CGRect.zero)
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        } else {
            label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        }
        self.view.addSubview(label)
        label.pac_center()
    }
}
