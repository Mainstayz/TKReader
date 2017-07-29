//
//  FileManager.swift
//  Tricky
//
//  Created by Pillar on 2017/6/25.
//  Copyright © 2017年 unkown. All rights reserved.
//

import Foundation

extension FileManager{
    
    func novelRootPath() -> String {
        return NSHomeDirectory() + "/Documents/novel/"
    }
    
    func creatDirectory(path: String) -> Bool{
        var isDir: ObjCBool = ObjCBool(false)
        let isDirExist = self.fileExists(atPath: path, isDirectory: &isDir)
        
        if !isDir.boolValue && isDirExist {
            do {
                try self.removeItem(atPath: path)
            } catch let error as NSError {
                print("Error remove directory: \(error.localizedDescription)")
                return false
            }
        }
        
        
        if !isDir.boolValue && !isDirExist {
            do {
                try self.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
                return false
            }
        }
        
        return true
    }
    
    // 保存小说章节
    func saveNovel(title:String,chapterUrl: String,content:String) -> Void{
        // 异步
        let queue = DispatchQueue(label: "com.saveNove.tk")
        queue.async {
            
            if chapterUrl.count == 0 || content.count == 0 {
                print("should not be empty....")
                return
            }
            
            let rootPath = self.novelRootPath()
            let novelPath = rootPath + "\(title)/"
            let suc =  self.creatDirectory(path: novelPath)
            
            guard suc == true else {
                return
            }
            
            
            // 获取到了 小说章节 保存的全路径
            let chapterPath = novelPath + "\(chapterUrl.md5())"
            
            
            do{
                // 小说章节内容写入磁盘
                try content.write(toFile: chapterPath, atomically: true, encoding: .utf8)
                
                print("保存成功----\(chapterPath)")
                
            }catch let error as NSError {
                print("Error save directory: \(error.localizedDescription)")
            }
            
        }
    }
    
    // 获取小说某个章节的缓存路径，如果存在表示缓存过，如果为nil就是没有缓存

    func chapterPath(title:String?, chapterUrl: String?) -> String?{
        guard title != nil && chapterUrl != nil else {
            return nil
        }
        
        let rootPath = self.novelRootPath()
        let chapterPath = rootPath+"\(title!)/"+"\(chapterUrl!.md5())"
        
        // 说明缓存过了
        let isExist = self.fileExists(atPath: chapterPath)
        
        guard isExist == true else{
            return nil
        }
        
        return chapterPath
        
    }
    
    // 删除某个小说
    func deleteNovel(title :String){
        guard title.count > 0 else {
            return
        }
        
        let rootPath = self.novelRootPath()
        let novelPath = rootPath+"\(title)/"
        
        do{
            try self.removeItem(atPath: novelPath)
        }catch let error as NSError {
            print("Error remove directory: \(error.localizedDescription)")
        }
        
        
    }
    
}
