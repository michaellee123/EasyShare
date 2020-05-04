//
//  DataUtils.swift
//  EasyShare
//
//  Created by Michael Lee on 2020/5/4.
//  Copyright © 2020 Michael Lee. All rights reserved.
//
import PerfectCrypto

import Foundation

class DataUtils{
    
    static func generateKey(name :String) -> String{
        let md5 = "\(NSDate().timeIntervalSince1970)\(name)".digest(.md5)?.encode(.base64url)
        return String(validatingUTF8: md5!) ?? "\(NSDate().timeIntervalSince1970)\(name)"
    }
    
}
