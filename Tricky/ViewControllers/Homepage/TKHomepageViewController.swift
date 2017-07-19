//
//  TKHomepageViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/11.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import KYDrawerController


class TKHomepageViewController: TKViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate{
    
    var books : [TKNovelModel]!
    var itemSize : CGSize!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(notification:)), name: Notification.Name(TKBookshelfNotificationDidAddBook), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(notification:)), name: Notification.Name(TKBookshelfNotificationDidGetBooksFromCache), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cacheBooks(notification:)), name: Notification.Name(TKBookshelfNotificationDidUpdataBookRecard), object: nil)
        
        
        
        
        let row : CGFloat = 3.0
        let width = (CGFloat)((TKScreenWidth - (CGFloat)(row+1.0) * 10)/row)
        let height = width * 12.0 / 9 + 40
        itemSize = CGSize(width: width, height: height)
        
        
        self.collectionView.register(UINib(nibName: "TKBookCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bookCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.books = TKBookshelfService.sharedInstance.books
        
        self.collectionView.reloadData()
        let right = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushSearchViewController))
        self.navigationItem.rightBarButtonItem = right;
        
    }
    
    func refresh(notification:Notification) -> Void {
        DispatchQueue.main.async {
            self.books = TKBookshelfService.sharedInstance.books
            self.collectionView.reloadData()
        }
    }
    
    func cacheBooks(notification:Notification) -> Void {
        
        TKBookshelfService.sharedInstance.cacheBooks { (suc) in
            debugPrint("保存: \(suc)")
        }
        
    }
    
    func pushSearchViewController(){
        let searchViewController = TKSearchViewController()
        let nv = TKNavigationController(rootViewController: searchViewController)
        self.present(nv, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! TKBookCollectionViewCell
        cell.configure(model:self.books[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let novel =  self.books[indexPath.item]
        
        let left = TKCatalogViewController(novel: novel)
        
        let dataSource = TKNovelDataSource(novel: novel)
        
        let reading = TKReadingViewController()
        reading.novelDataSource = dataSource
        left.delegate = reading as! TKCatalogViewControllerDelegate
        
        let drawController = KYDrawerController(drawerDirection: .left, drawerWidth: TKScreenWidth - 44)
        
        drawController.mainViewController = reading
        drawController.drawerViewController = left
        
        self.present(drawController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    
    
    override var prefersStatusBarHidden: Bool{
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
}
