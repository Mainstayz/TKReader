//
//  UINavigationBar+Animation.swift
//  Tricky
//
//  Created by Pillar on 2017/6/19.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

extension UINavigationBar{
    func setNavigationBarHide(progress:CGFloat) -> Void {
        print(progress)
        if progress > 0 {
            transform = CGAffineTransform.identity.translatedBy(x: 0, y: -bounds.height*progress)
            
        }else {
            transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
        }
//        if let leftViews = value(forKey: "_leftViews") as? [UIView] {
//            for leftView in leftViews {
//                leftView.alpha = 1 - progress
//            }
//        }
//        if let rightViews = value(forKey: "_rightViews") as? [UIView] {
//            for rightView in rightViews {
//                rightView.alpha = 1 - progress
//            }
//        }
//        if let titleView = value(forKey: "_titleView") as? UIView {
//            titleView.alpha = 1 - progress
//        }
    }
}
