//
//  Common.swift
//  Tricky
//
//  Created by Pillar on 2017/6/11.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit


class TKViewController: UIViewController {

    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
}


class TKTableViewController: UITableViewController {
    
}

class TKNavigationController: UINavigationController,UINavigationControllerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.delegate == nil {
            self.delegate = self
        }
        
        self.interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleInteractivePopGestureRecognizer(gestureRecognizer:)))
    }
    
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        
        let currentViewController = self.topViewController
        
        if let vc = currentViewController {
            vc.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }

        super.pushViewController(viewController, animated: animated)
    }
    
    
    
    
    
    func handleInteractivePopGestureRecognizer(gestureRecognizer:UIScreenEdgePanGestureRecognizer) -> Void {
        let state = gestureRecognizer.state
        if state == .ended {
            if (self.topViewController?.view.superview?.frame.minX)! < (CGFloat)(0.0){
                print("手势返回放弃")
            }else{
                print("手势返回")
            }
        }
    }
    
 
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return self.topViewController?.preferredStatusBarStyle ?? UIStatusBarStyle.lightContent
    }

}


class TKTableViewCell : UITableViewCell{
    func configure(_ model : Any) -> Void {
        return
    }
}
