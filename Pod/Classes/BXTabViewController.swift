//
//  BXTabViewController.swift
//  Pods
//
//  Created by Haizhen Lee on 16/1/6.
//
//

import UIKit
import PinAuto



open class BXTabViewController: BXTabLayoutViewController{
 
  var currentVisibleController:UIViewController?

  open override var currentPageViewController:UIViewController?{
    return currentVisibleController
  }
  
  open override func showPageAtIndex(_ index:Int){
    if viewControllers.isEmpty{
      return
    }
    let currentIndex = currentPageIndex() ?? -1
    if currentIndex == index{
      return
      
    }
    
    let direction:UIPageViewControllerNavigationDirection = index > currentIndex ? .forward:.reverse
    let nextVC = viewControllers[index]
    guard let prevVC = currentVisibleController else{
      displayTabViewController(nextVC)
      return
    }
    switchFromViewController(prevVC, toViewController: nextVC,navigationDirection: direction)
    
  }
  
  
  
}


// MARK: PageController Helper
extension BXTabViewController{
  

 
  func newViewStartFrame(_ direction:UIPageViewControllerNavigationDirection) -> CGRect{
    let frame = containerView.bounds
    if direction == .forward{
      return frame.offsetBy(dx: frame.width, dy: 0)
    }else{
      return frame.offsetBy(dx:-frame.width, dy: 0)
    }
  }
  
  func oldViewEndFrame(_ direction:UIPageViewControllerNavigationDirection) -> CGRect{
    let frame = containerView.bounds
    if direction == .forward{
      return frame.offsetBy(dx: -frame.width, dy: 0)
    }else{
      return frame.offsetBy(dx:frame.width, dy: 0)
    }
  }
  
  
  func switchFromViewController(_ oldVC:UIViewController,toViewController newVC:UIViewController,navigationDirection:UIPageViewControllerNavigationDirection = .forward){
    // Prepare the two view controllers for the change.
    oldVC.willMove(toParentViewController: nil)
    self.addChildViewController(newVC)
    
    // Get the start frame of the new view controller and the end frame
    // for the old view controller. Both rectangles are offscreen
//    containerView.addSubview(newVC.view) // 至少 iOS 9 transitionFromViewController 时 会自动添加
    newVC.view.frame = newViewStartFrame(navigationDirection)
    let oldEndFrame = oldViewEndFrame(navigationDirection)
    let newEndFrame = oldVC.view.frame
    
    transition(from: oldVC, to: newVC, duration: 0.25, options: UIViewAnimationOptions(), animations: { () -> Void in
      // Animate the views to their final positions
        newVC.view.frame = newEndFrame
        oldVC.view.frame = oldEndFrame
      }) { (finished) -> Void in
        // Remove the old view Controller and send the final
        // notification to the new view Controller
        oldVC.view.removeFromSuperview()
        oldVC.removeFromParentViewController()
        newVC.didMove(toParentViewController: self)
        self.currentVisibleController = newVC
        
    }
  }
  
  fileprivate func displayTabViewController(_ controller:UIViewController){
    addChildViewController(controller)
    controller.view.frame = frameForTabViewController
    self.containerView.addSubview(controller.view)
    controller.didMove(toParentViewController: self)
    self.currentVisibleController = controller
  }
  
  fileprivate var frameForTabViewController:CGRect{
    return containerView.bounds
  
  }
  
}
