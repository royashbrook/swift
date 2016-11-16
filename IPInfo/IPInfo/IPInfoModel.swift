//
//  IPInfoModel.swift
//  IPInfo
//
//  Created by Roy Ashbrook on 6/11/15.
//  Copyright (c) 2015 Roy Ashbrook. All rights reserved.
//

import Foundation


class IPInfoModel
{
    //inputs - note: sanity check needs to be performed outside of this class
    // all other values are derived from this value.
    // this allows us to reset the value and get new values whenever we want
    var sInput: String
    
    //calculations
    
    // return string array of the sInput value split up by the "/" character
    var slashsplit: [String]{
        return split(self.sInput) {$0 == "/"}
    }
    
    // return the first part of the slashsplit, this should be the 4 octet IP address
    var sIpAddress: String {
        return slashsplit[0]
    }
    
    //return the second part of the slashsplit, this should be the network prefix
    var sPrefixBits: String {
        return slashsplit[1]
    }
    
    // returns the network prefix value as an int
    var iPrefixBits: Int{
        return self.sPrefixBits.toInt()!
    }
    
    var oAddress: Address{
        return Address(DottedDecimal: sIpAddress)
    }
    
    var oNetwork: Network{
        return Network(HostOrNetworkAddress: self.oAddress, Prefix: self.iPrefixBits)
    }
    
    // initially a CIDR format address is given to create this object.
    // note that no bounds checking is really done in this object
    init(CIDRIpAddress: String) {
        self.sInput = CIDRIpAddress
    }
}
class Network{
    
    private var iAddress: Address
    private var iPrefix: Int
    
    init(HostOrNetworkAddress:Address, Prefix: Int){
        self.iPrefix = Prefix
        self.iAddress = HostOrNetworkAddress
    }
    
    init(NetworkAddress:Address, Mask: Address){
        self.iAddress = NetworkAddress
        self.iPrefix = Mask.toBinaryString.componentsSeparatedByString("1").count - 1
    }
    
    func oAddress() -> Address{
        
        // get the number of network prefix bits
        var a: Int = self.iPrefix
        
        // get the string representation of the ip address
        var b: String = self.iAddress.toBinaryString
        
        // get the number of bits on the left side of the string that represent the network bits
        // this is defined by the network prefix. so if the prefix is 12, you get the first 12 bits in the ip address binary string
        var c: String = (b as NSString).substringWithRange(NSMakeRange(0,a))
        
        // fill the rest of the ip address binary, up to 32 characters, with 0s
        var d: String = c + "0".repeat(32-a)
        
        // return this value
        return Address(BinaryString: d)
        
    }
    
    func oMask() -> Address {
        
        // get the number of network prefix bits
        var a: Int = self.iPrefix
        
        // 1's for however long the prefix is
        var b: String = "1".repeat(a)
        
        // pad out to 32 characters with 0s
        var c: String = b.padRight("0", toSize: 32)
        
        // return address with this value
        return Address(BinaryString: c)
    }

    
    func oBroadcast() -> Address {
        
        // calculate the broadcast address
        // this is the same as the network address, just replace the final chars with 1s
        
        // get the number of network prefix bits
        var a: Int = self.iPrefix
        
        // get the string representation of the ip address
        var b: String = self.oAddress().toBinaryString
        
        // get the number of bits on the left side of the string that represent the network bits
        // this is defined by the network prefix. so if the prefix is 12, you get the first 12 bits in the ip address binary string
        var c: String = (b as NSString).substringWithRange(NSMakeRange(0,a))
        
        // fill the rest of the ip address binary, up to 32 characters, with 0s
        var d: String = c + "1".repeat(32-a)
        
        // return that value
        return Address(BinaryString: d)

    }

    
    func oFirstHost() -> Address{
        // get the network address
        var a: String = self.oAddress().toBinaryString
        // replace 32nd bit with a 1
        var b: String = (a as NSString).substringWithRange(NSMakeRange(0,31)) + "1"
        // return that value
        return Address(BinaryString: b)
    }

    func oLastHost() -> Address {
        // get the broadcast address
        var a: String = self.oBroadcast().toBinaryString
        // replace last bit with 0
        var b: String = (a as NSString).substringWithRange(NSMakeRange(0,31)) + "0"
        // return that number
        return Address(BinaryString: b)
    }
    
    
    /*
    //calculate subnets allowed
    func MaxSubnets() -> Int{
        var a: Int = 0
        switch (self.NetworkClass())
        {
        case "A": a = 8
        case "B": a = 16
        case "C": a = 24
        default: a = 0
        }
        return Int(pow(Double(2),Double(self.iPrefix - a)))
    }
    */
    //calculate hosts allowed
    func MaxSubnets() -> Int {
        var bitsborrowed = 32 /* total size */ - self.iPrefix /* network id length */ - 1 /* need one bit for hosts */
        var bitshift = bitsborrowed - 1 // this is to account for 2^0 = 2, not 2^1
        return 2 << bitshift
    }
    
    //calculate hosts allowed
    func MaxHosts() -> Int {
        // if 31 bit Prefix, PtP links are allowed - see RFC 3021
        if self.iPrefix == 31 {
            return 2
        }
        else {
            return Int(pow(Double(2),Double(32-self.iPrefix))) - 2
        }
    }

    //return network class
    func NetworkClass() -> String {
        var fo = Array(self.oAddress().sb8o_1)
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
    
    func NetworkVsHost() -> String {
        var a: String = "n".repeat(self.iPrefix)
        return a.padRight("h", toSize: 32)
    }
}
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
        var d:String = String(Delimiter)
        return sb8o_1 + d + sb8o_2 + d + sb8o_3 + d + sb8o_4
    }
    //return binary dotted format xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx where x=0|1
    var toBinaryString: String {
        return sb8o_1 + sb8o_2 + sb8o_3 + sb8o_4
    }
}


