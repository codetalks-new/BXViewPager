//
//  BXTabView.swift
//  BXViewPager
//
//  Created by Haizhen Lee on 15/11/18.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

// Build for target uimodel
//locale (None, None)
import UIKit

// -BXTabView(m=BXTab):cc
// title[x,b12](f16,cdt);indicator[b0,x,h2]:v

public class BXTabView : BXTabViewCell{
  let titleLabel = UILabel(frame:CGRectZero)

  
  private var _normalTitleColor:UIColor?
  private  var _selectedTitleColor:UIColor?
  public dynamic var normalTitleColor:UIColor?{
    get{
      return _normalTitleColor
    }set{
      _normalTitleColor = newValue
      updateTitleLabel()
    }
  }
  
  public dynamic var selectedTitleColor:UIColor?{
    get{
      return _selectedTitleColor
    }set{
      NSLog("setSelectedTitleColor")
      _selectedTitleColor = newValue
      updateTitleLabel()
    }
  }

  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  
  
  public override func bind(item:BXTab){
    titleLabel.text  = item.text
  }
  
  override public func awakeFromNib() {
    super.awakeFromNib()
    commonInit()
  }
  
  var allOutlets :[UIView]{
    return [titleLabel]
  }
  var allUILabelOutlets :[UILabel]{
    return [titleLabel]
  }

  public  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func commonInit(){
    for childView in allOutlets{
      contentView.addSubview(childView)
      childView.translatesAutoresizingMaskIntoConstraints = false
    }
    installConstaints()
    setupAttrs()
    
  }
  
  func installConstaints(){
    titleLabel.pinCenterX()
    titleLabel.pinBottom(10)
  }
  
  func setupAttrs(){
//    backgroundColor = UIColor.whiteColor()
    titleLabel.textColor = UIColor.darkTextColor()
    titleLabel.font = UIFont.systemFontOfSize(13)
    titleLabel.textAlignment = .Center
//    titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

  }
  

  override public var selected:Bool{
    didSet{
      updateTitleLabel()
    }
  }
  
  func updateTitleLabel(){
      let textColor:UIColor
      if selected{
        textColor = selectedTitleColor ?? self.tintColor
      }else{
        textColor = normalTitleColor ?? UIColor.darkTextColor()
      }
      UIView.transitionWithView(titleLabel, duration: 0.3,
        options: UIViewAnimationOptions.TransitionCrossDissolve,
        animations: { () -> Void in
          self.titleLabel.textColor = textColor
        }) { (finished) -> Void in
          
    }
  }
  
}