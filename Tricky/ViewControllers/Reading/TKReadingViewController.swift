//
//  TKReadingViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import KVNProgress
class TKReadingViewController: TKViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    
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
    
    var currentPage : (Int,Int)!
    
    var needCacheChapters = [Int]()
    
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
        

       let tap = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        
        self.view.addGestureRecognizer(tap)
    
        KVNProgress.show()
        novelDataSource.cacheChaptersNearby(index: novelDataSource.currentPage()!.0) { [unowned self] in
            self.refresh()
            KVNProgress.dismiss()
        }
    }
    
    
    
   
    
    
    func dismissViewController(){
        self.dismiss(animated: true, completion: nil)
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
        
        let vc = pendingViewControllers.first as! TKReadingPageViewController
        let nextIndex = vc.page!
        
        if nextIndex.0 == currentPage.0 {
            if nextIndex.1 > currentPage.1 {
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

                }
            }else if direction == .pre{
                if let pre = novelDataSource.prePage(){
                    currentPage = pre
                    novelDataSource.page = pre
                    debugPrint("现在 \(pre)")
                }
            }

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
    
    
    
    func viewController(page:(Int,Int)?) -> UIViewController? {
        
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
    
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
}
