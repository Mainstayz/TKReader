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
class TKReadingViewController: TKViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource,TKCatalogViewControllerDelegate,TKToolsProtocol,UIGestureRecognizerDelegate{
    
    enum TKReadingDirection: Int {
        case none = -1
        case pre
        case next
    }
    
    var novelDataSource : TKNovelDataSource!
    
    var pageViewController : UIPageViewController!
    
    var direction : TKReadingDirection = .none
    
    var readingRecord : (Int,Int)!
    
    weak var toolView : UIView?
    
    var statusBarHidden = true
    
    var tapGesture : UITapGestureRecognizer!
    
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
        bottomBar.fontButton.addTarget(self, action: #selector(showFontToolView), for: .touchUpInside)
        bottomBar.frame = CGRect(x: 0, y: TKScreenHeight, width: TKScreenWidth, height: 49)
        
        return bottomBar
    }()
    
    
    lazy var fontToolView: TKFontToolView = {
        let view = UINib.init(nibName: "TKFontToolView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! TKFontToolView
        view.delegate = self
        return view
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
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(pageDidCilcked(with:)))
        
        self.tapGesture.delegate = self
        
        self.view.addGestureRecognizer(self.tapGesture)
        
        self.view.addSubview(self.toastView)
        
        
        
        // 先拿到阅读记录，如果没有，返回（0，0）
        
        let record =  TKReadingRecordManager.default.readingRecord(key: novelDataSource.novel.title!)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // 拿到阅读记录附近的章节
        novelDataSource.cacheChaptersNearby(index: record.0) { [unowned self] in
            //更新当前 页码数
            
            self.novelDataSource.page = self.novelDataSource.page(from: record)!
            // 刷新显示
            self.refresh()
            
            // 保存当前观看的阅读记录
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
    
    
    func showFontToolView(){
        
        
        if self.toolView == self.fontToolView {
            return;
        }
        
        if self.toolView == nil {
            self.toolView = self.fontToolView
            self.toolView?.frame = CGRect(x: 0, y: TKScreenHeight, width: TKScreenWidth, height: 100)
            self.showToolView()
        }else{
            self.fontToolView.frame = CGRect(x: 0, y: TKScreenHeight - 49 - 100, width: TKScreenWidth, height: 100)
            UIView.transition(from: self.toolView!, to: self.fontToolView, duration: 0.15, options: .layoutSubviews, completion: { (completion) in
                self.toolView = self.fontToolView;
            })
        }
    }
    
    func showToolView(){
        if self.toolView!.superview == nil{
            self.view.addSubview(self.toolView!)
            UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, animations: {
                self.toolView!.frame = CGRect(x: 0, y: TKScreenHeight - 49 - 100, width: TKScreenWidth, height: 100)
            })
        }
    }
    
    func hiddenToolView() {
        guard self.toolView != nil else {
            return
        }
        if self.toolView!.superview != nil{
            UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, animations: {
                self.toolView!.frame = CGRect(x: 0, y: TKScreenHeight, width: TKScreenWidth, height: 100)
            }, completion: { (suc) in
                self.toolView!.removeFromSuperview()
                self.toolView = nil
            })
        }
    }
    
    
    
