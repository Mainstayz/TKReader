//
//  TKBookshelfFlowLayout.swift
//  Tricky
//
//  Created by Pillar on 2017/7/24.
//  Copyright © 2017年 unkown. All rights reserved.
//


import UIKit

@objc protocol TKBookshelfFlowLayoutDelegate {
    func moveItem(atIndex:IndexPath, toIndex:IndexPath)
    func didChangeEditState(inEditState:Bool)
}

class TKBookshelfFlowLayout: UICollectionViewFlowLayout,UIGestureRecognizerDelegate {
    
    private var _inEditState : Bool! = false
    
    var inEditState : Bool!{
        get{
            return _inEditState
        }
        set{
            if _inEditState != newValue {
                delegate?.didChangeEditState(inEditState: newValue)
            }
            _inEditState = newValue
        }
    }
    @IBOutlet var delegate : TKBookshelfFlowLayoutDelegate?
    
    
    private var longGesture : UILongPressGestureRecognizer!
    private var currentIndexPath : IndexPath!
    private var movePoint : CGPoint!
    private var moveView : UIView!
    private var difPotin : CGPoint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureObserver()
    }
    
    override init() {
        super.init()
        self.configureObserver()
    }
    
    func configureObserver() -> Void {
        addObserver(self, forKeyPath: "collectionView", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "collectionView" {
            setUpGestureRecognizers()
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func setUpGestureRecognizers() -> Void {
        guard collectionView != nil else {
            return
        }
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGesture(gesture:)))
        longGesture.minimumPressDuration = 0.3
        longGesture.delegate = self
        collectionView!.addGestureRecognizer(longGesture)
        
        
    }
    
    func longGesture(gesture: UILongPressGestureRecognizer) -> Void {
        if self.inEditState == false {
            self.inEditState = true
        }
        
        
        
        switch gesture.state {
        case .began:
            
            let location = gesture.location(in: collectionView)
            let indexPath = collectionView?.indexPathForItem(at: location)
            if indexPath == nil || indexPath?.section != 0 {
                return
            }
            
            currentIndexPath = indexPath!
            
            if let targetCell = collectionView?.cellForItem(at: indexPath!){
                moveView = targetCell.snapshotView(afterScreenUpdates: true)
                targetCell.isHidden = true
                moveView.center = targetCell.center
                difPotin = CGPoint(x: location.x - targetCell.center.x, y: location.y - targetCell.center.y)
                collectionView?.addSubview(moveView)
                moveView.transform.scaledBy(x: 1.1, y: 1.1)
                
            }
            
            break
        case .changed:
           
            var point = gesture.location(in: collectionView)
            point.x -= difPotin.x
            point.y -= difPotin.y
            moveView.center = point
            
            if let indexPath = collectionView?.indexPathForItem(at: point) {
                if indexPath.section == currentIndexPath.section && indexPath.section == 0{
                    if indexPath.item != currentIndexPath.item {
                        delegate?.moveItem(atIndex: currentIndexPath, toIndex: indexPath)
                        collectionView?.moveItem(at: currentIndexPath, to: indexPath)
                        currentIndexPath = indexPath
                    }
                    
                }
            }
            
            break
        case .ended:
            difPotin = CGPoint.zero
            if let cell = collectionView?.cellForItem(at: currentIndexPath) {
                UIView.animate(withDuration: 0.25, animations: {
                    self.moveView.center = cell.center
                }, completion: { (finished) in
                    self.moveView.removeFromSuperview()
                    cell.isHidden = false
                    self.moveView = nil
                    self.currentIndexPath = nil
                    self.collectionView?.reloadData()
                })
            }
            break
        default:
            break
        }

    }
    
    
    deinit {
        self.removeObserver(self, forKeyPath: "collectionView")
    }
    
}
