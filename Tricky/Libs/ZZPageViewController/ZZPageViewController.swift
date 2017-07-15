//
//  ZZPageViewController.swift
//  ZZPageViewController
//
//  Created by Pillar on 2017/6/28.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit


public enum ZZPageViewControllerNavigationOrientation : Int {
    
    
    case horizontal
    
    case vertical
}

public enum ZZPageViewControllerNavigationDirection : Int {
    
    case none
    
    case previous
    
    case next
}


class ZZPageViewController: UIViewController,UIScrollViewDelegate {
    
    // MARK: - 属性
    
    var scrollView : UIScrollView = UIScrollView()
    
    // 如果value == NSNULL 表示到头了。  如果是UIViewController 说明还可以滑动。如果是nil 代表需要加载
    var viewControllers : Dictionary<Int,Any?> = Dictionary()
    
    weak var delegate: ZZPageViewControllerDelegate?
    weak var dataSource: ZZPageViewControllerDataSource?{
        didSet{
            if dataSource != nil {
                scrollView.isScrollEnabled = true
            }else{
                scrollView.isScrollEnabled = false
            }
        }
    }
    
    private var navigationOrientation : ZZPageViewControllerNavigationOrientation!
    private var navigationDirection : ZZPageViewControllerNavigationDirection = .none
    
    private var interPageSpacing : CGFloat = 0
    private var originOffset : CGFloat = 0.0
    
    private var currentIndex = 0
    
    private var validScrollSize : Bool{
        get{
            guard !scrollView.frame.size.equalTo(CGSize.zero) else {
                return false
            }
            return true
            
        }
    }
    
    
    // MARK: - 初始化方法
    