    func pageDidCilcked(with gesture:UITapGestureRecognizer){
        let location = gesture.location(in: view)
        // 左边区域
        
        
        if self.topBar.superview != nil && self.bottomBar.superview != nil {
            hiddenBar()
            hiddenToolView()
            return
        }
        
        
        if location.x < TKScreenWidth / 3.0 {
            // 判断是否存在上 一个
            if let page = self.novelDataSource.prePage(){
                // 创建上一页的viewController
                if let viewController =  self.viewController(page: page){
                    // 创建成功， 无动画调到上一页
                    jump(to: viewController, set: page, completion: {  [unowned self] in
                        
                        //  翻页成功后   判断上一章 是否存在
                        if let preChapter = self.novelDataSource.preChapter() {
                            if self.novelDataSource.downloadedChapters[preChapter] == nil {
                                // 如果不存在,解析上一章  
                                //   2 3 4 5      比如说读到第2章，判断第一章是否存在，不存在就下载解析，保存到两个字典里面去
                                self.novelDataSource.parse(chapter: preChapter, completion: {[unowned self] _ in
                                    self.displayToastView(hidden: true)
                                    debugPrint("缓存上一章： 、\(preChapter)")
                                })
                            }
                        }
                    })
                }
 
            }else{
                // 如果上一页不存在，则判断获取上一章
                if let preChapter = novelDataSource.preChapter(){
                    displayToastView(hidden: false)
                    requestChapter(index: preChapter, completion: { [unowned self] in
                        self.displayToastView(hidden: true)
                    })
                    
                }
            }
            return
            
        }else if location.x > 2 * (TKScreenWidth / 3.0) {
            // 右边区域
            if let page = self.novelDataSource.nextPage(){

                if let viewController =  self.viewController(page: page){
                    // 跳到下一章
                    jump(to: viewController, set: page, completion: {[unowned self] in
                        // 检查下下章是否缓存
                        if let nextChapter = self.novelDataSource.nextChapter() {
                            if self.novelDataSource.downloadedChapters[nextChapter] == nil {
                                self.novelDataSource.parse(chapter: nextChapter, completion: {[unowned self] _ in
                                    self.displayToastView(hidden: true)
                                    debugPrint("缓存下一章： 、\(nextChapter)")
                                })
                            }
                        }
                    })
                }
            }else{
                if let nextChapter = novelDataSource.nextChapter(){
                    displayToastView(hidden: false)
                    requestChapter(index: nextChapter, completion: { [unowned self] in
                        self.displayToastView(hidden: true)
                    })
                    
                }
            }
            return
        }else{
            if self.topBar.superview == nil && self.bottomBar.superview == nil {
                showBar()
            }else{
                hiddenBar()
                hiddenToolView()
            }
        }
    }
    
    
    
    
    func jump(to viewcontroller:UIViewController, set page:(Int,Int,Int), completion: (() -> Void)?){
        hiddenBar()
        hiddenToolView()
        
        pageViewController.dataSource = nil
        // 这个 setViewControllers 就是 UIPageViewController 的 reloadData 方法函数
        pageViewController.setViewControllers([viewcontroller], direction: UIPageViewControllerNavigationDirection.forward, animated: false) { [unowned self] (finished) in
            self.novelDataSource.page = page
            completion?()
            let range = self.novelDataSource.downloadedChapters[page.0]!.ranges[page.2]
            self.readingRecord = (page.0,range.0)
            self.pageViewController.dataSource = self
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

        if TKBookshelfService.sharedInstance.novelExists(title: novelDataSource.novel.title!) == false {
            
            let alertController  = UIAlertController(title: nil, message: "是否加入书架？", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (alertAction) in
                // 删除本机下载的记录
                FileManager.default.deleteNovel(title: self.novelDataSource.novel.title!)
                self.dismiss(animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "加入", style: .default, handler: { (alertAction) in
                // 添加书架
                TKBookshelfService.sharedInstance.add(book: self.novelDataSource.novel)
                TKBookshelfService.sharedInstance.cacheBooks(completion: { (finish) in
                    print("保存完毕")
                })
                // 保存阅读记录
                TKReadingRecordManager.default.updateReadingRecord(key: self.novelDataSource.novel.title!, chapterNum: self.readingRecord.0, location: self.readingRecord.1)
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
            
            
        }

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
        if let viewController =  self.viewController(page: page){
            jump(to: viewController, set: page, completion:nil)
        }
 
    }
    
    func requestChapter(index: Int, completion:@escaping ()->Void){
        novelDataSource.parse(chapter: index, completion: {[unowned self]  _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.refresh()
                completion()
            })
        })
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        hiddenBar()
        hiddenToolView()
        
        let vc = pendingViewControllers.first as! TKReadingPageViewController
        let nextIndex = vc.page!
        
        let currentPage = self.novelDataSource.page
        
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
                    novelDataSource.page = next
                    debugPrint("现在 \(next)")
                    
                    if let nextChapter = novelDataSource.nextChapter() {
                        if novelDataSource.downloadedChapters[nextChapter] == nil {
                            requestChapter(index: nextChapter, completion: { [unowned self] in
                                self.displayToastView(hidden: true)
                            })
                        }
                    }
                    
                }
            }else if direction == .pre{
                if let pre = novelDataSource.prePage(){
                    novelDataSource.page = pre
                    debugPrint("现在 \(pre)")
                    
                    if let preChapter = novelDataSource.preChapter() {
                        if novelDataSource.downloadedChapters[preChapter] == nil {
                            requestChapter(index: preChapter, completion: {[unowned self] in
                                self.displayToastView(hidden: true)
                            })
                        }
                    }
                    
                }
            }
            
            //保存当前页码
            
            let currentPage = novelDataSource.page

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
        if let info =  novelDataSource.pageInfo(at: page){
            pegeController.syncUpdateContent(content: info.content)
            
        }
        return pegeController
        
    }
    
    
    
