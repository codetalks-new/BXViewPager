

// BXTab 将支持两种显示模式,一种是Tab 栏本身是可滚动的.
// 比如 Android Google Play 中的顶栏就是可滚动的. 国内众多 的新闻客户端 Tab 栏也是可滚动的.
// 可滚动的 Tab 栏可以指定可见的 Tab 数量,为了更灵活的控制,可见 Tab 数量可以指定为小数
public enum BXTabLayoutMode{
  case Scrollable(visibleItems:CGFloat)
  case Fixed
  
  var isFixed:Bool{
    switch self{
    case .Fixed: return true
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
import PinAutoLayout

// -BXTabLayout:v
// _[hor0,t0,b0]:c
// shadow[hor0,h1,b0]:v
// indicator[w60,h2,b0]:v

public class BXTabLayout : UIView,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
  lazy var collectionView :UICollectionView = { [unowned self] in
    return UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)
    }()
  
  private lazy var flowLayout:UICollectionViewFlowLayout = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumInteritemSpacing = 10
    flowLayout.itemSize = CGSize(width:100,height:100)
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionInset = UIEdgeInsetsZero
    flowLayout.scrollDirection = .Vertical
    return flowLayout
  }()
  
  let shadowView = UIView(frame:CGRectZero)
  let indicatorView = UIView(frame:CGRectZero)
  
  public dynamic var showIndicator:Bool {
    get{
      return !indicatorView.hidden
    }set{
      indicatorView.hidden = !newValue
    }
  }
  
  public dynamic var showShadow:Bool{
    get{
      return !shadowView.hidden
    }set{
      shadowView.hidden = !newValue
    }
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  override public func awakeFromNib() {
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
    collectionView.pinBottom(0)
    collectionView.pinHorizontal(0)
    collectionView.pinTop(0)
    
    shadowView.pinHeight(1)
    shadowView.pinBottom(0)
    shadowView.pinHorizontal(0)
    
    indicatorView.pinHeight(2)
    indicatorView.pinBottom(0)
    indicatorView.pinWidth(60)
    
  }
  
  func setupAttrs(){
    self.backgroundColor = UIColor(white: 0.912, alpha: 1.0)
    
    // 注意: 当 scrollDirection 为 .Horizontal 时,Item 之间的间距其实是 minmumLineSpacing
    flowLayout.minimumInteritemSpacing = options.minimumInteritemSpacing
    flowLayout.minimumLineSpacing = options.minimumInteritemSpacing
    flowLayout.scrollDirection = .Horizontal
   
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.scrollEnabled = true
    collectionView.backgroundColor = .whiteColor()
    
    collectionView.delegate = self
    collectionView.dataSource = self
    
    registerClass(BXTabView.self)
    
    indicatorView.backgroundColor = self.tintColor
  }
  
  // MARK: Indicator View Support
  // 使用 dynamic 以便可以支付 appearance 的设置
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
  
  
  public override func tintColorDidChange() {
    super.tintColorDidChange()
    if indicatorColor == nil{
      indicatorView.backgroundColor = self.tintColor
    }
  }
  
  
  
  func reloadData(){
    collectionView.reloadData()
  }
  
  public var mode:BXTabLayoutMode = .Fixed{
    didSet{
      if collectionView.dataSource != nil{
        itemSize = CGSizeZero
        reloadData()
      }
    }
  }
  
  private var tabs:[BXTab] = []
  
  
  
  public var didSelectedTab: ( (BXTab) -> Void )?
  
  public var options:BXTabLayoutOptions = BXTabLayoutOptions.defaultOptions{
    didSet{
      itemSize = CGSizeZero
      flowLayout.minimumInteritemSpacing = options.minimumInteritemSpacing
      flowLayout.minimumLineSpacing = options.minimumInteritemSpacing //
    }
  }
  
  public func registerClass(cellClass: AnyClass?) {
    collectionView.registerClass(cellClass, forCellWithReuseIdentifier: BX_TAB_REUSE_IDENTIFIER)
  }
  
  public func registerNib(nib: UINib?) {
    collectionView.registerNib(nib, forCellWithReuseIdentifier: BX_TAB_REUSE_IDENTIFIER)
  }
  
  public func addTab(tab:BXTab,index:Int = 0,setSelected:Bool = false){
    tabs.insert(tab, atIndex: index)
    reloadData()
    if(setSelected){
      selectTabAtIndex(index)
    }
    
  }
  
  public func updateTabs(tabs:[BXTab]){
    self.tabs.removeAll()
    self.tabs.appendContentsOf(tabs)
    reloadData()
    if tabs.count > 0 {
      if let indexPaths = collectionView.indexPathsForSelectedItems() where indexPaths.isEmpty{
        collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: true, scrollPosition: .CenteredHorizontally)
      }
    }
  }
 
