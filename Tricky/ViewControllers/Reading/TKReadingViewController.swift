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
    
    var currentPage : (Int,Int) = (0,0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey:0])
        pageViewController.dataSource = self
        pageViewController.delegate = self;
        pageViewController.view.frame = self.view.bounds
        
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        self.refresh()
        
    }
    
    
    
    func refresh() -> Void {
        
        let viewController =  self.viewController(pageInfo: self.novelDataSource.currentPage())
        currentPage = (self.novelDataSource.currentPage()?.page)!
        if viewController != nil {
            pageViewController.setViewControllers([viewController!], direction: UIPageViewControllerNavigationDirection.forward, animated: false) { (finished) in
                print("刷新完毕：\(finished)")
            }
        }
        
        
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
        }else{
            
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        
        let previousIndex = (previousViewControllers.first as! TKReadingPageViewController).page

        if completed {
            //
            
            
            if direction == .next {
                if let next = novelDataSource.nextPage(){
                    currentPage = next.page
                    novelDataSource.page += 1
                }
            }else if direction == .pre{
                if let pre = novelDataSource.prePage(){
                    currentPage = pre.page
                    novelDataSource.page -= 1
                }
            }

        }else{
            
            // 翻页没成功
            
        }
        
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
         debugPrint(" viewControllerBefore")
        return self.viewController(pageInfo: self.novelDataSource.prePage())
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        debugPrint(" viewControllerAfter")
        return self.viewController(pageInfo: self.novelDataSource.nextPage())
    }
    
    func viewController(pageInfo:TKPageInfoModel?) -> UIViewController? {
        if pageInfo == nil {
            return nil
        }
        let pegeController = TKReadingPageViewController()
        pegeController.syncUpdateContent(content: pageInfo!.content)
        pegeController.chapterName = pageInfo!.title
        pegeController.page = pageInfo!.page
        return pegeController
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
}
