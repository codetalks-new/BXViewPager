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

public class BXViewPagerViewController: BXTabLayoutViewController{
  
  
  public let pageController =  UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
  
    override public func viewDidLoad() {
        super.viewDidLoad()
        pageController.dataSource = self
        pageController.delegate = self
        addChildControllerToContainer(pageController)
        containerView.gestureRecognizers = pageController.gestureRecognizers
    }
  


// MARK: PageController Helper
  
    public override var currentPageViewController:UIViewController?{
      return pageController.viewControllers?.first
    }
  
    public override func showPageAtIndex(index:Int){
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
