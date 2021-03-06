//
//  TKDetailViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import CWStatusBarNotification
import KYDrawerController


class TKDetailViewController: TKViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var authorLab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    
    var statusBarNotification = CWStatusBarNotification()
    var bookDetail : TKNovelModel!
    var didUpdata = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusBarNotification.notificationLabelBackgroundColor = themeBackgroundColor
        self.statusBarNotification.notificationLabelTextColor = themeTextColor
        self.statusBarNotification.notificationStyle = .navigationBarNotification
        
        self.imgView.sd_setImage(with: URL(string: self.bookDetail.img!))
        self.titleLab.text = self.bookDetail.title
        self.authorLab.text = self.bookDetail.author
        self.contentLab.text = self.bookDetail.desc
        
    }
    
    @IBAction func read() -> Void {
        
        if self.didUpdata {
            
            let left = TKCatalogViewController(novel: self.bookDetail)
            
            let dataSource = TKNovelDataSource(novel: self.bookDetail)
            
            let reading = TKReadingViewController()
            reading.novelDataSource = dataSource
            left.delegate = reading as TKCatalogViewControllerDelegate
            
            let drawController = KYDrawerController(drawerDirection: .left, drawerWidth: TKScreenWidth - 44)
            drawController.mainViewController = reading
            drawController.drawerViewController = left
            
            self.present(drawController, animated: true, completion: nil)

            
        }else{
            
            self.statusBarNotification.display(withMessage: "正在读取数据", completion: nil)
            
            self.updateData { [unowned self] (finied) in
                
                self.didUpdata = finied
                self.statusBarNotification.dismiss()

                let left = TKCatalogViewController(novel: self.bookDetail)
                
                let dataSource = TKNovelDataSource(novel: self.bookDetail)
                
                let reading = TKReadingViewController()
                reading.novelDataSource = dataSource
                left.delegate = reading as TKCatalogViewControllerDelegate
                
                let drawController = KYDrawerController(drawerDirection: .left, drawerWidth: TKScreenWidth - 44)
                drawController.mainViewController = reading
                drawController.drawerViewController = left
                
                self.present(drawController, animated: true, completion: nil)

                
                
                
            }
        }
    }
    @IBAction func addToBookrack() -> Void {
        
        if  self.didUpdata {
            return
        
        }

        
        self.statusBarNotification.display(withMessage: "正在读取数据", completion: nil)
        self.updateData { [unowned self] (finied) in
            self.didUpdata = finied
            self.statusBarNotification.dismiss()
            TKBookshelfService.sharedInstance.add(book: self.bookDetail)
            TKBookshelfService.sharedInstance.cacheBooks(completion: { (finish) in
                print("保存完毕")
            })
        }
    
    }
    
    
    
    func updateData(complete:@escaping (Bool)->()) -> Void {
        TKNovelRequest.novelDetail(url: self.bookDetail.url!, source: TKNovelSourceKey.Buquge) { (detail) in
            if detail != nil {
                self.bookDetail = detail
                complete(true)
            }else{
                complete(false)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
