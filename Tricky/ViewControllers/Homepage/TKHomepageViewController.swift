//
//  TKHomepageViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/11.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit


class TKHomepageViewController: TKViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate{

    var books = [TKNovelDetail]()
    var itemSize : CGSize!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let row : CGFloat = 3.0
        let width = (CGFloat)((UIScreen.main.bounds.width - (CGFloat)(row+1.0) * 10)/row)
        let height = width * 12.0 / 9 + 40
        itemSize = CGSize(width: width, height: height)

        
        self.collectionView.register(UINib(nibName: "TKBookCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bookCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        
        let  b =  TKNovelDetail()
        b.url = "11111"
        let  b1 =  TKNovelDetail()
        b.url = "1111221"
        let  b2 =  TKNovelDetail()
        b.url = "111331211"
        let  b3 =  TKNovelDetail()
        b.url = "1114412311"
        let  b4 =  TKNovelDetail()
        b.url = "11113111"
        
        books.append(b)
        books.append(b1)
        books.append(b2)
        books.append(b3)
        books.append(b4)
        
        
        self.collectionView.reloadData()
        
        
        
        let right = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushSearchViewController))
        self.navigationItem.rightBarButtonItem = right;
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath)
        return cell
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
