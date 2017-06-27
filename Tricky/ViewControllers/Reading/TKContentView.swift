//
//  TKContentView.swift
//  Tricky
//
//  Created by Pillar on 2017/6/26.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKContentView: UIView {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var attributedText : NSAttributedString?{
        didSet{
            self.render()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    func render() -> Void {
        
        self.layer.sublayers?.map({$0.removeFromSuperlayer()})
        
        DispatchQueue.init(label: "com.drawImage.tk").async {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0);
            let context = UIGraphicsGetCurrentContext()
            context?.textMatrix = .identity
            context?.translateBy(x: 0, y: self.bounds.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            
            let childFramesetter = CTFramesetterCreateWithAttributedString(self.attributedText!)
            
            let besizer = UIBezierPath(rect: self.bounds)
            let frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), besizer.cgPath, nil)
            CTFrameDraw(frame, context!)
            
            let img = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();

            let cgImg = img!.cgImage
            
            
            let maxLength : CGFloat = 5000
            
            if img!.size.height > maxLength {
                
                var totalLength = img!.size.height
                var height  = maxLength
                var y : CGFloat = 0
                var rectArr = [CGRect]()
                
                repeat{
                    let rect = CGRect(x: 0, y: y, width: img!.size.width, height: height)

                    y += height
                    totalLength -= maxLength
                    height = totalLength < maxLength ?  totalLength : maxLength
                    rectArr.append(rect)
                }while(totalLength > 0.0)
                
                for rect in rectArr{
                    
                    DispatchQueue.main.async {
                        let subImg = cgImg!.cropping(to: CGRect(x: 0, y: rect.origin.y * img!.scale, width: rect.width * img!.scale, height: rect.height * img!.scale))
                        let layer = CALayer()
                        layer.contentsScale = UIScreen.main.scale
                        layer.contents = subImg
                        layer.frame = rect
                        self.layer.addSublayer(layer)
                    }

                }

            }else{
                DispatchQueue.main.async {
                    let layer = CALayer()
                    layer.contentsScale = UIScreen.main.scale
                    layer.contents = cgImg
                    layer.frame = self.bounds
                    self.layer.addSublayer(layer)
                }
            }
        }
        
    }
    
}
