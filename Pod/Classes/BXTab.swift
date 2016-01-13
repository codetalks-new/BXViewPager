//
//  BXTab.swift
//  BXViewPager
//
//  Created by Haizhen Lee on 15/11/18.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

// MARK: BXTab Model
public class BXTab{
  public static let INVALID_POSITION = -1
  
  public var tag:AnyObject?
  public var icon:UIImage?
  public var text:String?
  public var contentDesc:String?
  public var badgeValue:String?
  
  public var position = BXTab.INVALID_POSITION
  
  public init(text:String?,icon:UIImage? = nil){
    self.text = text
    self.icon = icon
  }
}