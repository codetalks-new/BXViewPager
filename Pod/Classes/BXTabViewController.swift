//
//  BXTabViewController.swift
//  Pods
//
//  Created by Haizhen Lee on 16/1/6.
//
//

import UIKit
import PinAutoLayout



public class BXTabViewController: UIViewController,UIGestureRecognizerDelegate{
  public var viewControllers: [UIViewController] = []{
    didSet{
      updateTabs()
      if isViewLoaded(){
        setupInitialViewController()
      }
    }
  }
  // If the number of view controllers is greater than the number displayable by a tab bar, a "More" navigation controller will automatically be shown.
  // The "More" navigation controller will not be returned by -viewControllers, but it may be returned by -selectedViewController.
  public func setViewControllers(viewControllers: [UIViewController], animated: Bool){
    self.viewControllers = viewControllers
    
  }
  
  //  unowned(unsafe) public var selectedViewController: UIViewController? // This may return the "More" navigation controller if it exists.
  //  public var selectedIndex: Int
  
  //  public var moreNavigationController: UINavigationController { get } // Returns the "More" navigation controller, creating it if it does not already exist.
  //  public var customizableViewControllers: [UIViewController]? // If non-nil, then the "More" view will include an "Edit" button that displays customization UI for the specified controllers. By default, all view controllers are customizable.
  
  //  public var tabBar: UITabBar { get } // Provided for -[UIActionSheet showFromTabBar:]. Attempting to modify the contents of the tab bar directly will throw an exception.
  
  //  weak public var delegate: UITabBarControllerDelegate?
  
  
  private lazy var tabLayout : BXTabLayout = {
    let tabLayout = BXTabLayout()
    tabLayout.showsHorizontalScrollIndicator = false
    tabLayout.showsVerticalScrollIndicator = false
    tabLayout.scrollEnabled = true
    tabLayout.backgroundColor = UIColor.whiteColor()
    return tabLayout
  }()
  
  public var tabLayoutHeight:CGFloat = TabConstants.defaultHeight
  
  private var containerView:UIView!
  
  public private(set) var pageController:UIPageViewController!
  
  public var didSelectedTab: ( (BXTab) -> Void )?
  
  public init(){
    super.init(nibName: nil, bundle: nil)
    self.automaticallyAdjustsScrollViewInsets = false
  }
  
  
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
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
    containerView = UIView()
    pageController =  UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    tabLayout.registerClass(BXTabView.self)
    //
    self.view.addSubview(tabLayout)
    tabLayout.translatesAutoresizingMaskIntoConstraints = false
    pinTopLayoutGuide(tabLayout)
    tabLayout.pinHorizontal(0)
    tabLayout.pinHeight(tabLayoutHeight)
    
    
    self.view.addSubview(containerView)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.pinHorizontal(0)
    containerView.pinBelowSibling(tabLayout,margin:0)
    pinBottomLayoutGuide(containerView)
    
    
    containerView.backgroundColor = UIColor.whiteColor()
  }
  
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
 
  var currentVisibleController:UIViewController?
  
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    NSLog("\(__FUNCTION__)")
    tabLayout.didSelectedTab = {
      tab in
      self.showPageAtIndex(tab.position)
    }
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
  
  func recalculateItemSize(){
   tabLayout.updateItemSize()
  }
  
  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    NSLog("\(__FUNCTION__) \(view.frame)")
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    NSLog("\(__FUNCTION__) \(view.frame)")
    tabLayout.updateItemSize()
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if viewControllers.count > 0 {
      setupInitialViewController()
    }
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    NSLog("\(__FUNCTION__)")
    
  }
  
}


// MARK: PageController Helper
extension BXTabViewController{
  
  func currentPageIndex() -> Int?{
    guard let currentVC = currentVisibleController else{
      return nil
    }
    return  viewControllers.indexOf(currentVC)
  }
  
  private func showPageAtIndex(index:Int){
    if viewControllers.isEmpty{
      return
    }
    let currentIndex = currentPageIndex() ?? -1
    let direction:UIPageViewControllerNavigationDirection = index > currentIndex ? .Forward:.Reverse
    let nextVC = viewControllers[index]
    guard let prevVC = currentVisibleController else{
      displayTabViewController(nextVC)
      return
    }
    switchFromViewController(prevVC, toViewController: nextVC,navigationDirection: direction)
    
  }
 
  func newViewStartFrame(direction:UIPageViewControllerNavigationDirection) -> CGRect{
    let frame = containerView.bounds
    if direction == .Forward{
      return frame.offsetBy(dx: frame.width, dy: 0)
    }else{
      return frame.offsetBy(dx:-frame.width, dy: 0)
    }
  }
  
  func oldViewEndFrame(direction:UIPageViewControllerNavigationDirection) -> CGRect{
    let frame = containerView.bounds
    if direction == .Forward{
      return frame.offsetBy(dx: -frame.width, dy: 0)
    }else{
      return frame.offsetBy(dx:frame.width, dy: 0)
    }
  }
  
  
  func switchFromViewController(oldVC:UIViewController,toViewController newVC:UIViewController,navigationDirection:UIPageViewControllerNavigationDirection = .Forward){
    // Prepare the two view controllers for the change.
    oldVC.willMoveToParentViewController(nil)
    self.addChildViewController(newVC)
    
    // Get the start frame of the new view controller and the end frame
    // for the old view controller. Both rectangles are offscreen
    containerView.addSubview(newVC.view)
    newVC.view.frame = newViewStartFrame(navigationDirection)
    let endFrame = oldViewEndFrame(navigationDirection)
    
    
    transitionFromViewController(oldVC, toViewController: newVC, duration: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
      // Animate the views to their final positions
        newVC.view.frame = oldVC.view.frame
        oldVC.view.frame = endFrame
      }) { (finished) -> Void in
        // Remove the old view Controller and send the final
        // notification to the new view Controller
        oldVC.view.removeFromSuperview()
        oldVC.removeFromParentViewController()
        newVC.didMoveToParentViewController(self)
        self.currentVisibleController = newVC
        
    }
  }
  
  private func displayTabViewController(controller:UIViewController){
    addChildViewController(controller)
    controller.view.frame = frameForTabViewController
    self.containerView.addSubview(controller.view)
    controller.didMoveToParentViewController(self)
    self.currentVisibleController = controller
  }
  
  private var frameForTabViewController:CGRect{
    return containerView.bounds
  
  }
  
}
