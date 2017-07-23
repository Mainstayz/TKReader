//
//  TKReadingViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController

class TKReadingViewController: TKViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource,TKCatalogViewControllerDelegate{
    
    enum TKReadingDirection: Int {
        case none = -1
        case pre
        case next
    }
    
    lazy var hudConfigure: KVNProgressConfiguration = {
        let configuration = KVNProgressConfiguration()
        configuration.statusColor = UIColor.white
        configuration.circleStrokeForegroundColor = UIColor.white
        configuration.circleStrokeBackgroundColor = UIColor.init(white: 1.0, alpha: 0.3)
        configuration.circleFillBackgroundColor = UIColor.init(white: 1.0, alpha: 0.1)
        configuration.backgroundFillColor = UIColor.init(red: 0.173, green: 0.263, blue: 0.856, alpha: 0.9)
        configuration.backgroundTintColor = UIColor.init(red: 0.173, green: 0.263, blue: 0.856, alpha: 0.1)
        
        configuration.successColor = UIColor.white
        configuration.errorColor = UIColor.white
        configuration.stopColor = UIColor.white
        configuration.circleSize = 110.0
        configuration.lineWidth = 1.0
        configuration.isFullScreen = true
        configuration.doesShowStop = true
        configuration.stopRelativeHeight = 0.4
        configuration.doesAllowUserInteraction = false
        return configuration
    }()
    
    var novelDataSource : TKNovelDataSource!
    
    var pageViewController : UIPageViewController!
    
    func initialize(){
        KVNProgress.setConfiguration(self.hudConfigure)
    }
    var direction : TKReadingDirection = .none
    
    var currentPage : (Int,Int,Int)!
    
    var readingRecord : (Int,Int)!
    
    var needCacheChapters = [Int]()
    
    var statusBarHidden = true
    
    
    lazy var topBar: TKSettingTopBar = {
        let topBar = UINib(nibName: "TKSettingTopBar", bundle: nil).instantiate(withOwner: nil, options: nil).first as! TKSettingTopBar
        topBar.frame = CGRect(x: 0, y: -64, width: TKScreenWidth, height: 64)
        topBar.cancelButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        
        return topBar
    }()
    
    lazy var bottomBar: TKSettingBottomBar = {
        let bottomBar = UINib(nibName: "TKSettingBottomBar", bundle: nil).instantiate(withOwner: nil, options: nil).first as! TKSettingBottomBar
        bottomBar.catalogButton.addTarget(self, action: #selector(displayLeftViewController), for: .touchUpInside)
        bottomBar.frame = CGRect(x: 0, y: TKScreenHeight, width: TKScreenWidth, height: 49)
        
        return bottomBar
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TKBookConfig.sharedInstance.backgroundColor
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey:0])
        pageViewController.dataSource = self
        pageViewController.delegate = self;
        pageViewController.view.frame = self.view.bounds

        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
 
