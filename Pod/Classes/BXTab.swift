//
//  BXTab.swift
//  BXViewPager
//
//  Created by Haizhen Lee on 15/11/18.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

// MARK: BXTab Model
open class BXTab{
  open static let INVALID_POSITION = -1
  
  open var tag:AnyObject?
  open var icon:UIImage?
  open var text:String?
  open var contentDesc:String?
  open var badgeValue:String?
  
  open var position = BXTab.INVALID_POSITION
  
  public init(text:String?,icon:UIImage? = nil){
    self.text = text
    self.icon = icon
  }
}
