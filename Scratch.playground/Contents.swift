//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


var myString = "1.1.1.1"
var myStringArray = myString.componentsSeparatedByString(".")
var ia1 = [1,1,1,1]
var ia2: [Int] = [1,1,1,1]
var ia3: [Int] = myStringArray.map({(v:String) -> Int in Int(v) })
ia3


/*
extension Array<String> {
    func toInt() -> [Int]{
        var r:[Int] = [Int]()
        for s in self{
            r.append(Int(s))
        }
        return r
    }
}*/