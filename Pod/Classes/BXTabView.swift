//
//  BXTabView.swift
//  BXViewPager
//
//  Created by Haizhen Lee on 15/11/18.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//


//
//  OvalLabel.swift
//  Pods
//
//  Created by Haizhen Lee on 15/12/29.
//
//

import UIKit

public class OvalLabel:UILabel{
  public var horizontalPadding:CGFloat = 4
  public lazy var maskLayer : CAShapeLayer = { [unowned self] in
    let maskLayer = CAShapeLayer()
    maskLayer.frame = self.frame
    self.layer.mask = maskLayer
    return maskLayer
    }()
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    maskLayer.frame = bounds
    maskLayer.path = UIBezierPath(ovalInRect:bounds).CGPath
  }
  
  public override func intrinsicContentSize() -> CGSize {
    let size = super.intrinsicContentSize()
    return CGSize(width: size.width + horizontalPadding, height: size.height + horizontalPadding)
  }
}

import UIKit

// Build for target uimodel
//locale (None, None)
import UIKit

// -BXTabView(m=BXTab):cc
// title[x,b12](f16,cdt);indicator[b0,x,h2]:v

public class BXTabView : BXTabViewCell{
  let titleLabel = UILabel(frame:CGRectZero)
  let badgeLabel = OvalLabel(frame:CGRectZero)

  
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
    if let badgeValue = item.badgeValue{
      badgeLabel.text = badgeValue
      badgeLabel.hidden = false
    }else{
      badgeLabel.hidden = true
    }
  }
  
  override public func awakeFromNib() {
    super.awakeFromNib()
    commonInit()
  }
  
  var allOutlets :[UIView]{
    return [titleLabel,badgeLabel]
  }
  var allUILabelOutlets :[UILabel]{
    return [titleLabel,badgeLabel]
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
    titleLabel.pinCenterY()
    
    badgeLabel.pinAboveSibling(titleLabel, margin: -7)
    badgeLabel.pinLeadingToSibling(titleLabel, margin: -7)
    badgeLabel.pinHeight(17)
    badgeLabel.pinWidthGreaterThanOrEqual(17)
  }
  
  func setupAttrs(){
    titleLabel.textColor = UIColor.darkTextColor()
    titleLabel.font = UIFont.systemFontOfSize(13)
    titleLabel.textAlignment = .Center
    badgeLabel.font = UIFont.systemFontOfSize(10)
    badgeLabel.textColor = UIColor.whiteColor()
    badgeLabel.backgroundColor = UIColor(red: 1.0, green: 0.231372, blue: 0.1881, alpha: 1.0)
    badgeLabel.textAlignment = .Center

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