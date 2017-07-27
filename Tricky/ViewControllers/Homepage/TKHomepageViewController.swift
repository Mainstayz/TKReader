//
//  TKHomepageViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/11.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import KYDrawerController


class TKHomepageViewController: TKViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,TKBookshelfFlowLayoutDelegate{
    
    var books : [TKNovelModel]!
    var itemSize : CGSize!
    var inEditState : Bool = false
    var editButton : UIButton!
    weak var layout : TKBookshelfFlowLayout?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(notification:)), name: Notification.Name(TKBookshelfNotificationDidAddBook), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(notification:)), name: Notification.Name(TKBookshelfNotificationDidGetBooksFromCache), object: nil)


        
        let right = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushSearchViewController))
        self.navigationItem.rightBarButtonItem = right

        
        editButton = UIButton(type:.custom)
        editButton.setTitle("编辑", for: .normal)
        editButton.setTitleColor(UIColor.white, for: .normal)
        editButton.sizeToFit()
        editButton.addTarget(self, action: #selector(changeInEditState), for: .touchUpInside)

        
        
        let row : CGFloat = 3.0
        let width : CGFloat  =  floor((TKScreenWidth - (CGFloat)(row+1.0) * 10)/row)
        let height = width * 12.0 / 9 + 40
        itemSize = CGSize(width: width, height: height)
        
        let layout =  self.collectionView.collectionViewLayout as! TKBookshelfFlowLayout
        layout.delegate = self
        self.layout = layout
        
        self.collectionView.register(UINib(nibName: "TKBookCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bookCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.books = TKBookshelfService.sharedInstance.books
        
        self.reloadData()
        
        
        
        
        
        
        TKBookshelfService.sharedInstance.updateBookshelf(progress: { (suc, index, novel) in
            debugPrint("suc \(suc) , index: \(index), \(String(describing: novel?.title))")
        }) {
            self.cacheBooks()
            self.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    func reloadData(){
        
        if self.books.count == 0 {
            self.navigationItem.leftBarButtonItem = nil
            didChangeEditState(inEditState: false)
            layout?.inEditState = false
        }else{
            let left = UIBarButtonItem(customView: editButton)
            self.navigationItem.leftBarButtonItem = left
        }
        
        self.collectionView.reloadData()
    }
    
    func changeInEditState() -> Void {
        let state = !self.inEditState
        didChangeEditState(inEditState: state)
        layout?.inEditState = state
    }
    func deleteBtnDidClicked(sender: UIButton, event:UIEvent){
        
        let touch = event.allTouches?.first
        if let point = touch?.location(in: collectionView) {
            if let indexPath = collectionView.indexPathForItem(at: point){
                if indexPath.section == 0{
                    
                    let novel = self.books[indexPath.item]
                    collectionView.performBatchUpdates({ [unowned self] in
                        self.collectionView.deleteItems(at: [indexPath])
                        self.books.remove(at: indexPath.item)
                    }, completion: { [unowned self] (finished) in
                        // 删除书架
                        
                        TKBookshelfService.sharedInstance.books.remove(at: indexPath.item)
                        TKBookshelfService.sharedInstance.cacheBooks { (suc) in
                            debugPrint("删除: \(suc)")
                        }

                        
                        // 删除本机下载的记录
                        FileManager.default.deleteNovel(title: novel.title!)
                        // 删除观看记录
                        TKReadingRecordManager.default.removeReadingRecord(key: novel.title!)
                        // 保存
                        self.cacheBooks()
                        
                        self.reloadData()
                    })
                }
            }
            
        }
        
        
        
    }
    
    
    func refresh(notification:Notification?) -> Void {
        DispatchQueue.main.async {
            self.books = TKBookshelfService.sharedInstance.books
            self.reloadData()
        }
    }
    
    func cacheBooks() -> Void {
        
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
        cell.setInEditState(edit: self.inEditState)
        cell.closeButton.addTarget(self, action: #selector(deleteBtnDidClicked(sender:event:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let novel =  self.books[indexPath.item]
        
        let left = TKCatalogViewController(novel: novel)
        
        let dataSource = TKNovelDataSource(novel: novel)
        
        let reading = TKReadingViewController()
        reading.novelDataSource = dataSource
        left.delegate = reading as TKCatalogViewControllerDelegate
        
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
    
    
    // MARK: - 
    
    
    func moveItem(atIndex: IndexPath, toIndex: IndexPath) {
        swap(&self.books[atIndex.item], &self.books[toIndex.item])
        swap(&TKBookshelfService.sharedInstance.books[atIndex.item], &TKBookshelfService.sharedInstance.books[toIndex.item])

        self.cacheBooks()
    }
    
    func didChangeEditState(inEditState: Bool) {
        self.inEditState  = inEditState
        for cell in collectionView.visibleCells {
            (cell as! TKBookCollectionViewCell).setInEditState(edit: inEditState)
        }
        if inEditState {
            editButton.setTitle("取消", for: .normal)
        }else{
            editButton.setTitle("编辑", for: .normal)
        }
        
    }
    
    // MARK: -
    
    override var prefersStatusBarHidden: Bool{
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
}
