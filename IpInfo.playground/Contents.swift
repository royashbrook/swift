//references
// http://stackoverflow.com/questions/26181221/how-to-convert-a-decimal-number-to-binary-in-swift
// http://stackoverflow.com/questions/24044851/how-do-you-use-string-substringwithrange-or-how-do-ranges-work-in-swift
// https://gist.github.com/albertbori/0faf7de867d96eb83591


import Foundation

class IPv4 {
    class Address: IPv4 {
        var Decimal: String
        var Binary: String
        init(BinaryString: String){
            self.Decimal = "d"
            self.Binary = "b"
        }
        init(DecimalString: String){
            self.Decimal = "d"
            self.Binary = "b"
        }
    }

}

var ipa = IPv4.Address("blah")
println("blah")


/*
class Network {
    var Address:Address
    //var Hosts:[Host]
    init(Address:Address){
        
    }
}
class Host: IPv4 {
    var Address:Address
}
*/
/*
class Ipv4{
    class Address
        Decimal| Binary
    class Network
        Address
        Mask | Prefix
        Hosts...
        Subnets
            Network...recurse..
    class Host
        Address
        Network


where does prefix go?
where does mask go?

var DottedDecimalAddress: String
var 32bitBinaryAddress: String
var Network
}*/
class IPv4AddressInfo{
    var _ip: IPv4Address
    var _pf: Int
    var _network: IPv4Subnet{
        return IPv4Subnet(ip: self._ip, prefix: self._pf)
    }
    
    init(ip:IPv4Address, prefix:Int){
        self._ip = ip
        self._pf = prefix
    }

}

//IPv4 Network Object
class IPv4Subnet{
    var _ip: IPv4Address
    var _pf: Int
    
    init(ip: IPv4Address, prefix: Int){
        self._ip = ip
        self._pf = prefix
    }
    
    var HostsAllowed: Int { return getHosts(_pf) }
    //var SubnetsAllowed: Int { return getSubnets(_ip.NetworkClass, NetworkPrefix: _pf) }
    var bNetworkMask: String{ return getNetworkMask(_pf) }
    var sNetworkMask: String { return bNetworkMask.BinaryIPToDecimalIP()}
    var NetworkVsHost: String { return getNetworkVsHosts(bNetworkMask) }

    
    //calculate subnets allowed
    func getSubnets(NetworkClass: String, NetworkPrefix: Int) -> Int {
        var a: Int = 0
        switch (NetworkClass)
        {
        case "A": a = 8
        case "B": a = 16
        case "C": a = 24
        default: a = 0
        }
        return Int(pow(Double(2),Double(NetworkPrefix - a)))
    }

    
    //calculate hosts allowed
    func getHosts(NetworkPrefix: Int) -> Int {
        // if 31 bit Prefix, PtP links are allowed - see RFC 3021
        if NetworkPrefix == 31 {
            return 2
        }
        else {
            return Int(pow(Double(2),Double(32-NetworkPrefix))) - 2
        }
    }
    //calculate the string binary representation of the network mask
    func getNetworkMask(NetworkPrefix:Int) -> String {
        // get the number of network prefix bits
        var a: Int = NetworkPrefix
        
        // first part of number will be all 1s for the same number as prefix
        var b: String = "1".repeat(a)
        
        // second part of number will be all 0s for 32 minus the prefix
        var c: String = "0".repeat(32-a)
        
        // put both of them together
        var d: String = b + c
        
        // return that value
        return d
    }
    // calculate the network vs host representation
    func getNetworkVsHosts(BinaryNetworkMask: String) -> String {
        return BinaryNetworkMask.replace("1", withString: "n").replace("0", withString: "h")
    }
    // calculate the string binary representation of the network address.
    var dNetwork: String{ return bNetwork.BinaryIPToDecimalIP()}
    var bNetwork: String{
        
        // get the number of network prefix bits
        var a: Int = self._pf
        
        // get the string representation of the ip address
        var b: String = self._ip.toBinaryStringNoDelims
        
        // get the number of bits on the left side of the string that represent the network bits
        // this is defined by the network prefix. so if the prefix is 12, you get the first 12 bits in the ip address binary string
        var c: String = (b as NSString).substringWithRange(NSMakeRange(0,a))
        
        // fill the rest of the ip address binary, up to 32 characters, with 0s
        var d: String = c + "0".repeat(32-a)
        
        // return that value
        return d
    }
    
