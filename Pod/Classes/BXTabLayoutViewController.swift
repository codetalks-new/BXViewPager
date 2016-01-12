//
//  BXBaseTabViewController.swift
//  Pods
//
//  Created by Haizhen Lee on 16/1/12.
//
//

import UIKit

public class BXTabLayoutViewController:UIViewController{
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public init(){
    super.init(nibName: nil, bundle: nil)
   
  }
  

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public private(set) var viewControllers: [UIViewController] = []{
    didSet{
      updateTabs()
      if isViewLoaded(){
        setupInitialViewController()
      }
    }
  }
  
  public func setViewControllers(viewControllers: [UIViewController], animated: Bool){
    self.viewControllers = viewControllers
  }
  
  
  internal lazy var tabLayout : BXTabLayout = {
    let tabLayout = BXTabLayout()

    tabLayout.backgroundColor = UIColor.whiteColor()
    return tabLayout
  }()
  
  internal let containerView:UIView = UIView()
  
  
  public var didSelectedTab: ( (BXTab) -> Void )?
  

  
  func updateTabs(){
    var tabs:[BXTab] = []
    for (index,vc) in self.viewControllers.enumerate() {
      let tab = BXTab(text: vc.title)
      tab.position = index
      tabs.append(tab)
    }
    tabLayout.updateTabs(tabs)
  }
  
  
  public override func loadView() {
    super.loadView()
     self.automaticallyAdjustsScrollViewInsets = false
    tabLayout.registerClass(BXTabView.self)
    //
    self.view.addSubview(tabLayout)
    tabLayout.translatesAutoresizingMaskIntoConstraints = false
    pinTopLayoutGuide(tabLayout)
    tabLayout.pinHorizontal(0)
    tabLayout.pinHeight(TabConstants.defaultHeight)
    
    
    self.view.addSubview(containerView)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.pinHorizontal(0)
    containerView.pinBelowSibling(tabLayout,margin:0)
    pinBottomLayoutGuide(containerView)
    
    
    containerView.backgroundColor = UIColor.whiteColor()
  }
  
  func addChildControllerToContainer(controller:UIViewController){
    addChildViewController(controller)
    containerView.addSubview(controller.view)
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    controller.view.pinEdge(UIEdgeInsetsZero)
    controller.didMoveToParentViewController(self)
  }

  override public func viewDidLoad(){
    super.viewDidLoad()
    tabLayout.didSelectedTab = {
      tab in
      self.showPageAtIndex(tab.position)
    }
  
  }
  
  func recalculateItemSize(){
    tabLayout.updateItemSize()
  }
  
  private var hasSelectAny = false
  
  func setupInitialViewController(){
    if hasSelectAny{
      return
    }
    hasSelectAny = true
    recalculateItemSize()
    tabLayout.selectTabAtIndex(0)
    showPageAtIndex(0)
  }
  
  

  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    recalculateItemSize()
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if viewControllers.count > 0 {
      setupInitialViewController()
    }
  }
  
  
  // MARK: Abstract Method
  public func currentPageIndex() -> Int?{
    guard let currentVC = currentPageViewController else{
      return nil
    }
    return  viewControllers.indexOf(currentVC)
  }
  
  public func showPageAtIndex(index:Int){
    fatalError("Should Override this")
  }
  
  public var currentPageViewController:UIViewController?{
    fatalError("Should Override this")
  }
  
  
}
