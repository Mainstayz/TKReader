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
            let currentChapter : TKChapterModel? = novelModel.chapters[novelModel.indexOfChapter]
            if currentChapter != nil {
                self.currentChapter = currentChapter
            }
            
        }
    }
    var currentChapter : TKChapterModel?
    
    var pageViewController : UIPageViewController!
    var cacheData : Dictionary<Int,String> = Dictionary<Int,String>()
    var newIndex : Int = 0
    
    
    func initialize(){
        KVNProgress.setConfiguration(self.hudConfigure)
    }
    
    
    func updateData(){
        // 先从内存拿
        
        let content = self.cacheData[self.novelModel.indexOfChapter]
        // 在硬盘拿
        if content == nil {
  
            let contentPath = FileManager.default.chapterPath(title: self.novelModel.title!, chapterUrl: self.currentChapter?.chapterUrl!)
            // 网络获取
            if contentPath == nil {
                KVNProgress.show()
                self.downData(complete: {[unowned self] (suc,content) in
                    KVNProgress.dismiss()
                    if suc == true && content != nil{
                        self.save(content: content!)
                        self.refresh()
                    }else{
                        

                    }
                })
                
                
                return
            }else{
                // 硬盘读取
                let data = FileManager.default.contents(atPath: contentPath!)
                let content = String(data: data!, encoding: .utf8)
                self.save(content: content!)
                
            }
            
        }else{
            self.save(content: content!)
        }
        
        self.refresh()
        
        
    }
    func downData(complete:@escaping (Bool,String?)->()) -> Void {
        TKNovelService.chapterDetail(url: self.currentChapter!.chapterUrl, source: self.novelModel.source) { (content) in
            if content != nil {
                
                // 1. 保存到内存以及硬盘
                self.save(content: content!)
                // 2. 回调
                complete(true,content)
            }else{
                complete(false,nil)
            }
        }
    }
    
    func save(content: String) -> Void {
        self.cacheData.updateValue(content, forKey: self.novelModel.indexOfChapter)
        FileManager.default.saveNovel(title: self.novelModel.title!, chapterUrl: self.currentChapter!.chapterUrl!, content: content)
        
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
        self.refresh()
        
        self.updateData()
    }
    
    
    
    func refresh() -> Void {
        let viewController = self.viewControllerAtIndex(index: self.novelModel.indexOfChapter)
        if viewController != nil {
            pageViewController.setViewControllers([self.viewControllerAtIndex(index: self.novelModel.indexOfChapter)!], direction: UIPageViewControllerNavigationDirection.forward, animated: false) { (finished) in
                print(finished)
            }
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.currentChapter = self.novelModel.chapters[self.newIndex]
        
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        self.newIndex = self.novelModel.indexOfChapter - 1
        return self.viewControllerAtIndex(index: self.newIndex)
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        self.newIndex = self.novelModel.indexOfChapter + 1
        return self.viewControllerAtIndex(index: self.newIndex)
    }
    
    func viewControllerAtIndex(index:Int) -> UIViewController? {
        
        if index < 0 || index >= self.novelModel.chapters.count || self.cacheData.count == 0 {
            return nil
        }
        
        let pegeController = TKReadingPageViewController()
        let content = self.cacheData[index]
        let title = self.novelModel.chapters[index].chapterName
        pegeController.chapterName = title
        pegeController.content = content
        return pegeController
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
}
