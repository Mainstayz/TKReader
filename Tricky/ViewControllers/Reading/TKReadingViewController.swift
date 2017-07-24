//
//  TKReadingViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import KYDrawerController
import MBProgressHUD
import Toast_Swift
class TKReadingViewController: TKViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource,TKCatalogViewControllerDelegate{
    
    enum TKReadingDirection: Int {
        case none = -1
        case pre
        case next
    }

    var novelDataSource : TKNovelDataSource!
    
    var pageViewController : UIPageViewController!
    
    var direction : TKReadingDirection = .none
    
    var currentPage : (Int,Int,Int)!
    
    var readingRecord : (Int,Int)!
    
    var needCacheChapters = [Int]()
    
    var statusBarHidden = true
    
    lazy var toastView: UILabel = {
        let lab = UILabel(frame: CGRect(x: 0, y: TKScreenHeight - 49, width: TKScreenWidth, height: 49))
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 11)
        lab.textColor = TKConfigure.default.pageColor
        lab.alpha = 0
        return lab
    }()
    
    
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
        self.view.backgroundColor = TKConfigure.default.backgroundColor
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey:0])
        pageViewController.dataSource = self
        pageViewController.delegate = self;
        pageViewController.view.frame = self.view.bounds

        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
 
        let tap = UITapGestureRecognizer(target: self, action: #selector(displaySettingBar))
        
        self.view.addGestureRecognizer(tap)
        
        self.view.addSubview(self.toastView)
 
        MBProgressHUD.showAdded(to: self.view, animated: true)
        novelDataSource.cacheChaptersNearby(index: novelDataSource.page.0) { [unowned self] in
            self.refresh()
            let range = self.novelDataSource.downloadedChapters[self.novelDataSource.page.0]!.ranges[self.novelDataSource.page.2]
            self.readingRecord = (self.novelDataSource.page.0,range.0)
            MBProgressHUD.hide(for: self.view, animated: true)
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
    
    
    func displayToastView(hidden:Bool){
        if hidden{
            self.toastView.text = "正在缓存下一章...完成"
            UIView.animate(withDuration: 0.68, animations: { 
                self.toastView.alpha = 0
            })
        }else{
            self.toastView.text = "正在缓存下一章..."
            UIView.animate(withDuration: 0.68, animations: {
                self.toastView.alpha = 1
            })
        }
    }
    
    
    func dismissViewController(){
        TKReadingRecordManager.default.updateReadingRecord(key: novelDataSource.novel.title!, chapterNum: readingRecord.0, location: readingRecord.1)
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayLeftViewController(){
        
        if let drawerController = parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }

        
    }
    
    
    func refresh() -> Void {
        let page = novelDataSource.page
        currentPage = page
        if let viewController =  self.viewController(page: page){
            pageViewController.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false) { (finished) in
                print("刷新完毕：\(finished)")
            }
        }
        
        
        
    }
    
    func requestChapter(index: Int, completion:@escaping ()->Void){
      
        novelDataSource.parse(chapter: index, completion: {[unowned self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.refresh()
                completion()
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
                        if novelDataSource.downloadedChapters[nextChapter] == nil {
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
                        if novelDataSource.downloadedChapters[preChapter] == nil {
                            novelDataSource.parse(chapter: preChapter, completion: {
                                debugPrint("缓存上一章： 、\(preChapter)")
                            })
                        }
                    }
                    
                }
            }
            
            //保存当前页码

            let range = novelDataSource.downloadedChapters[currentPage.0]!.ranges[currentPage.2]
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
                displayToastView(hidden: false)
                requestChapter(index: preChapter, completion: {[unowned self] in
                    self.displayToastView(hidden: true)
                })
            }
        }
        return viewController
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let page = self.novelDataSource.nextPage()
        let viewController = self.viewController(page: page)
        if viewController == nil {
            if let nextChapter = novelDataSource.nextChapter(){
                displayToastView(hidden: false)
                requestChapter(index: nextChapter, completion: { [unowned self] in
                    self.displayToastView(hidden: true)
                })
                
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
        pegeController.chapterName = novelDataSource.novel.chapters[page!.0].chapterName
        if let info =  novelDataSource.pageInfo(page: page){
            pegeController.syncUpdateContent(content: info.content)
            
        }
        return pegeController
        
    }
    
    
    
    // MARK: - TKCatalogViewControllerDelegate
    
    
    func catalogViewController(vc: TKCatalogViewController, didSelectRowAt indexPath: Int, chapter: TKChapterListModel) {
        
        if let drawerController = self.parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
            self.hiddenBar()
        }
        
        self.readingRecord = (indexPath,0)

        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        novelDataSource.cacheChaptersNearby(index: indexPath) { [unowned self] in
 
            let chapterInfo =  self.novelDataSource.downloadedChapters[indexPath]!
            self.novelDataSource.page = (indexPath,chapterInfo.ranges.count,0)
            self.currentPage = (indexPath,chapterInfo.ranges.count,0)
            self.refresh()
            MBProgressHUD.hide(for: self.view, animated: true)
 
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


