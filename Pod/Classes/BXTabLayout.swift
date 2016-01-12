

// BXTab 将支持两种显示模式,一种是Tab 栏本身是可滚动的.
// 比如 Android Google Play 中的顶栏就是可滚动的. 国内众多 的新闻客户端 Tab 栏也是可滚动的.
// 可滚动的 Tab 栏可以指定可见的 Tab 数量,为了更灵活的控制,可见 Tab 数量可以指定为小数
public enum BXTabLayoutMode{
  case Scrollable(visibleItems:CGFloat)
  case Fixed
}


public struct BXTabLayoutOptions{
  public var minimumInteritemSpacing:CGFloat = 8
  
  public static let defaultOptions = BXTabLayoutOptions()
}

public let BX_TAB_REUSE_IDENTIFIER = "bx_tabCell"
public class BXTabLayout: UICollectionView,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
  
  public var mode:BXTabLayoutMode = .Fixed{
    didSet{
      if dataSource != nil{
        itemSize = CGSizeZero
        reloadData()
      }
    }
  }
    
    private var tabs:[BXTab] = []
    public  let flowLayout = UICollectionViewFlowLayout()
    
    public var didSelectedTab: ( (BXTab) -> Void )?
  
  public var options:BXTabLayoutOptions = BXTabLayoutOptions.defaultOptions{
    didSet{
         itemSize = CGSizeZero
         flowLayout.minimumInteritemSpacing = options.minimumInteritemSpacing
    }
  }
  
    public init(tabs:[BXTab] = [],mode :BXTabLayoutMode = .Fixed){
        self.tabs.appendContentsOf(tabs)
        self.mode = mode
        super.init(frame: CGRectZero, collectionViewLayout: flowLayout)
      
        self.backgroundColor = UIColor(white: 0.912, alpha: 1.0)
      
        flowLayout.minimumInteritemSpacing = options.minimumInteritemSpacing
        flowLayout.scrollDirection = .Horizontal
      
        self.delegate = self
        self.dataSource = self
      
        registerClass(BXTabView.self, forCellWithReuseIdentifier: BX_TAB_REUSE_IDENTIFIER)
        if !tabs.isEmpty{
            selectTabAtIndex(0)
        }
    }
  
  public func registerClass(cellClass: AnyClass?) {
      registerClass(cellClass, forCellWithReuseIdentifier: BX_TAB_REUSE_IDENTIFIER)
  }
  
  public func registerNib(nib: UINib?) {
      registerNib(nib, forCellWithReuseIdentifier: BX_TAB_REUSE_IDENTIFIER)
  }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
  }
  
    public func selectTabAtIndex(index:Int){
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
    }
    
    public func tabAtIndexPath(indexPath:NSIndexPath) -> BXTab{
        return tabs[indexPath.item]
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
  }
 
  
  private var itemSize:CGSize = CGSizeZero
  
  private func calculateItemWidth() -> CGFloat{
    let tabCount:CGFloat = CGFloat(numberOfTabs)
    var visibleTabCount = tabCount
    switch mode{
    case .Scrollable(let visibleItems):
      visibleTabCount = visibleItems
    default:break
    }
    
    let spaceCount :CGFloat = visibleTabCount - 1
    let totalWidth = bounds.width - flowLayout.minimumInteritemSpacing * spaceCount - flowLayout.sectionInset.left - flowLayout.sectionInset.right
    let itemWidth = totalWidth / visibleTabCount
    return itemWidth
    
  }
  
  private func calculateItemHeight() -> CGFloat{
    let height = bounds.height - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom
    return height
  }
  
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if itemSize == CGSizeZero{
      itemSize = CGSize(width: calculateItemWidth(),height: calculateItemWidth())
    }
    return itemSize
  }
  
  func updateItemSize(){
      itemSize = CGSize(width: calculateItemWidth(),height: calculateItemWidth())
    flowLayout.itemSize = itemSize
  }

  
}