    // MARK: - TKCatalogViewControllerDelegate
    
    
    func catalogViewController(vc: TKCatalogViewController, didSelectRowAt indexPath: Int, chapter: TKChapterListModel) {
        
        if let drawerController = self.parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
            self.hiddenBar()
            self.hiddenToolView()
        }
        
        self.readingRecord = (indexPath,0)
        
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        novelDataSource.cacheChaptersNearby(index: indexPath) { [unowned self] in
            
            let chapterInfo =  self.novelDataSource.downloadedChapters[indexPath]!
            self.novelDataSource.page = (indexPath,chapterInfo.ranges.count,0)
            self.refresh()
            MBProgressHUD.hide(for: self.view, animated: true)
            
        }
        
    }
    
    
    // MARK: - toos protocol
    
    func fontSizeDidChange(_ value: Int) {
        // 清除分页记录。
        // 重新分页
        // 保存阅读记录
        // 保存字号大小
        // 刷新界面
        let newSize =  TKConfigure.default.fonts[value]
        
        if newSize == TKConfigure.default.fontSize!{
            return
        }
        TKConfigure.default.fontSize = newSize
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        novelDataSource.downloadedChapters.removeAll()
        novelDataSource.pageinfos.removeAll()
        
        // 拿到阅读记录附近的章节
        novelDataSource.cacheChaptersNearby(index: self.readingRecord.0) { [unowned self] in
            //更新当前 页码数
            
            self.novelDataSource.page = self.novelDataSource.page(from: self.readingRecord)!
            
            let page = self.novelDataSource.page
            // 刷新显示
            
            if let viewController =  self.viewController(page: self.novelDataSource.page){ 
                self.pageViewController.dataSource = nil
                // 这个 setViewControllers 就是 UIPageViewController 的 reloadData 方法函数
                self.pageViewController.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false) { [unowned self] (finished) in
                    self.novelDataSource.page = page
                    let range = self.novelDataSource.downloadedChapters[page.0]!.ranges[page.2]
                    self.readingRecord = (page.0,range.0)
                    self.pageViewController.dataSource = self
                }
                
            }

            
            // 保存当前观看的阅读记录
            let range = self.novelDataSource.downloadedChapters[self.novelDataSource.page.0]!.ranges[self.novelDataSource.page.2]
            self.readingRecord = (self.novelDataSource.page.0,range.0)
            
            MBProgressHUD.hide(for: self.view, animated: true)
        }


    }
    
    
    // MARK: - gesture delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: view) && !(touch.view is TKContentView){
            return false
        }
        return true
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


