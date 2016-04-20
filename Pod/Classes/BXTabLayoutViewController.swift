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
      if isViewLoaded() && self.view.window != nil{
        setupInitialViewController()
      }
    }
  }
  
  public func setViewControllers(viewControllers: [UIViewController], animated: Bool){
    self.viewControllers = viewControllers
  }
  
  
  public lazy private(set) var tabLayout : BXTabLayout = {
    let tabLayout = BXTabLayout()
    tabLayout.backgroundColor = UIColor.whiteColor()
    return tabLayout
  }()
  
  internal let containerView:UIView = UIView()
  
  
  public var didSelectedTab: ( (BXTab) -> Void )?
  
  public var showIndicator:Bool{
    get{
      return tabLayout.showIndicator
    }set{
      tabLayout.showIndicator = newValue
    }
  }
  
  
  func updateTabs(){
    if useCustomTabs{
      return
    }
    var tabs:[BXTab] = []
    for (index,vc) in self.viewControllers.enumerate() {
      let tab = BXTab(text: vc.title)
      tab.position = index
      tabs.append(tab)
    }
    tabLayout.updateTabs(tabs)
  }
 
  private var useCustomTabs = false
  public func updateTabs(tabs:[BXTab]){
    useCustomTabs = true
   tabLayout.updateTabs(tabs)
  }
 
  
  public var tabLayoutHeight:CGFloat{
    get{
      return tabLayoutHeightContraint?.constant ?? TabLayoutDefaultOptions.defaultHeight
    }set{
      tabLayoutHeightContraint?.constant = newValue
    }
  }
  
  public private(set) var tabLayoutHeightContraint:NSLayoutConstraint?
  public private(set) var tabLayoutLeadingConstraint:NSLayoutConstraint?
  public private(set) var tabLayoutTrailingConstraint:NSLayoutConstraint?
  
  public override func loadView() {
    super.loadView()
     self.automaticallyAdjustsScrollViewInsets = false
    tabLayout.registerClass(BXTabView.self)
    //
    self.view.addSubview(tabLayout)
    tabLayout.translatesAutoresizingMaskIntoConstraints = false
    tabLayout.pa_below(topLayoutGuide).install()
    tabLayoutLeadingConstraint =  tabLayout.pa_leading.eq(0).install()
    tabLayoutTrailingConstraint =  tabLayout.pa_trailing.eq(0).install()
    tabLayoutHeightContraint = tabLayout.pa_height.eq(TabLayoutDefaultOptions.defaultHeight).install()
    
    
    self.view.addSubview(containerView)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.pac_horizontal(0)
    containerView.pa_below(tabLayout,offset:0).install()
    containerView.pa_above(bottomLayoutGuide).install()
    
    
    containerView.backgroundColor = UIColor.whiteColor()
  }
  
  func addChildControllerToContainer(controller:UIViewController){
    addChildViewController(controller)
    containerView.addSubview(controller.view)
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    controller.view.pac_edge()
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
    
    tabLayout.selectTabAtIndex(0)
    showPageAtIndex(0)
  }
  
  

  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    NSLog("\(#function)")
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    NSLog("\(#function)")
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
