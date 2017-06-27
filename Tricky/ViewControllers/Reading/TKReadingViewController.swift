//
//  TKReadingViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import KVNProgress
class TKReadingViewController: TKViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource {
    
    enum TKReadingDirection: Int {
        case none = -1
        case up
        case bottom
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
    
    
    
    var novelModel: TKNovelModel! {
        didSet {
            let currentChapter : TKChapterModel? = self.novelModel.chapters[self.novelModel.indexOfChapter]
            if currentChapter != nil {
                
                self.currentIndex = self.novelModel.indexOfChapter
            }
            
        }
    }
    
    var pageViewController : UIPageViewController!
    var cacheData : Dictionary<Int,String> = Dictionary<Int,String>()
    
    var currentIndex : Int = 0
    
    
    var direction : TKReadingDirection = .none
    
    func initialize(){
        KVNProgress.setConfiguration(self.hudConfigure)
    }
    
    
    
    // 缓存xxx章数据
    func cacheData(at index : Int, completion:@escaping(Bool,String?)->()){
        debugPrint("先从内存拿章节")
        let content = self.cacheData[index]
        // 在硬盘拿
        if content == nil {
            debugPrint("内存找不到，判断是非存在硬盘中 -- ")
            
            let chapterUrl = self.novelModel.chapters[index].chapterUrl!
            
            let contentPath = FileManager.default.chapterPath(title: self.novelModel.title!, chapterUrl:chapterUrl)
            
            if contentPath == nil {
                debugPrint("硬盘找不到，网络下载 -- ")
                
                self.showHUD(at: index)
                self.downData(index: index, complete: {[unowned self] (suc,newContent) in
                    
                    self.hiddenHUD(at: index)
                    if suc == true && newContent != nil{
                        debugPrint("下载成功，缓存数据，返回")
                        self.cacheData.updateValue(newContent!, forKey: index)
                        completion(true,newContent)
                        FileManager.default.saveNovel(title: self.novelModel.title!, chapterUrl:chapterUrl, content: newContent!)
                    }else{
                        debugPrint("网络下载失败。。。")
                        completion(false,nil)

                    }
                })
                return
            }else{
                // 硬盘读取
                debugPrint("硬盘中找到了，保存到内存中，并返回 ")
                let data = FileManager.default.contents(atPath: contentPath!)
                let aContent = String(data: data!, encoding: .utf8)
                self.cacheData.updateValue(aContent!, forKey: index)
                completion(true,aContent!)
                return
            }
            
        }else{
            //如果拿到了
            debugPrint("从内存中获取数据 返回")
            completion(true,content!)
            return
        }
        
        
        
        
        
    }
    
    
    func showHUD(at index : Int) -> Void {
        if index == self.currentIndex {
            // 调用 对象方法 更好？？
            debugPrint("下载页 等于 当前页面 ，显示HUD ")
            KVNProgress.show()
            
        }
    }
    
    func hiddenHUD(at index: Int) -> Void {
        if index == self.currentIndex {
            debugPrint("下载页 等于 当前页面 ，隐藏HUD ")
            KVNProgress.dismiss()
            
        }
    }
    
    // 下载xx章数据
    func downData(index:Int, complete:@escaping (Bool,String?)->()) -> Void {
        
        let chapter = self.novelModel.chapters[index]
        
        TKNovelService.chapterDetail(url: chapter.chapterUrl, source: self.novelModel.source) { (content) in
            if content != nil {
                complete(true,content)
            }else{
                complete(false,nil)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: [UIPageViewControllerOptionInterPageSpacingKey:60])
        pageViewController.dataSource = self
        pageViewController.delegate = self;
        pageViewController.view.frame = self.view.bounds
        
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        self.cacheData(at: self.currentIndex, completion: { [unowned self] (suc, content) in
            self.refresh()
        })
    }
    
    
    
    func refresh() -> Void {
        
        let viewController = self.viewControllerAtIndex(index: self.currentIndex)
        if viewController != nil {
            pageViewController.setViewControllers([self.viewControllerAtIndex(index: self.currentIndex)!], direction: UIPageViewControllerNavigationDirection.forward, animated: false) { (finished) in
                print("刷新完毕：\(finished)")
            }
        }
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        let vc = pendingViewControllers.first as! TKReadingPageViewController
        let nextIndex = vc.index!
        vc.scrollViewDirectionType = nextIndex > self.currentIndex ?  .up : .bottom
        
        debugPrint(" 即将加载\(vc.index)章")
        // 后续章节缓存。。也好
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        
        let previousIndex = (previousViewControllers.first as! TKReadingPageViewController).index!

        if completed {
            //
            
            
            
            self.currentIndex = self.direction == .bottom ? previousIndex + 1 : previousIndex - 1
            
//            let content = self.cacheData[self.currentIndex]
            
//            if content == nil {
//                self.showHUD(at: self.currentIndex)
//            }
            
            
            self.novelModel.indexOfChapter = self.currentIndex
            
            
            // todo : 注意保存阅读的章节数。或者 进行后续章节缓存。。。
            //
            //
        }else{
            
            // 翻页没成功
            
        }
        
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        self.direction = .up
        
        let currentIndex = (viewController as! TKReadingPageViewController).index!
        
        return self.viewControllerAtIndex(index: currentIndex - 1)
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        self.direction = .bottom
        
        let currentIndex = (viewController as! TKReadingPageViewController).index!
        
        return self.viewControllerAtIndex(index: currentIndex + 1)
    }
    
    func viewControllerAtIndex(index:Int) -> UIViewController? {
        
        if index < 0 || index >= self.novelModel.chapters.count || self.cacheData.count == 0 {
            return nil
        }
        
        let pegeController = TKReadingPageViewController()
        let title = self.novelModel.chapters[index].chapterName
        let content = self.cacheData[index]
        
        if content == nil {
            self.cacheData(at: index, completion: {(suc, newContent) in
                if newContent != nil {
                    pegeController.asyncUpdateContent(content: newContent!)
                }
            })
        }else{
            pegeController.syncUpdateContent(content: content!)
        }
        
        pegeController.chapterName = title
        pegeController.index = index
        return pegeController
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
}
