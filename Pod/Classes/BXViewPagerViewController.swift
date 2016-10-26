//
//  BXViewPagerViewController.swift
//  Pods
//
//  Created by Haizhen Lee on 15/11/4.
//
//

import UIKit
import PinAuto

struct TabConstants{
  static let minInteritemSpacing : CGFloat = 8
  static let minItemWidth: CGFloat = 64
}

public struct TabLayoutDefaultOptions{
  public static var defaultHeight : CGFloat = 44
}


// MARK: UIPageViewControllerDataSource
extension BXViewPagerViewController:UIPageViewControllerDataSource{
  // MARK: UIPageViewController DataSource
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
    if let index =  viewControllers.index(of: viewController) , index > 0{
      let prevIndex = (index - 1)
      return viewControllers[prevIndex]
    }
    return nil
    
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
    if let index = viewControllers.index(of: viewController) , index < (viewControllers.endIndex - 1){
      return viewControllers[(index + 1)]
    }
    return nil
  }
  
}

open class BXViewPagerViewController: BXTabLayoutViewController{
  
  
  open let pageController =  UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
  
    override open func viewDidLoad() {
        super.viewDidLoad()
        pageController.dataSource = self
        pageController.delegate = self
        addChildControllerToContainer(pageController)
        containerView.gestureRecognizers = pageController.gestureRecognizers
    }
  


// MARK: PageController Helper
  
    open override var currentPageViewController:UIViewController?{
      return pageController.viewControllers?.first
    }
  
    open override func showPageAtIndex(_ index:Int){
      if viewControllers.isEmpty{
        return
      }
        let currentIndex = currentPageIndex() ?? -1
        let direction:UIPageViewControllerNavigationDirection = index > currentIndex ? .forward:.reverse
        let initControllers = [ viewControllers[index] ]
        pageController.setViewControllers(initControllers, direction: direction, animated: true){
            finished in
            NSLog("animation finished ? \(finished)")
        }
    }
}

// MARK: UIPageViewControllerDelegate
extension BXViewPagerViewController: UIPageViewControllerDelegate{
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed{
      if let index = currentPageIndex(){
        tabLayout.selectTabAtIndex(index)
      }
    }
  }
  
  
  public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    
  }
}
