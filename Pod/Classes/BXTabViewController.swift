//
//  BXTabViewController.swift
//  Pods
//
//  Created by Haizhen Lee on 16/1/6.
//
//

import UIKit
import PinAutoLayout



public class BXTabViewController: BXTabLayoutViewController{
 
  var currentVisibleController:UIViewController?

  public override var currentPageViewController:UIViewController?{
    return currentVisibleController
  }
  
  public override func showPageAtIndex(index:Int){
    if viewControllers.isEmpty{
      return
    }
    let currentIndex = currentPageIndex() ?? -1
    if currentIndex == index{
      return
      
    }
    
    let direction:UIPageViewControllerNavigationDirection = index > currentIndex ? .Forward:.Reverse
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
//    containerView.addSubview(newVC.view) // 至少 iOS 9 transitionFromViewController 时 会自动添加
    newVC.view.frame = newViewStartFrame(navigationDirection)
    let oldEndFrame = oldViewEndFrame(navigationDirection)
    let newEndFrame = oldVC.view.frame
    
    transitionFromViewController(oldVC, toViewController: newVC, duration: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
      // Animate the views to their final positions
        newVC.view.frame = newEndFrame
        oldVC.view.frame = oldEndFrame
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
