//
//  TKCatalogViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/7/19.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit


protocol TKCatalogViewControllerDelegate {
    func catalogViewController(vc : TKCatalogViewController, didSelectRowAt indexPath: Int,chapter: TKChapterModel)
}


class TKCatalogViewController: TKViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    var novel : TKNovelModel!
    var delegate : TKCatalogViewControllerDelegate?
    
    init(novel: TKNovelModel) {
        super.init(nibName: "TKCatalogViewController", bundle: nil)
        self.novel = novel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tableView.backgroundColor = UIColor.clear
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let readingRerord = TKReadingRecordManager.sharedInstance.readingRecord(key: novel.title!)
        tableView.scrollToRow(at: IndexPath(row: readingRerord.0, section: 0), at: .middle, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return novel.chapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "catalog")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "catalog")
        }
        let chapter = novel.chapters[indexPath.row]
        
        cell?.textLabel?.text = chapter.chapterName
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chapter = novel.chapters[indexPath.row]
        self.delegate?.catalogViewController(vc: self, didSelectRowAt: indexPath.row, chapter: chapter)
    }
    
}
