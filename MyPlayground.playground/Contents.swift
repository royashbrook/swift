//: Playground - noun: a place where people can play

import UIKit

func pad(string : String, toSize: Int, padstring: String) -> String {
    var padded = string
    for i in 0..<toSize - count(string) {
        padded = "0" + padded
    }
    return padded
}

extension String {
    // Faster version
    // benchmarked with a 1000 characters and 100 repeats the fast version is approx 500 000 times faster :-)
    func repeat(n:Int) -> String {
        var result = self
        for _ in 1 ..< n {
            result.extend(self)   // Note that String.extend is up to 10 times faster than "result += self"
        }
        return result
    }
}

let num = "192"
let str = String(num.toInt()!, radix: 2)
println(str) // 10110
pad(str, 8,"0")  // 00010110

    var a: Int = 16
    var b: String = "11111000111111110110000000011000"
// below per http://stackoverflow.com/questions/24044851/how-do-you-use-string-substringwithrange-or-how-do-ranges-work-in-swift
    var c: String = (b as NSString).substringWithRange(NSMakeRange(0,a))
    var d: String = c + "0".repeat(32-a)

    var aa: NSString = (b as NSString)
        var x = strtoul(aa.substringWithRange(NSMakeRange(0,8)),nil,2)
x.description + "."







    var bb: NSString =
    aa.substringWithRange(NSMakeRange(0,8)) + "."
        + aa.substringWithRange(NSMakeRange(8,8)) + "."
        + aa.substringWithRange(NSMakeRange(16,8)) + "."
        + aa.substringWithRange(NSMakeRange(24,8))


let binary = "11001"
let number = strtoul(binary, nil, 2)
println(number) // Output: 25