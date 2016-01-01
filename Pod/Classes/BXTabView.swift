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

public class BXTabView : UICollectionViewCell{
  let titleLabel = UILabel(frame:CGRectZero)
  let indicatorView = UIView(frame:CGRectZero)

  
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
  
  public dynamic var indicatorColor:UIColor?{
    get{
      NSLog("get indicatorColor")
      return indicatorView.backgroundColor
    }
    set{
      NSLog("set indicatorColor")
      indicatorView.backgroundColor = newValue
      
    }
  }
 
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  
  
  public func bind(item:BXTab){
    titleLabel.text  = item.text
  }
  
  override public func awakeFromNib() {
    super.awakeFromNib()
    commonInit()
  }
  
  var allOutlets :[UIView]{
    return [titleLabel,indicatorView]
  }
  var allUILabelOutlets :[UILabel]{
    return [titleLabel]
  }
  var allUIViewOutlets :[UIView]{
    return [indicatorView]
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
    
    indicatorView.pinCenterX()
    indicatorView.pinBottom(0)
    indicatorView.pinHeight(2)
    indicatorView.pinWidthToSibling(titleLabel, multiplier: 1.0, constant: 40)
    
  }
  
  func setupAttrs(){
    backgroundColor = UIColor.whiteColor()
    titleLabel.textColor = UIColor.darkTextColor()
    titleLabel.font = UIFont.systemFontOfSize(13)
    titleLabel.textAlignment = .Center
//    titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    indicatorView.backgroundColor = self.tintColor
    indicatorView.hidden = true
  }
  
  public override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    
//    UIColor(white: 0.937, alpha: 1.0).setFill()
//    UIRectFill(CGRect(x: rect.minX, y: rect.maxY - 1, width: rect.width, height: 1))
  }
  
  
  
  public override func tintColorDidChange() {
    super.tintColorDidChange()
    if indicatorColor == nil{
      indicatorView.backgroundColor = self.tintColor
    }
  }
  
  override public var selected:Bool{
    didSet{
      updateIndicatorView()
      updateTitleLabel()
    }
  }
  
  func updateIndicatorView(){
      indicatorView.hidden = !selected
  }
  
  
  func updateTitleLabel(){
      let textColor:UIColor
      if selected{
        textColor = selectedTitleColor ?? self.tintColor
      }else{
        textColor = normalTitleColor ?? UIColor.darkTextColor()
      }
      titleLabel.textColor = textColor
  }
  
}