        let tap = UITapGestureRecognizer(target: self, action: #selector(displaySettingBar))
        
        self.view.addGestureRecognizer(tap)
        
        
        KVNProgress.show()
        novelDataSource.cacheChaptersNearby(index: novelDataSource.currentPage()!.0) { [unowned self] in
            self.refresh()
            let range = self.novelDataSource.cacheData[self.novelDataSource.currentPage()!.0]!.ranges[self.novelDataSource.currentPage()!.2]
            self.readingRecord = (self.novelDataSource.currentPage()!.0,range.0)
            KVNProgress.dismiss()
        }
    }
    
    
    
    
    func showBar(){
        if self.topBar.superview == nil && self.bottomBar.superview == nil {
            statusBarHidden = false
            self.view.addSubview(self.topBar)
            self.view.addSubview(self.bottomBar)
            UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
                self.topBar.frame = CGRect(x: 0, y: 0, width: TKScreenWidth, height: 64)
                self.bottomBar.frame = CGRect(x: 0, y: TKScreenHeight - 49, width: TKScreenWidth, height: 49)
            })
        }
    }
    
    func hiddenBar(){
        if self.topBar.superview != nil && self.bottomBar.superview != nil {
            statusBarHidden = true
            UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
                self.topBar.frame = CGRect(x: 0, y: -64, width: TKScreenWidth, height: 64)
                self.bottomBar.frame = CGRect(x: 0, y: TKScreenHeight, width: TKScreenWidth, height: 49)
            }, completion: { (suc) in
                self.topBar.removeFromSuperview()
                self.bottomBar.removeFromSuperview()
            })
        }
    }
        
    func displaySettingBar(){
        if self.topBar.superview == nil && self.bottomBar.superview == nil {
            showBar()
        }else{
            hiddenBar()
        }
    }
    
    
    func dismissViewController(){
        TKReadingRecordManager.sharedInstance.updateReadingRecord(key: novelDataSource.novelModel.title!, chapterNum: readingRecord.0, location: readingRecord.1)
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayLeftViewController(){
        
        if let drawerController = parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }

        
    }
    
    
    func refresh() -> Void {
        
        if let page = novelDataSource.currentPage() {
            currentPage = page
            if let viewController =  self.viewController(page: page){
                pageViewController.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false) { (finished) in
                    print("刷新完毕：\(finished)")
                }
            }
            
        }
        
    }
    
    func requestChapter(index: Int){
        KVNProgress.show()
        novelDataSource.parse(chapter: index, completion: {[unowned self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.refresh()
                KVNProgress.dismiss()
            })
        })
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        hiddenBar()
        let vc = pendingViewControllers.first as! TKReadingPageViewController
        let nextIndex = vc.page!
        
        if nextIndex.0 == currentPage.0 {
            if nextIndex.2 > currentPage.2 {
                direction = .next
            }else {
                direction = .pre
            }
            
        }else if nextIndex.0 > currentPage.0 {
            direction = .next
        }else if nextIndex.0 < currentPage.0 {
            direction = .pre
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed && finished{
            
            if direction == .next {
                if let next = novelDataSource.nextPage(){
                    currentPage = next
                    novelDataSource.page = next
                    debugPrint("现在 \(next)")
                    
                    if let nextChapter = novelDataSource.nextChapter() {
                        if novelDataSource.cacheData[nextChapter] == nil {
                            novelDataSource.parse(chapter: nextChapter, completion: {
                                debugPrint("缓存下一章： 、\(nextChapter)")
                            })
                        }
                    }
                    
                }
            }else if direction == .pre{
                if let pre = novelDataSource.prePage(){
                    currentPage = pre
                    novelDataSource.page = pre
                    debugPrint("现在 \(pre)")
                    
                    
                    
                    if let preChapter = novelDataSource.preChapter() {
                        if novelDataSource.cacheData[preChapter] == nil {
                            novelDataSource.parse(chapter: preChapter, completion: {
                                debugPrint("缓存上一章： 、\(preChapter)")
                            })
                        }
                    }
                    
                }
            }
            
            //保存当前页码

            let range = novelDataSource.cacheData[currentPage.0]!.ranges[currentPage.2]
            self.readingRecord = (currentPage.0,range.0)
            
            
            
            
            
            
        }else{
            
            // 翻页没成功
            debugPrint("翻页不成功")
            
        }
        
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let page = self.novelDataSource.prePage()
        let viewController = self.viewController(page: page)
        if viewController == nil {
            if let preChapter = novelDataSource.preChapter(){
                requestChapter(index: preChapter)
            }
        }
        return viewController
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let page = self.novelDataSource.nextPage()
        let viewController = self.viewController(page: page)
        if viewController == nil {
            if let nextChapter = novelDataSource.nextChapter(){
                requestChapter(index: nextChapter)
            }
        }
        return viewController
        
    }
    
    
    
    func viewController(page:(Int,Int,Int)?) -> UIViewController? {
        
        if page == nil {
            print("空了")
            return nil
        }
        
        let pegeController = TKReadingPageViewController()
        pegeController.page = page
        pegeController.chapterName = novelDataSource.novelModel.chapters[page!.0].chapterName
        if let info =  novelDataSource.pageInfo(page: page){
            pegeController.syncUpdateContent(content: info.content)
            
        }
        return pegeController
        
    }
    
    
    
    // MARK: - TKCatalogViewControllerDelegate
    
    
    func catalogViewController(vc: TKCatalogViewController, didSelectRowAt indexPath: Int, chapter: TKChapterModel) {
        
        self.readingRecord = (indexPath,0)

        KVNProgress.show()
        novelDataSource.cacheChaptersNearby(index: indexPath) { [unowned self] in
            let chapterInfo =  self.novelDataSource.cacheData[indexPath]!
            self.novelDataSource.page = (indexPath,chapterInfo.ranges.count,0)
            self.currentPage = (indexPath,chapterInfo.ranges.count,0)
            self.refresh()
            KVNProgress.dismiss()
            
            if let drawerController = self.parent as? KYDrawerController {
                drawerController.setDrawerState(.closed, animated: true)
                self.hiddenBar()
            }
            
        }
        
    }
    
    
    
    override var prefersStatusBarHidden: Bool{
        return statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
}

extension KYDrawerController{
    open override var prefersStatusBarHidden: Bool{
        return self.mainViewController.prefersStatusBarHidden
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return self.mainViewController.preferredStatusBarUpdateAnimation
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle{
        return self.mainViewController.preferredStatusBarStyle
    }
    
}


