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

// MARK: UICollectionViewDataSource
extension BXViewPagerViewController:UICollectionViewDataSource{

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

extension BXViewPagerViewController{
  
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




public let bx_tab_reuse_identifier = "bx_tabCell"
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
  
  
    private var tabLayout:UICollectionView!
    private var containerView:UIView!
    
    private var pageController:UIPageViewController!
  private let flowLayout:UICollectionViewFlowLayout = {
      let flowLayout = UICollectionViewFlowLayout()
      flowLayout.minimumInteritemSpacing = TabConstants.minInteritemSpacing
      flowLayout.itemSize = CGSize(width:TabConstants.minItemWidth,height:TabConstants.defaultHeight)
      flowLayout.minimumLineSpacing = 0
      flowLayout.sectionInset = UIEdgeInsetsZero
//      flowLayout.estimatedItemSize = flowLayout.itemSize
      flowLayout.scrollDirection = .Horizontal
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
        pageController =  UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
      
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
        tabLayout.pinHeight(TabConstants.defaultHeight + 4)
        
        
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
    }
  
  func setupInitialViewController(){
        selectTabAtIndex(0)
        showPageAtIndex(0)
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
extension BXViewPagerViewController{
  
    func currentPageIndex() -> Int?{
        guard let currentVC = pageController.viewControllers?.first else {
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
        selectTabAtIndex(index)
      }
    }
  }
  
  
  public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
    
  }
}
