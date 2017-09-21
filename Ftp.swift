//
//  Ftp.swift
//  FtpExplorer
//
//  Created by Bernardo Breder on 24/06/15.
//  Copyright (c) 2015 Bernardo Breder. All rights reserved.
//

import Foundation
//import CFNetwork

class Ftp {
    
    let host: String
    
    let user: String
    
    let pass: String
    
    init(host: String, user: String, pass: String) {
        self.host = host
        self.user = user
        self.pass = pass
    }
    
    func dataFromPath(path: String) -> NSData? {
        let url: NSURL? = NSURL(string: "ftp://ftp." + host + path)
        if url == nil {
            return nil
        }
        let streamRef: Unmanaged<CFReadStream>! = CFReadStreamCreateWithFTPURL(nil, url!)
        let stream: CFReadStream = streamRef.takeRetainedValue()
        CFReadStreamSetProperty(stream, kCFStreamPropertyFTPUserName, user)
        CFReadStreamSetProperty(stream, kCFStreamPropertyFTPPassword, pass)
        CFReadStreamOpen(stream)
        let data: NSMutableData = NSMutableData(capacity: 1024)!
        let buffer: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.alloc(1024)
        for ;; {
            let count: CFIndex = CFReadStreamRead(stream, buffer, 1024)
            if count == 0 { break }
            if count == -1 { return nil }
            data.appendBytes(buffer, length: count)
        }
        CFReadStreamClose(stream)
        return data
    }
    
    func listPaths(path: String) -> [String]? {
        let data: NSData? = self.dataFromPath(path + "/")
        if data == nil {
            return nil
        }
        let content: NSString? = NSString(data:data!, encoding:NSUTF8StringEncoding)
        if content == nil {
            return nil
        }
        let array: [NSString] = content!.componentsSeparatedByString("\n") as! [NSString]
        var result: [String] = []
        let trim: NSCharacterSet = NSCharacterSet(charactersInString: "\r")
        for (idx: Int, line: NSString) in enumerate(array) {
            if idx >= 2 && line.length >= array[0].length {
                let name: NSString = line.substringFromIndex(array[0].length-2)
                let nameTrim: NSString = name.stringByTrimmingCharactersInSet(trim)
                result.append(String(nameTrim))
            }
        }
        return result
    }
    
}