  public func bx_delay(delay:NSTimeInterval,block:dispatch_block_t){
    dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC)))
      , dispatch_get_main_queue()
      , block)
  }
  
  public func selectTabAtIndex(index:Int){
    let indexPath = NSIndexPath(forItem: index, inSection: 0)
    collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
    if mode.isFixed{
      self.onSelectedTabChanged()
    }else{
      flowLayout.invalidateLayout()
      bx_delay(0.3){
        self.onSelectedTabChanged()
      }
    }
  }
  
  public func tabAtIndexPath(indexPath:NSIndexPath) -> BXTab{
    return tabs[indexPath.item]
  }
  
  func onSelectedTabChanged(){
    updateIndicatorView()
  }
  
  func updateIndicatorView(){
    guard  let indexPath = collectionView.indexPathsForSelectedItems()?.first else{
      return
    }
    
    guard let attrs = flowLayout.layoutAttributesForItemAtIndexPath(indexPath) else{
      return
    }
    
    NSLog("Current Selected Item Attrs:\(attrs)")
    
    let originX = attrs.frame.minX - collectionView.bounds.origin.x
    let centerX = originX + attrs.frame.width * 0.5
    
    UIView.animateWithDuration(0.3){
      self.indicatorView.center.x = centerX
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    updateItemSize()
    updateIndicatorView()
    NSLog("\(__FUNCTION__)")
  }
  
  public override func didMoveToWindow() {
    super.didMoveToWindow()
    NSLog("\(__FUNCTION__)")
  }
  
  
  public var numberOfTabs:Int{
    return tabs.count
  }
  
  // 自由类中实现中才可以被继承的子类重写,所以放在同一个类中
  //MARK: UICollectionViewDataSource
  
  public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
    return 1
  }
  
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
    return numberOfTabs
  }
  
  
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let tab = tabAtIndexPath(indexPath)
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BX_TAB_REUSE_IDENTIFIER, forIndexPath: indexPath) as! BXTabViewCell
    cell.bind(tab)
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let tab = tabAtIndexPath(indexPath)
    tab.position = indexPath.row
    didSelectedTab?(tab)
    onSelectedTabChanged()
  }
  
  
  private var itemSize:CGSize = CGSizeZero
  
  private func calculateItemWidth() -> CGFloat{
    if collectionView.bounds.width < 1{
      return 0
    }
    let tabCount:CGFloat = CGFloat(numberOfTabs)
    var visibleTabCount = tabCount
    switch mode{
    case .Scrollable(let visibleItems):
      visibleTabCount = visibleItems
    default:break
    }
    
    let spaceCount :CGFloat = visibleTabCount - 1
    let itemSpace = flowLayout.scrollDirection == .Horizontal ? flowLayout.minimumLineSpacing: flowLayout.minimumInteritemSpacing
    let totalWidth = collectionView.bounds.width - itemSpace * spaceCount - flowLayout.sectionInset.left - flowLayout.sectionInset.right
    let itemWidth = totalWidth / visibleTabCount
    return itemWidth
    
  }
  
  private func calculateItemHeight() -> CGFloat{
    if collectionView.bounds.height < 1{
      return 0
    }
    let height = collectionView.bounds.height - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom
    return height
  }
  
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if itemSize == CGSizeZero{
      itemSize = CGSize(width: calculateItemWidth(),height: calculateItemHeight())
    }
    return itemSize
  }
  
  func updateItemSize(){
    itemSize = CGSize(width: calculateItemWidth(),height: calculateItemHeight())
    flowLayout.itemSize = itemSize
  }
  
  
}
