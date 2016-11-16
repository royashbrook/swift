//: Playground - noun: a place where people can play

import UIKit

//IPv4 Address Object
class Address{
    var o_1: Int //octet 1
    var o_2: Int //octet 2
    var o_3: Int //octet 3
    var o_4: Int //octet 4
    
    //todo: bounds checking
    init(Octet1:Int,Octet2:Int,Octet3:Int,Octet4:Int) {
        self.o_1 = Octet1 //should be 0-255
        self.o_2 = Octet2 //should be 0-255
        self.o_3 = Octet3 //should be 0-255
        self.o_4 = Octet4 //should be 0-255
    }
    init(DottedDecimal:String){
        let dd:[String] = DottedDecimal.componentsSeparatedByString(".")
        var Octet1: String = dd[0] //should be 0-255
        var Octet2: String = dd[1] //should be 0-255
        var Octet3: String = dd[2] //should be 0-255
        var Octet4: String = dd[3] //should be 0-255
        self.o_1 = Octet1.toInt()! //should be 0-255
        self.o_2 = Octet2.toInt()! //should be 0-255
        self.o_3 = Octet3.toInt()! //should be 0-255
        self.o_4 = Octet4.toInt()! //should be 0-255
    }
    init(BinaryString:String){
        let dd:[String] = BinaryString.BinaryIPToDecimalIP().componentsSeparatedByString(".")
        var Octet1: String = dd[0] //should be 0-255
        var Octet2: String = dd[1] //should be 0-255
        var Octet3: String = dd[2] //should be 0-255
        var Octet4: String = dd[3] //should be 0-255
        self.o_1 = Octet1.toInt()! //should be 0-255
        self.o_2 = Octet2.toInt()! //should be 0-255
        self.o_3 = Octet3.toInt()! //should be 0-255
        self.o_4 = Octet4.toInt()! //should be 0-255
    }
    //const
    let p:String = "." //period delimiter
    
    //octet strings
    var so_1: String { return String(self.o_1) }//octet 1
    var so_2: String { return String(self.o_2) }//octet 2
    var so_3: String { return String(self.o_3) }//octet 3
    var so_4: String { return String(self.o_4) }//octet 4
    
    //octet binary strings
    var sbo_1: String { return self.o_1.toBinaryString() }//octet 1
    var sbo_2: String { return self.o_2.toBinaryString() }//octet 2
    var sbo_3: String { return self.o_3.toBinaryString() }//octet 3
    var sbo_4: String { return self.o_4.toBinaryString() }//octet 4
    
    //octet 8 bit binary strings
    var sb8o_1: String { return self.o_1.to8bitPaddedBinaryString() }//octet 1
    var sb8o_2: String { return self.o_2.to8bitPaddedBinaryString() }//octet 2
    var sb8o_3: String { return self.o_3.to8bitPaddedBinaryString() }//octet 3
    var sb8o_4: String { return self.o_4.to8bitPaddedBinaryString() }//octet 4
    
    //return decimal dotted format x.x.x.x where x =0-255
    var toString: String{
        return so_1 + p + so_2 + p + so_3 + p + so_4
    }
    //return binary dotted format xxxxxxxx.xxxxxxxx.xxxxxxxx.xxxxxxxx where x=0|1
    func toBinaryStringWithDelimiter(Delimiter:Character) -> String {
        return self.toBinaryString.injectDelim(Character(p), every: 8)
    }
    //return binary dotted format xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx where x=0|1
    var toBinaryString: String {
        return sb8o_1 + sb8o_2 + sb8o_3 + sb8o_4
    }
}





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