    init(navigationOrientation: ZZPageViewControllerNavigationOrientation,interPageSpacing: CGFloat ){
        super.init(nibName: nil, bundle: nil)
        self.navigationOrientation = navigationOrientation
        self.interPageSpacing = interPageSpacing
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool{
        return true
    }
    
    
    // MARK: - Core
    
    func setViewController(_ viewController: UIViewController?, completion: (() -> Void)?){
        
        for (_,value) in viewControllers {
            if value is UIViewController {
                (value as! UIViewController).removeFromSuperViewController()
            }
        }
        viewControllers.removeAll()
        
        currentIndex = 0
        
        viewControllers[currentIndex] = viewController!
        
        addViewContorllerOnly(viewController!)
        
        updateScrollViewDisplayIndexIfNeeded()
        
        completion?()
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        originOffset = scrollViewOffset()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isDragging == true && scrollView == self.scrollView {
            
            
            var flag = false
            
            let offset = scrollViewOffset()
            
            if originOffset < offset {
                
                if viewControllers[currentIndex + 1] == nil{
                    cacheViewControllerFromDataSource(currentIndex + 1, callback: { [unowned self] (suc, vc) in
                        if suc {
                            self.addViewContorllerOnly(vc!)
                        }
                    })
                    
                    flag = true
                    
                }
//                
//                if viewControllers[currentIndex - 1] == nil{
//                    cacheViewControllerFromDataSource(currentIndex - 1, callback: { [unowned self] (suc, vc) in
//                        if suc {
//                            self.addViewContorllerOnly(vc!)
//                        }
//                    })
//                    flag = true
//                }
                
                if navigationDirection == .none && viewControllers[currentIndex + 1] is UIViewController {
                    self.delegate?.pageViewController(self, willTransitionTo: viewControllers[currentIndex + 1] as! UIViewController)
                    
                }
                navigationDirection = .next
                
            } else if (originOffset > offset) {
                
                if viewControllers[currentIndex - 1] == nil{
                    cacheViewControllerFromDataSource(currentIndex - 1, callback: { [unowned self] (suc, vc) in
                        if suc {
                            self.addViewContorllerOnly(vc!)
                        }
                    })
                    flag = true
                }
                
//                if viewControllers[currentIndex + 1] == nil{
//                    cacheViewControllerFromDataSource(currentIndex + 1, callback: { [unowned self] (suc, vc) in
//                        if suc {
//                            self.addViewContorllerOnly(vc!)
//                        }
//                    })
//                    flag = true
//                    
//                }
                
                if navigationDirection == .none && viewControllers[currentIndex - 1] is UIViewController {
                    self.delegate?.pageViewController(self, willTransitionTo: viewControllers[currentIndex - 1] as! UIViewController)
                    
                }
                
                navigationDirection = .previous
            }
            
            if flag {
                
                updateScrollViewDisplayIndexIfNeeded()
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollView.isUserInteractionEnabled = false
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = true
        
        
        if scrollView.isDecelerating == false {
            
            let lastIndex = currentIndex
            var newIndex : Int = 0
            
            navigationDirection = .none
            
            for (index,viewController) in validViewControllers(){
                if scrollView.bounds.intersects(viewController.view.frame) {
                    newIndex = index
                }
            }
            if lastIndex == newIndex{
                self.delegate?.pageViewController(self, didFinishAnimating: !scrollView.isDecelerating, previousViewControllers: viewControllers[currentIndex] as! UIViewController, transitionCompleted: false)
                
                return
            }
            
            self.delegate?.pageViewController(self, didFinishAnimating: !scrollView.isDecelerating, previousViewControllers: viewControllers[currentIndex] as! UIViewController, transitionCompleted: true)
            
            currentIndex = newIndex
            
            // 如果往下滑动
            if newIndex > lastIndex {
                
                if viewControllers[newIndex + 1] == nil{
                    cacheViewControllerFromDataSource(currentIndex + 1, callback: { [unowned self] (suc, vc) in
                        if suc {
                            self.addViewContorllerOnly(vc!)
                        }
                    })
                    
                }else{
                    
                }
                
                if let oldViewController = viewControllers[lastIndex - 1] {
                    
                    if oldViewController is UIViewController {
                        (oldViewController as! UIViewController).removeFromSuperViewController()
                        
                    }
                    viewControllers.removeValue(forKey: lastIndex - 1)
                    
                }
                
                updateScrollViewDisplayIndexIfNeeded()
                
            }else{
                if viewControllers[newIndex - 1] == nil{
                    cacheViewControllerFromDataSource(currentIndex - 1, callback: { [unowned self] (suc, vc) in
                        if suc {
                            self.addViewContorllerOnly(vc!)
                        }
                    })
                    
                }else{
                    
                }
                
                if let oldViewController = viewControllers[lastIndex + 1] {
                    
                    if oldViewController is UIViewController {
                        (oldViewController as! UIViewController).removeFromSuperViewController()
                    }
                    viewControllers.removeValue(forKey: lastIndex + 1)
                    
                    updateScrollViewDisplayIndexIfNeeded()
                }
            }
            
        }
    }
    // MARK: - Helper
    
    private func margin() -> CGFloat{
        return interPageSpacing / 2.0
    }
    
    private func pageCount() -> CGFloat{
        
        var count : CGFloat = 0
        for (_,value) in viewControllers{
            if value is UIViewController{
                count += 1
            }
        }
        
        return count
    }
    
    
    private func validViewControllers() -> [(Int,UIViewController)]{
        let targer =  viewControllers.filter { (_,value) -> Bool in
            value is UIViewController
            }.sorted { (t, t1) -> Bool in
                return t.key < t1.key ? true : false
        }
        
        return targer as! [(Int, UIViewController)]
    }
    
    
    private func scrollViewOffset() -> CGFloat{
        return navigationOrientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
    }
    
    private func scrollViewSize() ->CGFloat{
        return navigationOrientation == .horizontal ? scrollView.bounds.width : scrollView.bounds.height
    }
    
    
    private func cacheViewControllerFromDataSource(_ index: Int, callback:((Bool,UIViewController?)->Void)?) -> Void{
        
        if index > currentIndex {
            if let vc = self.dataSource!.pageViewController(self, viewControllerAfter: viewControllers[index - 1] as! UIViewController) {
                viewControllers[index] = vc
                callback?(true,vc)
            }else{
                viewControllers[index] = NSNull()
                callback?(false,nil)
            }
        }else if index < currentIndex {
            if let vc = self.dataSource!.pageViewController(self, viewControllerBefore: viewControllers[index + 1] as! UIViewController) {
                viewControllers[index] = vc
                callback?(true,vc)
            }else{
                viewControllers[index] = NSNull()
                callback?(false,nil)
            }
        }else{
            
        }
        
        
    }
    
    private func updateScrollViewLayoutIfNeeded() {
        if validScrollSize{
            
            let width : CGFloat =  navigationOrientation == .horizontal ? pageCount() * scrollView.frame.size.width + CGFloat.leastNormalMagnitude: scrollView.frame.size.width
            
            let height : CGFloat = navigationOrientation == .horizontal ? scrollView.frame.size.height :pageCount() * scrollView.frame.size.height + CGFloat.leastNormalMagnitude
            
            let oldContentSize = scrollView.contentSize
            if width != oldContentSize.width || height != oldContentSize.height
            {
                
                scrollView.contentSize = CGSize(width: width, height: height)
                
            }
        }
    }
    
    private func updateAllViewsLayout(){
        
        var i = 0
        for (_,viewController) in validViewControllers(){
            viewController.view.frame = calcVisibleViewControllerFrameWith(i)
            i += 1
        }
        
    }
    
    private func updateScrollViewDisplayIndexIfNeeded() {
        if validScrollSize{
            
            updateScrollViewLayoutIfNeeded()
            
            var indexNum = 0
            
            if let vc =  viewControllers[currentIndex - 1] {
                if vc is UIViewController {
                    indexNum += 1
                }
            }
            
            let pageOffset = currentViewOffset()
            updateAllViewsLayout()
            
            let newOffset = pageViewOffset(offset: pageOffset, index: indexNum)
            if newOffset.x != scrollView.contentOffset.x ||
                newOffset.y != scrollView.contentOffset.y
            {
                scrollView.contentOffset = newOffset
            }
            
        }
        
    }
    
    
    private func currentViewOffset() -> CGFloat{
        
        var offset  = scrollViewOffset()
        while offset >= scrollViewSize() {
            offset -= scrollViewSize()
        }
        return offset
    }
    
    private func pageViewOffset(offset:CGFloat,index : Int) -> CGPoint{
        
        if navigationOrientation == .horizontal{
            return CGPoint(x:(CGFloat)(index) * scrollViewSize() + offset,y:0)
        }else{
            return CGPoint(x:0,y:(CGFloat)(index) * scrollViewSize() + offset)
        }
        
    }
    
    
    @objc fileprivate func addViewContorllerOnly(_ vc:UIViewController) -> Void{
        
        self.addSubViewController(vc, setSubViewAction: { [unowned self] (superViewController,subViewController) in
            if self.scrollView.subviews.contains(subViewController.view) == false {
                self.scrollView.addSubview(subViewController.view)
            }
        })
        
    }
    
    
    @objc fileprivate func calcVisibleViewControllerFrameWith(_ index:Int) -> CGRect {
        
        var offsetX : CGFloat
        var offsetY : CGFloat
        var width : CGFloat
        var height : CGFloat
        
        if navigationOrientation == .horizontal{
            offsetX = CGFloat(index) * scrollView.frame.width + margin()
            offsetY = 0
            width = scrollView.frame.width - 2 * margin()
            height = scrollView.frame.height
        }else{
            offsetX = 0
            offsetY = CGFloat(index) * scrollView.frame.height + margin()
            width = scrollView.frame.width
            height = scrollView.frame.height - 2 * margin()
        }
        
        return CGRect(x: offsetX, y: offsetY, width: width, height:height)
    }
    
    
    // MARK: - Config
    
    func config() {
        
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = UIColor.clear
        scrollView.scrollsToTop = false
        view.addSubview(scrollView)
        
        
        var frame : CGRect
        
        if navigationOrientation == .horizontal {
            
            frame = CGRect(x: -margin(), y: 0, width: view.bounds.width+2*margin(), height: view.bounds.height)
            scrollView.alwaysBounceHorizontal = true
            scrollView.alwaysBounceVertical = false
        }else{
            frame = CGRect(x: 0, y: -margin(), width: view.bounds.width, height: view.bounds.height + 2*margin())
            scrollView.alwaysBounceHorizontal = false
            scrollView.alwaysBounceVertical = true
        }
        
        scrollView.frame = frame
        
    }
    
}


protocol ZZPageViewControllerDelegate : NSObjectProtocol {
    
    
    func pageViewController(_ pageViewController: ZZPageViewController, willTransitionTo pendingViewControllers: UIViewController)
    
    
    func pageViewController(_ pageViewController: ZZPageViewController, didFinishAnimating finished: Bool, previousViewControllers: UIViewController, transitionCompleted completed: Bool)
    
    
}



protocol ZZPageViewControllerDataSource : NSObjectProtocol {
    
    
    
    func pageViewController(_ pageViewController: ZZPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    
    
    func pageViewController(_ pageViewController: ZZPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    
}



extension UIViewController{
    
    func addSubViewController(_ viewController:UIViewController,
                              setSubViewAction:((_ superViewController:UIViewController,
        _ subViewController:UIViewController) -> Void)?) {
        let isContain = self.childViewControllers.contains(viewController)
        
        if isContain == false {
            self.addChildViewController(viewController)
        }
        
        setSubViewAction?(self,viewController)
        
        if isContain == false {
            viewController.didMove(toParentViewController: self)
        }
    }
    
    
    func removeFromSuperViewController() {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
}
