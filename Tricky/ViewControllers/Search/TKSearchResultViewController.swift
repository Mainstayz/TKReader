//
//  TKSearchResultViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/24.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import SVPullToRefresh
import MBProgressHUD

class TKSearchResultViewController: UITableViewController {
    
    var novels :[TKNovelModel]!{
        didSet{
            
            guard let list = novels else{return}
            if list.count == 0 {
                self.tableView.infiniteScrollingView.enabled = false
            }else{
                self.tableView.infiniteScrollingView.enabled = true
            }
        }
    }
    var page = 0
    var keyword : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "TKSearchResultCell", bundle: nil), forCellReuseIdentifier:"cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.keyboardDismissMode = .onDrag
        
        tableView.addInfiniteScrolling { [unowned self] in
            self.page += 1
            self.search(keyword: self.keyword!)
        }
        novels = [TKNovelModel]()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func search(keyword :String) -> Void {
        if page == 0 {
            novels.removeAll()
        }
        
       MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        TKNovelRequest.searchNovel(source: .Buquge, keyword: keyword, page: page) { (list) in ()
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            guard list != nil else {
                self.tableView.reloadData()
                self.tableView.infiniteScrollingView.stopAnimating()
                return
            }
            self.novels.append(contentsOf: list!)
            self.tableView.reloadData()
            self.tableView.infiniteScrollingView.stopAnimating()
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.novels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TKSearchResultCell
        cell.configure(self.novels[indexPath.row])
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = TKDetailViewController()
        detail.bookDetail = self.novels[indexPath.row]
        self.presentingViewController?.navigationController?.pushViewController(detail, animated: true)
    }
    
    
    // MARK: - UISearchBarDelegate
    

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
