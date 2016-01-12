//
//  BXViewPagerViewController.swift
//  Pods
//
//  Created by Haizhen Lee on 15/11/4.
//
//

import UIKit
import PinAutoLayout

struct TabConstants{
  static let defaultHeight : CGFloat = 44
  static let minInteritemSpacing : CGFloat = 8
  static let minItemWidth: CGFloat = 64
}

// MARK: UICollectionViewDelegateFlowLayout
extension BXViewPagerViewController:UICollectionViewDelegateFlowLayout{
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    showPageAtIndex(indexPath.item)
  }
}

// MARK: UIPageViewControllerDataSource
extension BXViewPagerViewController:UIPageViewControllerDataSource{
  // MARK: UIPageViewController DataSource
  public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
    if let index =  viewControllers.indexOf(viewController) where index > 0{
      let prevIndex = index.predecessor()
      return viewControllers[prevIndex]
    }
    return nil
    
  }
  
  public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
    if let index = viewControllers.indexOf(viewController) where index < viewControllers.endIndex.predecessor(){
      return viewControllers[index.successor()]
    }
    return nil
  }
  
}




public class BXViewPagerViewController: UIViewController,UIGestureRecognizerDelegate{
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
  
  
  var customPanGestureRcognizer: UIPanGestureRecognizer?
  
  func onPan(sender:UIPanGestureRecognizer){
    NSLog("OnPan")
  }
  
  public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if  pageController.gestureRecognizers.contains(otherGestureRecognizer){
      return true
    }
    return false
  }

    override public func viewDidLoad() {
        super.viewDidLoad()
        pageController.dataSource = self
        pageController.delegate = self
        addChildViewController(pageController)
        containerView.addSubview(pageController.view)
        pageController.view.pinEdge(UIEdgeInsetsZero)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageController.didMoveToParentViewController(self)
        containerView.gestureRecognizers = pageController.gestureRecognizers
        NSLog("\(__FUNCTION__)")
      
        //
        customPanGestureRcognizer = UIPanGestureRecognizer(target: self, action: "onPan:")
        customPanGestureRcognizer?.delegate = self
        containerView.addGestureRecognizer(customPanGestureRcognizer!)
      
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
      recalculateItemSize()
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
extension BXViewPagerViewController{
  
    func currentPageIndex() -> Int?{
        guard let currentVC = pageController.viewControllers?.first else {
            return nil
        }
        return  viewControllers.indexOf(currentVC)
    }
  
    public var currentPageViewController:UIViewController?{
      return pageController.viewControllers?.first
    }
  
    private func showPageAtIndex(index:Int){
      if viewControllers.isEmpty{
        return
      }
        let currentIndex = currentPageIndex() ?? -1
        let direction:UIPageViewControllerNavigationDirection = index > currentIndex ? .Forward:.Reverse
        let initControllers = [ viewControllers[index] ]
        pageController.setViewControllers(initControllers, direction: direction, animated: true){
            finished in
            NSLog("animation finished ? \(finished)")
        }
    }
}

// MARK: UIPageViewControllerDelegate
extension BXViewPagerViewController: UIPageViewControllerDelegate{
  public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed{
      if let index = currentPageIndex(){
        tabLayout.selectTabAtIndex(index)
      }
    }
  }
  
  
  public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
    
  }
}
