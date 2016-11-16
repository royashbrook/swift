//
//  Extensions.swift
//  IPInfo
//
//  Created by Roy Ashbrook on 6/19/15.
//  Copyright (c) 2015 Roy Ashbrook. All rights reserved.
//

import Foundation


//Helper Extensions
extension String {
    
    func repeat(n:Int) -> String {
        var result = self
        for _ in 1 ..< n {
            result.extend(self)   // Note that String.extend is up to 10 times faster than "result += self"
        }
        return result
    }
    //enum padSide { case left, right }
    //todo: dry below..
    func padLeft(withString: String, toSize: Int) -> String {
        var s = self
        var len = count(s)
        var diff = toSize - len
        return diff > 0 ? withString.repeat(diff) + s : s
    }
    func padRight(withString: String, toSize: Int) -> String {
        var s = self
        var len = count(s)
        var diff = toSize - len
        return diff > 0 ? s + withString.repeat(diff) : s
    }
    func injectDelim(delim: Character, every: Int) -> String {
        var i: Int = 0
        var s: String = ""
        for char in self {
            s.extend(String(char))
            i++
            if (i % every == 0){
                s.extend(String(delim))
                i==0
            }
        }
        return s
    }
    //string decimal to string binary
    func toDecimalFromBinary() -> String {
        return strtoul(self,nil,2).description
    }
    //string int to string binary
    func toBinaryFromDecimal() -> String{
        return self.toInt()!.toBinaryString()
    }
    //string int to string binary padded to 8 bits
    func to8BitBinaryFromDecimal() -> String{
        return self.toInt()!.to8bitPaddedBinaryString()
    }
    //convert ip binary to standard decimal notation ip address
    func BinaryIPToDecimalIP() -> String{
        var a: NSString = (self as NSString)
        var b: String = ""
        for var i = 0; i <= 24; i += 8 {
            b.extend(a.substringWithRange(NSMakeRange(i,8)).toDecimalFromBinary())
            if i < 24 { b.extend(".") }
        }
        return b
    }
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}
extension Int{
    //int to string binary
    func toBinaryString() ->String{
        return String(self, radix: 2)
    }
    //int to string binary
    func to8bitPaddedBinaryString() ->String{
        return self.toBinaryString().padLeft("0",toSize: 8)
    }
}