    // calculate the broadcast address
    // this is the same as the network address, just replace the final chars with 1s
    var dBroadcast: String{ return bBroadcast.BinaryIPToDecimalIP()}
    var bBroadcast: String{
        // get the number of network prefix bits
        var a: Int = self._pf
        
        // get the string representation of the ip address
        var b: String = self._ip.toBinaryStringNoDelims
        
        // get the number of bits on the left side of the string that represent the network bits
        // this is defined by the network prefix. so if the prefix is 12, you get the first 12 bits in the ip address binary string
        var c: String = (b as NSString).substringWithRange(NSMakeRange(0,a))
        
        // fill the rest of the ip address binary, up to 32 characters, with 0s
        var d: String = c + "1".repeat(32-a)
        
        // return that value
        return d
    }
    // calculate the first host for the network this IP belongs to
    var dFirstHost: String{ return bFirstHost.BinaryIPToDecimalIP()}
    var bFirstHost: String{
        // get the network address
        var a: String = self.bNetwork
        // replace 32nd bit with a 1
        var b: String = (a as NSString).substringWithRange(NSMakeRange(0,31)) + "1"
        // return that value
        return b
    }
    // calculate the last host for the network this IP belongs to
    var dLastHost: String { return bLastHost.BinaryIPToDecimalIP() }
    var bLastHost: String {
        // get the broadcast address
        var a: String = self.bBroadcast
        // replace last bit with 0
        var b: String = (a as NSString).substringWithRange(NSMakeRange(0,31)) + "0"
        // return that number
        return b
    }
    //func getLastHost(BroadcastAddress

    
}
//IPv4 Address Object
class IPv4Address{
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
    var toString: String{ return so_1 + p + so_2 + p + so_3 + p + so_4 }
    //return binary dotted format xxxxxxxx.xxxxxxxx.xxxxxxxx.xxxxxxxx where x=0|1
    var toBinaryString: String { return self.toBinaryStringNoDelims.injectDelim(Character(p), every: 8) }
    //return binary dotted format xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx where x=0|1
    var toBinaryStringNoDelims: String { return sb8o_1 + sb8o_2 + sb8o_3 + sb8o_4 }
    }
class Info: IPv4Address {
    //return network class
    var NetworkClass: String {
        var fo = Array(self.sb8o_1)
        if fo[0] == "0" { //starts with 0, class is A
            return "A"
        }else{ //first bit is a 1
            if fo[1] == "0" { //starts with 10, class is B
                return "B"
            }else{
                if fo[2] == "0" { //starts with 110, class is C
                    return "C"
                }else{
                    if fo[3] == "0" { //starts with 1110, class is D
                        return "D"
                    }else{ //starts with 1111, class is E
                        return "E"
                    }
                }
            }
        }
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

@objc protocol Serializable {
    var jsonProperties:Array<String> { get }
    func valueForKey(key: String!) -> AnyObject!
}
struct Serialize {
    static func toDictionary(obj:Serializable) -> NSDictionary {
        // make dictionary
        var dict = Dictionary<String, AnyObject>()
        
        // add values
        for prop in obj.jsonProperties {
            var val:AnyObject! = obj.valueForKey(prop)
            
            if (val is String)
            {
                dict[prop] = val as! String
            }
            else if (val is Int)
            {
                dict[prop] = val as! Int
            }
            else if (val is Double)
            {
                dict[prop] = val as! Double
            }
            else if (val is Array<String>)
            {
                dict[prop] = val as! Array<String>
            }
            else if (val is Serializable)
            {
                dict[prop] = toJSON(val as! Serializable)
            }
            else if (val is Array<Serializable>)
            {
                var arr = Array<NSDictionary>()
                
                for item in (val as! Array<Serializable>) {
                    arr.append(toDictionary(item))
                }
                
                dict[prop] = arr
            }
            
        }
        
        // return dict
        return dict
    }
    
    static func toJSON(obj:Serializable) -> String {
        // get dict
        var dict = toDictionary(obj)
        
        // make JSON
        var error:NSError?
        var data = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions(0), error: &error)
        
        // return result
        return NSString(data: data!, encoding: NSUTF8StringEncoding)
    }
}

"1111111111".toDecimalFromBinary()
"11111111000000001111111100000000".BinaryIPToDecimalIP()
"11111111000000001111111100000000".injectDelim(".", every: 8)
strtoul("1100011",nil,2).description
"blah blah".repeat(5)
"10101010".toDecimalFromBinary()
"3".to8BitBinaryFromDecimal()
var i:IPv4Address = IPv4Address(Octet1: 192,Octet2: 168,Octet3: 1,Octet4: 73)
var nfo:IPv4AddressInfo = IPv4AddressInfo(ip: i, prefix: 31)
/*
nfo.NetworkVsHost.injectDelim(".", every: 8)
nfo.Hosts
nfo.Subnets
*/
i.NetworkClass
i.toBinaryString
i.toBinaryStringNoDelims
i.toString
var iii = i.toString
var ii = i.o_1.toBinaryString().padLeft("x", toSize: 20)
ii = i.o_1.toBinaryString().padRight("x", toSize: 20)

