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

open class OvalLabel:UILabel{
  open var horizontalPadding:CGFloat = 4
  open lazy var maskLayer : CAShapeLayer = { [unowned self] in
    let maskLayer = CAShapeLayer()
    maskLayer.frame = self.frame
    self.layer.mask = maskLayer
    return maskLayer
    }()
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    maskLayer.frame = bounds
    maskLayer.path = UIBezierPath(ovalIn:bounds).cgPath
  }
  
  open override var intrinsicContentSize : CGSize {
    let size = super.intrinsicContentSize
    return CGSize(width: size.width + horizontalPadding, height: size.height + horizontalPadding)
  }
}

import UIKit

// Build for target uimodel
//locale (None, None)
import UIKit

// -BXTabView(m=BXTab):cc
// title[x,b12](f16,cdt);indicator[b0,x,h2]:v

open class BXTabView : BXTabViewCell{
  let titleLabel = UILabel(frame:CGRect.zero)
  let badgeLabel = OvalLabel(frame:CGRect.zero)

  
  fileprivate var _normalTitleColor:UIColor?
  fileprivate  var _selectedTitleColor:UIColor?
  open dynamic var normalTitleColor:UIColor?{
    get{
      return _normalTitleColor
    }set{
      _normalTitleColor = newValue
      updateTitleLabel()
    }
  }
  
  open dynamic var selectedTitleColor:UIColor?{
    get{
      return _selectedTitleColor
    }set{
      _selectedTitleColor = newValue
      updateTitleLabel()
    }
  }
  
  open dynamic var titleFont:UIFont{
    get{
      return titleLabel.font
    }set{
      titleLabel.font = newValue
      updateTitleLabel()
    }
  }

  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  
  
  open override func bind(_ item:BXTab){
    titleLabel.text  = item.text
    if let badgeValue = item.badgeValue{
      badgeLabel.text = badgeValue
      badgeLabel.isHidden = false
    }else{
      badgeLabel.isHidden = true
    }
  }
  
  override open func awakeFromNib() {
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
    titleLabel.pac_center()
    
    badgeLabel.pa_above(titleLabel, offset: -7).install()
    badgeLabel.pa_after(titleLabel, offset: -7).install()
    badgeLabel.pa_height.eq(17).install()
    badgeLabel.pa_width.gte(17).install()
  }
  
  func setupAttrs(){
    titleLabel.textColor = UIColor.darkText
    titleLabel.font = UIFont.systemFont(ofSize: 13)
    titleLabel.textAlignment = .center
    badgeLabel.font = UIFont.systemFont(ofSize: 10)
    badgeLabel.textColor = UIColor.white
    badgeLabel.backgroundColor = UIColor(red: 1.0, green: 0.231372, blue: 0.1881, alpha: 1.0)
    badgeLabel.textAlignment = .center

  }
  

  override open var isSelected:Bool{
    didSet{
      updateTitleLabel()
    }
  }
  
  func updateTitleLabel(){
      let textColor:UIColor
      if isSelected{
        textColor = selectedTitleColor ?? self.tintColor
      }else{
        textColor = normalTitleColor ?? UIColor.darkText
      }
      UIView.transition(with: titleLabel, duration: 0.3,
        options: UIViewAnimationOptions.transitionCrossDissolve,
        animations: { () -> Void in
          self.titleLabel.textColor = textColor
        }) { (finished) -> Void in
          
    }
  }
  
}
