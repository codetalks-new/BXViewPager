//
//  BXTabViewController.swift
//  Pods
//
//  Created by Haizhen Lee on 16/1/6.
//
//

import UIKit
import PinAutoLayout


// MARK: UICollectionViewDataSource
extension BXTabViewController:UICollectionViewDataSource{
  
  public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tabs.count
  }
  
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let tab = tabAtIndexPath(indexPath)
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(bx_tab_reuse_identifier, forIndexPath: indexPath) as! BXTabView
    cell.bind(tab)
    return cell
  }
  
}

// MARK BXViewPagerViewController - Helper

extension BXTabViewController{
  
  //  public func addTab(tab:BXTab,index:Int = 0,setSelected:Bool = false){
  //    tabs.insert(tab, atIndex: index)
  //    tabLayout.reloadData()
  //    if(setSelected){
  //      selectTabAtIndex(index)
  //    }
  //
  //  }
  //
  public func selectTabAtIndex(index:Int){
    if tabs.isEmpty{
      return
    }
    let indexPath = NSIndexPath(forItem: index, inSection: 0)
    tabLayout.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
  }
  
  public func tabAtIndexPath(indexPath:NSIndexPath) -> BXTab{
    return tabs[indexPath.item]
  }
  
  public var numberOfTabs:Int{
    return tabs.count
  }
}

// MARK: UICollectionViewDelegateFlowLayout
extension BXTabViewController:UICollectionViewDelegateFlowLayout{
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    showPageAtIndex(indexPath.item)
  }
}




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
  
  
  private var tabLayout:UICollectionView!
  private var containerView:UIView!
  
  private let flowLayout:UICollectionViewFlowLayout = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumInteritemSpacing = 0// TabConstants.minInteritemSpacing
    flowLayout.itemSize = CGSize(width:TabConstants.minItemWidth,height:TabConstants.defaultHeight)
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionInset = UIEdgeInsetsZero
    //      flowLayout.estimatedItemSize = flowLayout.itemSize
    flowLayout.scrollDirection = .Vertical
    return flowLayout
  }()
  public var didSelectedTab: ( (BXTab) -> Void )?
  var tabs: [BXTab] = []
  
  
  public init(){
    super.init(nibName: nil, bundle: nil)
    self.automaticallyAdjustsScrollViewInsets = false
  }
  
  
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  func updateTabs(){
    tabs.removeAll()
    for (index,vc) in self.viewControllers.enumerate() {
      let tab = BXTab(text: vc.title)
      tab.position = index
      tabs.append(tab)
    }
  }
  
  
  public override func loadView() {
    super.loadView()
    containerView = UIView()
    
    tabLayout = {
      let tabLayout = UICollectionView(frame:CGRect(x: 0, y: 0, width: 320, height: TabConstants.defaultHeight + 4), collectionViewLayout: flowLayout)
      tabLayout.showsHorizontalScrollIndicator = false
      tabLayout.showsVerticalScrollIndicator = false
      tabLayout.scrollEnabled = true
      tabLayout.backgroundColor = UIColor.whiteColor()
      //        tabLayout.backgroundColor = UIColor.purpleColor()
      return tabLayout
      }()
    tabLayout.registerClass(BXTabView.self, forCellWithReuseIdentifier: bx_tab_reuse_identifier)
    tabLayout.delegate = self
    tabLayout.dataSource = self
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
  
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
 
  var currentVisibleController:UIViewController?
  
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    NSLog("\(__FUNCTION__)")
  }
  
  private var hasSelectAny = false
  
  func setupInitialViewController(){
    if hasSelectAny{
      return
    }
    hasSelectAny = true
    recalculateItemSize()
    selectTabAtIndex(0)
    showPageAtIndex(0)
  }
  
  func recalculateItemSize(){
    let sectionInset = flowLayout.sectionInset
    let totalWidth = self.view.bounds.width - flowLayout.minimumInteritemSpacing - sectionInset.left - sectionInset.right
    let itemCount = viewControllers.count
    let itemWidth = floor(totalWidth / CGFloat(itemCount) )
    let itemHeight = flowLayout.itemSize.height
    let itemSize = CGSize(width: itemWidth, height: itemHeight)
    flowLayout.itemSize = itemSize
    
  }
  
  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    NSLog("\(__FUNCTION__) \(view.frame)")
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    NSLog("\(__FUNCTION__) \(view.frame)")
    let space = flowLayout.minimumInteritemSpacing * CGFloat(numberOfTabs - 1)
    let availableWidth = tabLayout.bounds.width - space
    let avgWidth = availableWidth / CGFloat(numberOfTabs)
    let itemWidth = max(avgWidth,TabConstants.minItemWidth)
    let itemSize = CGSize(width: itemWidth, height: TabConstants.defaultHeight)
    flowLayout.itemSize = itemSize
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
