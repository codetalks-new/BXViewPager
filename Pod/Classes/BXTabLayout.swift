

public enum BXTabLayoutMode:Int{
    case Scrollable
    case Fixed
}

public enum BXTabLayoutStyle:Int{
    case Android
    case IOS
    case RoundedPop
}


public let BX_TAB_REUSE_IDENTIFIER = "bx_tabCell"
public class BXTabLayout: UICollectionView{
    static let DEFAULT_HEIGHT : CGFloat = 48
    static let TAG_MIN_WIDTH_MARGIN : CGFloat = 56
    static let FIXED_WRAP_GUTTER_MIN : CGFloat = 8
    static let MOTION_NON_ADJACENT_OFFSET : CGFloat = 24
    static let ANIMATION_DURATION : CGFloat = 300 // micoseconds
    
    public var mode:BXTabLayoutMode = .Fixed
    
    private var tabs:[BXTab] = []
    private  let flowLayout = UICollectionViewFlowLayout()
    
    public var didSelectedTab: ( (BXTab) -> Void )?
    
    public init(tabs:[BXTab],mode :BXTabLayoutMode = .Fixed){
        self.tabs.appendContentsOf(tabs)
        self.mode = mode
        flowLayout.minimumInteritemSpacing = self.dynamicType.FIXED_WRAP_GUTTER_MIN
        super.init(frame: CGRectZero, collectionViewLayout: flowLayout)
        self.backgroundColor = UIColor(white: 0.912, alpha: 1.0)
        self.delegate = self
        self.dataSource = self
        
        registerClass(BXTabView.self, forCellWithReuseIdentifier: BX_TAB_REUSE_IDENTIFIER)
        if !tabs.isEmpty{
            selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: true, scrollPosition: .CenteredHorizontally)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func addTab(tab:BXTab,index:Int = 0,setSelected:Bool = false){
        tabs.insert(tab, atIndex: index)
        reloadData()
        if(setSelected){
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
        }
        
    }
    
    public func tabAtIndexPath(indexPath:NSIndexPath) -> BXTab{
        return tabs[indexPath.item]
    }
   
    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 320, height: self.dynamicType.DEFAULT_HEIGHT)
    }

    
}

// MARK: UICollectionViewDataSource
extension BXTabLayout : UICollectionViewDataSource{
    // Helpers
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return tabs.count
    }
    
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let tab = tabAtIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BX_TAB_REUSE_IDENTIFIER, forIndexPath: indexPath) as! BXTabView
        cell.bindTab(tab)
        return cell
    }
}


// MARK: UICollectionViewDelegate

extension BXTabLayout: UICollectionViewDelegateFlowLayout{
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tab = tabAtIndexPath(indexPath)
        self.didSelectedTab?(tab)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let count = collectionView.numberOfItemsInSection(indexPath.section)
        let size = collectionView.frame.size
        let gutterTotalWidth = flowLayout.minimumInteritemSpacing * CGFloat(count  - 1)
        let itemWidth  = (size.width - gutterTotalWidth) / CGFloat(count)
        let itemHeight = size.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}


// MARK: BXTab Model
public class BXTab{
    public static let INVALID_POSITION = -1
    
    public var tag:AnyObject?
    public var icon:UIImage?
    public var text:String?
    public var contentDesc:String?
    
    public var position = BXTab.INVALID_POSITION
    
    public init(text:String?,icon:UIImage? = nil){
        self.text = text
        self.icon = icon
    }
}


// MARK: BXTabView View
public class BXTabView:UICollectionViewCell{
    let textView:UILabel = UILabel()
    let iconView:UIImageView = UIImageView()
    var tabStyle:BXTabLayoutStyle = BXTabLayoutStyle.Android
    let indicatorLine = UIView()
    override init(frame:CGRect){
        super.init(frame: CGRectZero)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public var selected:Bool{
        didSet{
            indicatorLine.hidden = !selected
            textView.textColor = selected ?  self.tintColor: UIColor.darkTextColor()
        }
    }
    
    
    
    
    func commonInit(){
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//        indicatorLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)
        contentView.addSubview(iconView)
        contentView.addSubview(indicatorLine)
        indicatorLine.backgroundColor = self.tintColor
        indicatorLine.hidden = true
        
        textView.textAlignment = .Center
        textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        
        
        
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        indicatorLine.backgroundColor = self.tintColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let rect  = bounds
        let indicatorThickness : CGFloat = 2
        indicatorLine.frame = CGRect(x: 0, y: rect.maxY - indicatorThickness, width: rect.width, height: indicatorThickness)
        
        textView.frame = CGRect(x: 0, y: rect.minX, width: rect.width, height: rect.height - indicatorThickness)
        
    }
    
    func bindTab(tab:BXTab){
        textView.text = tab.text
    }
}