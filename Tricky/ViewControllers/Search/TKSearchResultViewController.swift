//
//  TKSearchResultViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/24.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import SVPullToRefresh

class TKSearchResultViewController: UITableViewController, UISearchBarDelegate {
    
    var novels :[TKNovelDetail]!{
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
        novels = [TKNovelDetail]()
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
        
        TKNovelService.searchNovel(source: TKBiqugeSource().source, keyword: keyword, page: page) { (list) in
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
    

    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        page = 0
    
        if let text = searchBar.text{
            keyword = text.trimmingCharacters(in: .whitespaces)
            self.search(keyword: keyword!)
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
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
