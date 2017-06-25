//
//  TKContentView.swift
//  Tricky
//
//  Created by Pillar on 2017/6/26.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

class TKContentView: UIView {
    
    var imageView : UIImageView = UIImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var attributedText : NSAttributedString?{
        didSet{
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.rander()
    }
    
    
    func rander() -> Void {
        
        
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
            
            DispatchQueue.main.async {
                self.imageView.image = img
            }

        }
    
        
        
    }
     /*
     - (void)setText:(NSAttributedString *)attributedText
     {
     self.attributedText = attributedText;
     [self setNeedsDisplay];
     }
     
     - (void)drawRect:(CGRect)rect {
     
     // Drawing code
     CGContextRef context = UIGraphicsGetCurrentContext();
     // Flip the coordinate system
     CGContextSetTextMatrix(context, CGAffineTransformIdentity);
     CGContextTranslateCTM(context, 0, self.bounds.size.height);
     CGContextScaleCTM(context, 1.0, -1.0);
     
     CTFramesetterRef childFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
     UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRect:rect];
     CTFrameRef frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.CGPath, NULL);
     CTFrameDraw(frame, context);
     CFRelease(frame);
     CFRelease(childFramesetter);
     
     }    */

    
    
    
    
}
