//
//  TKToolsProtocol.swift
//  Tricky
//
//  Created by Pillar on 2017/8/1.
//  Copyright © 2017年 unkown. All rights reserved.
//

import Foundation

@objc protocol TKToolsProtocol: NSObjectProtocol{
    
    @objc optional func fontSizeDidChange(_ value: Int) -> Void
    
    
}
