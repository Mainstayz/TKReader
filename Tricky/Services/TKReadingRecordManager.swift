//
//  TKReadingRecordManager.swift
//  Tricky
//
//  Created by Pillar on 2017/7/23.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit

let chapterNumber = "TKChapterNumber"
let chapterLoaction = "TKChapterLoaction"

class TKReadingRecordManager: NSObject {
    
    var record : Dictionary<String,Dictionary<String, Int>>!
    
    static let sharedInstance = TKReadingRecordManager.init()
    private override init() {
        super.init()
    }
    
    private func readingRecordPath() -> String {
        return NSHomeDirectory() + "/Documents/ReadingRecord.tk"
    }
    
    private func checkRecord(){
        if let data = NSData(contentsOfFile: readingRecordPath()) {
            do {
                let json = try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers)
                let dic = json as! Dictionary<String,Dictionary<String, Int>>
                record = dic
            } catch _ {
                record = Dictionary<String,Dictionary<String, Int>>()
            }
        }else{
            record = Dictionary<String,Dictionary<String, Int>>()
        }
    }
    
    func updateReadingRecord(key:String,chapterNum:Int,location:Int) -> Void {
        checkRecord()
        let readingRecord = [chapterNumber:chapterNum,chapterLoaction:location]
        record[key] = readingRecord
        save()
    }
    func readingRecord(key:String) -> (Int,Int) {
        checkRecord()
        if let readingRecord = record[key] {
            return (readingRecord[chapterNumber]!,readingRecord[chapterLoaction]!)
        }
        return (0,0)
    }
    func removeReadingRecord(key:String) -> Void {
        checkRecord()
        record[key] = nil
    }
    
    func removeAllReadingRecord() -> Void {
        record = Dictionary<String,Dictionary<String, Int>>()
        do{
            try FileManager.default.removeItem(atPath: readingRecordPath())
        }catch let error as NSError {
            print("Error remove directory: \(error.localizedDescription)")
        }

    }
    
    
    
    func save() -> Void {
        
        if(!JSONSerialization.isValidJSONObject(record)) {
            print("is not a valid json object")
            return
            
        }
        
        //利用自带的json库转换成Data
        
        //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
        
        let data = try? JSONSerialization.data(withJSONObject: record, options:.prettyPrinted)
        
        do {
            try data?.write(to:URL(fileURLWithPath: readingRecordPath()))
        } catch _ {
            debugPrint("阅读记录保持失败。。。")
        }
        
    }
}
