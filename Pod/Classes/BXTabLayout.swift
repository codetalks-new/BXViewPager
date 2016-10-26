

// BXTab 将支持两种显示模式,一种是Tab 栏本身是可滚动的.
// 比如 Android Google Play 中的顶栏就是可滚动的. 国内众多 的新闻客户端 Tab 栏也是可滚动的.
// 可滚动的 Tab 栏可以指定可见的 Tab 数量,为了更灵活的控制,可见 Tab 数量可以指定为小数
public enum BXTabLayoutMode{
  case scrollable(visibleItems:CGFloat)
  case fixed
  
  var isFixed:Bool{
    switch self{
    case .fixed: return true
    default: return false
    }
  }
}


public struct BXTabLayoutOptions{
  public var minimumInteritemSpacing:CGFloat = 8
  
  public static let defaultOptions = BXTabLayoutOptions()
}

public let BX_TAB_REUSE_IDENTIFIER = "bx_tabCell"

// Build for target uimodel
//locale (None, None)
import UIKit
import PinAuto

// -BXTabLayout:v
// _[hor0,t0,b0]:c
// shadow[hor0,h1,b0]:v
// indicator[w60,h2,b0]:v

open class BXTabLayout : UIView,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
  lazy var collectionView :UICollectionView = { [unowned self] in
    return UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
    }()
  
  fileprivate lazy var flowLayout:UICollectionViewFlowLayout = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumInteritemSpacing = 10
    flowLayout.itemSize = CGSize(width:100,height:100)
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.scrollDirection = .vertical
    return flowLayout
  }()
  
  let shadowView = UIView(frame:CGRect.zero)
  let indicatorView = UIView(frame:CGRect.zero)
  
  open dynamic var showIndicator:Bool {
    get{
      return !indicatorView.isHidden
    }set{
      indicatorView.isHidden = !newValue
    }
  }
  
  open dynamic var showShadow:Bool{
    get{
      return !shadowView.isHidden
    }set{
      shadowView.isHidden = !newValue
    }
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  override open func awakeFromNib() {
    super.awakeFromNib()
    commonInit()
  }
  
  var allOutlets :[UIView]{
    return [collectionView,shadowView,indicatorView]
  }
  var allUICollectionViewOutlets :[UICollectionView]{
    return [collectionView]
  }
  var allUIViewOutlets :[UIView]{
    return [shadowView,indicatorView]
  }
  
  
  func commonInit(){
    for childView in allOutlets{
      addSubview(childView)
      childView.translatesAutoresizingMaskIntoConstraints = false
    }
    installConstaints()
    setupAttrs()
    
  }
  
  func installConstaints(){
    collectionView.pac_vertical(0)
    collectionView.pac_horizontal(0)
    
    shadowView.pa_height.eq(1).install()
    shadowView.pa_bottom.eq(0).install()
    shadowView.pac_horizontal(0)
    
    indicatorView.pa_height.eq(2).install()
    indicatorView.pa_bottom.eq(0).install()
    indicatorView.pa_width.eq(60).install()
    
  }
  
  func setupAttrs(){
    self.backgroundColor = UIColor(white: 0.912, alpha: 1.0)
    
    // 注意: 当 scrollDirection 为 .Horizontal 时,Item 之间的间距其实是 minmumLineSpacing
    flowLayout.minimumInteritemSpacing = options.minimumInteritemSpacing
    flowLayout.minimumLineSpacing = options.minimumInteritemSpacing
    flowLayout.scrollDirection = .horizontal
   
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isScrollEnabled = true
    collectionView.backgroundColor = .white
    
    collectionView.delegate = self
    collectionView.dataSource = self
    
    registerClass(BXTabView.self)
    
    indicatorView.backgroundColor = self.tintColor
  }
  
  // MARK: Indicator View Support
  // 使用 dynamic 以便可以支付 appearance 的设置
  open dynamic var indicatorColor:UIColor?{
    get{
      NSLog("get indicatorColor")
      return indicatorView.backgroundColor
    }
    set{
      NSLog("set indicatorColor")
      indicatorView.backgroundColor = newValue
      
    }
  }
  
  
  open override func tintColorDidChange() {
    super.tintColorDidChange()
    if indicatorColor == nil{
      indicatorView.backgroundColor = self.tintColor
    }
  }
  
  
  
  func reloadData(){
    collectionView.reloadData()
  }
  
  open var mode:BXTabLayoutMode = .fixed{
    didSet{
      if collectionView.dataSource != nil{
        itemSize = CGSize.zero
        reloadData()
      }
    }
  }
  
  fileprivate var tabs:[BXTab] = []
  
  
  
  open var didSelectedTab: ( (BXTab) -> Void )?
  
  open var options:BXTabLayoutOptions = BXTabLayoutOptions.defaultOptions{
    didSet{
      itemSize = CGSize.zero
      flowLayout.minimumInteritemSpacing = options.minimumInteritemSpacing
      flowLayout.minimumLineSpacing = options.minimumInteritemSpacing //
    }
  }
  
  open func registerClass(_ cellClass: AnyClass?) {
    collectionView.register(cellClass, forCellWithReuseIdentifier: BX_TAB_REUSE_IDENTIFIER)
  }
  
  open func registerNib(_ nib: UINib?) {
    collectionView.register(nib, forCellWithReuseIdentifier: BX_TAB_REUSE_IDENTIFIER)
  }
  
  open func addTab(_ tab:BXTab,index:Int = 0,setSelected:Bool = false){
    tabs.insert(tab, at: index)
    reloadData()
    if(setSelected){
      selectTabAtIndex(index)
    }
    
  }
  
  open func updateTabs(_ tabs:[BXTab]){
    self.tabs.removeAll()
    self.tabs.append(contentsOf: tabs)
    reloadData()
    if tabs.count > 0 {
      if let indexPaths = collectionView.indexPathsForSelectedItems , indexPaths.isEmpty{
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
      }
    }
  }
 
  open func bx_delay(_ delay:TimeInterval,block:@escaping ()->()){
    DispatchQueue.main.asyncAfter(
      deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      , execute: block)
  }
  
  open func selectTabAtIndex(_ index:Int){
    let indexPath = IndexPath(item: index, section: 0)
    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
    if mode.isFixed{
      self.onSelectedTabChanged()
    }else{
      flowLayout.invalidateLayout()
      bx_delay(0.3){
        self.onSelectedTabChanged()
      }
    }
  }
  
  open func tabAtIndexPath(_ indexPath:IndexPath) -> BXTab{
    return tabs[(indexPath as NSIndexPath).item]
  }
  
  func onSelectedTabChanged(){
    updateIndicatorView()
  }
  
  func updateIndicatorView(){
    guard  let indexPath = collectionView.indexPathsForSelectedItems?.first else{
      return
    }
    
   
    if mode.isFixed{
      let itemSize = flowLayout.itemSize
      let item = CGFloat((indexPath as NSIndexPath).item)
      let originX =  collectionView.bounds.origin.x + (itemSize.width * item) + (flowLayout.minimumLineSpacing * item)
      let centerX = originX + itemSize.width * 0.5
      UIView.animate(withDuration: 0.3, animations: {
        self.indicatorView.center.x = centerX
      })
    }else{
      guard let attrs = flowLayout.layoutAttributesForItem(at: indexPath) else{
        return
      }
      NSLog("Current Selected Item Attrs:\(attrs)")
      let originX = attrs.frame.minX - collectionView.bounds.origin.x
      let centerX = originX + attrs.frame.width * 0.5
      
      UIView.animate(withDuration: 0.3, animations: {
        self.indicatorView.center.x = centerX
      })
    }

  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    updateItemSize()
    updateIndicatorView()
    NSLog("\(#function)")
  }
  
  open override func didMoveToWindow() {
    super.didMoveToWindow()
    NSLog("\(#function)")
  }
  
  
  open var numberOfTabs:Int{
    return tabs.count
  }
  
  // 自由类中实现中才可以被继承的子类重写,所以放在同一个类中
  //MARK: UICollectionViewDataSource
  
  open func numberOfSections(in collectionView: UICollectionView) -> Int{
    return 1
  }
  
  open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
    return numberOfTabs
  }
  
  
  open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let tab = tabAtIndexPath(indexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BX_TAB_REUSE_IDENTIFIER, for: indexPath) as! BXTabViewCell
    cell.bind(tab)
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  
  open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let tab = tabAtIndexPath(indexPath)
    tab.position = (indexPath as NSIndexPath).row
    didSelectedTab?(tab)
    onSelectedTabChanged()
  }
  
  
  fileprivate var itemSize:CGSize = CGSize.zero
  
  fileprivate func calculateItemWidth() -> CGFloat{
    if collectionView.bounds.width < 1{
      return 0
    }
    let tabCount:CGFloat = CGFloat(numberOfTabs)
    var visibleTabCount = tabCount
    switch mode{
    case .scrollable(let visibleItems):
      visibleTabCount = visibleItems
    default:break
    }
    
    let spaceCount :CGFloat = visibleTabCount - 1
    let itemSpace = flowLayout.scrollDirection == .horizontal ? flowLayout.minimumLineSpacing: flowLayout.minimumInteritemSpacing
    let totalWidth = collectionView.bounds.width - itemSpace * spaceCount - flowLayout.sectionInset.left - flowLayout.sectionInset.right
    let itemWidth = totalWidth / visibleTabCount
    return itemWidth
    
  }
  
  fileprivate func calculateItemHeight() -> CGFloat{
    if collectionView.bounds.height < 1{
      return 0
    }
    let height = collectionView.bounds.height - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom
    return height
  }
  
  open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if itemSize == CGSize.zero{
      itemSize = CGSize(width: calculateItemWidth(),height: calculateItemHeight())
    }
    return itemSize
  }
  
  func updateItemSize(){
    itemSize = CGSize(width: calculateItemWidth(),height: calculateItemHeight())
    flowLayout.itemSize = itemSize
  }
  
  
}
