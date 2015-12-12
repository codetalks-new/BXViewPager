

public enum BXTabLayoutMode:Int{
    case Scrollable
    case Fixed
}



public let BX_TAB_REUSE_IDENTIFIER = "bx_tabCell"
public class BXTabLayout: UICollectionView{
    
    struct TabConstants{
        static let DEFAULT_HEIGHT : CGFloat = 48
        static let TAB_MIN_WIDTH_MARGIN : CGFloat = 56
        static let FIXED_WRAP_GUTTER_MIN : CGFloat = 8
        static let MOTION_NON_ADJACENT_OFFSET : CGFloat = 24
        static let ANIMATION_DURATION : CGFloat = 300 // micoseconds
    }
    
    public var mode:BXTabLayoutMode = .Fixed
    
    private var tabs:[BXTab] = []
    public  let flowLayout = UICollectionViewFlowLayout()
    
    public var didSelectedTab: ( (BXTab) -> Void )?
   
    private var adapter:BXTabLayoutAdapter!
    public init(tabs:[BXTab],mode :BXTabLayoutMode = .Fixed){
        self.tabs.appendContentsOf(tabs)
        self.mode = mode
        flowLayout.minimumInteritemSpacing = TabConstants.FIXED_WRAP_GUTTER_MIN
        flowLayout.itemSize = CGSize(width: TabConstants.TAB_MIN_WIDTH_MARGIN,height:TabConstants.DEFAULT_HEIGHT)
        super.init(frame: CGRectZero, collectionViewLayout: flowLayout)
        self.backgroundColor = UIColor(white: 0.912, alpha: 1.0)
        adapter = BXTabLayoutAdapter(tabLayout: self)
        self.delegate = adapter
        self.dataSource = adapter
        registerClass(BXTabView.self, forCellWithReuseIdentifier: BX_TAB_REUSE_IDENTIFIER)
        if !tabs.isEmpty{
            selectTabAtIndex(0)
        }
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
    
    public func selectTabAtIndex(index:Int){
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
    }
    
    public func tabAtIndexPath(indexPath:NSIndexPath) -> BXTab{
        return tabs[indexPath.item]
    }
   
    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 320, height: TabConstants.DEFAULT_HEIGHT)
    }

    public var numberOfTabs:Int{
        return tabs.count
    }
    
}

public class BXTabLayoutAdapter: NSObject, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    // Helpers
    let tabLayout:BXTabLayout
    public init(tabLayout:BXTabLayout){
        self.tabLayout = tabLayout
        super.init()
    }
    
    // MARK: UICollectionViewDataSource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return tabLayout.numberOfTabs
    }
    
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let tab = tabLayout.tabAtIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BX_TAB_REUSE_IDENTIFIER, forIndexPath: indexPath) as! BXTabView
        cell.bind(tab)
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tab = tabLayout.tabAtIndexPath(indexPath)
        tab.position = indexPath.row
        tabLayout.didSelectedTab?(tab)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        NSLog("Tab indexPath \(indexPath)")
        let count =  tabLayout.numberOfTabs
        let size = collectionView.frame.size
        let gutterTotalWidth = tabLayout.flowLayout.minimumInteritemSpacing * CGFloat(count  - 1)
        let itemWidth  = (size.width - gutterTotalWidth) / CGFloat(count)
        let itemHeight = size.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}