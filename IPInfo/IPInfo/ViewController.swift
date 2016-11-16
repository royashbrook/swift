//
//  ViewController.swift
//  IPInfo
//
//  Created by Roy Ashbrook on 6/11/15.
//  Copyright (c) 2015 Roy Ashbrook. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController {
    @IBOutlet var CIDRIPTextField : UITextField!
    @IBOutlet weak var resultsWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //enable iAds
        self.canDisplayBannerAds = true
        
        //todo: need to take this formatting stuff out
        CIDRIPTextField.text = "192.168.1.1/24" //default value
        resultsWebView.loadHTMLString("<h1>loaded</h1>", baseURL: nil)
        resultsWebView.scalesPageToFit = true;
        refreshUI()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func calculateTapped(sender : AnyObject) {
        var newval = CIDRIPTextField.text
        var sane = sanitycheck(newval)
        if sane {
            refreshUI()
        }else{
            updateResults("Input failed sanity test. Input must be in the format x.x.x.x/y where x is always 0-255 and y is 0-31")
        }
        CIDRIPTextField.endEditing(true)
    }
    @IBAction func viewTapped(sender : AnyObject) {
        CIDRIPTextField.resignFirstResponder()
    }
    
    func refreshUI() {
        
        var IPInfo: IPInfoModel = IPInfoModel(CIDRIpAddress: CIDRIPTextField.text)
        let space: Character = " "
        
        var sResults: String = ""
        sResults.extend("Input Data:" + "</br>")
        sResults.extend("------------------------------------------------" + "</br>")
        sResults.extend("<table style=\"font-family:courier;font-size:20pt;text-align:right;\" width=\"100%\">")
        sResults.extend("<tr><td style=\"width:70%;\">Given =</td><td>" + IPInfo.sInput + "</td></tr>")
        sResults.extend("<tr><td>IP Address =</td><td>" + IPInfo.sIpAddress + "</td></tr>")
        sResults.extend("<tr><td>Network Prefix =</td><td>" + IPInfo.sPrefixBits + "</td></tr>")
        sResults.extend("</table>")
        sResults.extend("</br>")
        sResults.extend("Network/Subnetting Info:" + "</br>")
        sResults.extend("------------------------------------------------" + "</br>")
        sResults.extend("<table style=\"font-family:courier;font-size:15pt;text-align:right;\" width=\"100%\">")
        sResults.extend("<tr><td>Network Class =</td><td></td><td>" + IPInfo.oNetwork.NetworkClass() + "</td></tr>")
        sResults.extend("<tr><td>Least Subnets/Most Hosts =</td><td>1 Subnet&nbsp;</td><td>" + IPInfo.oNetwork.MaxHosts().description + " Hosts</td></tr>")
        sResults.extend("<tr><td>Most Subnets/Least Hosts (RFC 3021) =</td><td>" + IPInfo.oNetwork.MaxSubnets().description + " Subnets</td><td>2 Hosts</td></tr>")
        sResults.extend("<tr><td>Most Subnets/Least Hosts (Standard) =</td><td>" + (IPInfo.oNetwork.MaxSubnets()/2).description + " Subnets</td><td>" + ((2<<2)-2).description + " Hosts </br></td></tr>")
        sResults.extend("</table>")
        sResults.extend("</br>")
        sResults.extend("Calculated IP Addresses:" + "</br>")
        sResults.extend("------------------------------------------------" + "</br>")
        sResults.extend("<table style=\"font-family:courier;font-size:20pt;text-align:right;\" width=\"100%\">")
        sResults.extend("<tr><td style=\"width:70%;\">Mask =</td><td>" + IPInfo.oNetwork.oMask().toString + "</td></tr>")
        sResults.extend("<tr><td>Network =</td><td>" + IPInfo.oNetwork.oAddress().toString + "</td></tr>")
        sResults.extend("<tr><td>Broadcast =</td><td>" + IPInfo.oNetwork.oBroadcast().toString + "</td></tr>")
        sResults.extend("<tr><td>FirstHost =</td><td>" + IPInfo.oNetwork.oFirstHost().toString + "</td></tr>")
        sResults.extend("<tr><td>LastHost =</td><td>" + IPInfo.oNetwork.oLastHost().toString + "</td></tr>")
        sResults.extend("</table>")
        sResults.extend("</br>")
        sResults.extend("Calculated Binary Addresses:" + "</br>")
        sResults.extend("------------------------------------------------" + "</br>")
        sResults.extend("Mask = " + IPInfo.oNetwork.oMask().toBinaryStringWithDelimiter(space).replace("1", withString: "<span style='color:#157DEC'>1</span>").replace("0", withString: "<span style='color:#ED8515'>0</span>") + "</br>")
        sResults.extend("Net vs Host = " + IPInfo.oNetwork.NetworkVsHost().injectDelim(space, every: 8) + "</br>")
        sResults.extend("IP = " + IPInfo.oAddress.toBinaryStringWithDelimiter(space) + "</br>")
        sResults.extend("Network = " + IPInfo.oNetwork.oAddress().toBinaryStringWithDelimiter(space) + "</br>")
        sResults.extend("Broadcast = " + IPInfo.oNetwork.oBroadcast().toBinaryStringWithDelimiter(space) + "</br>")
        sResults.extend("FirstHost = " + IPInfo.oNetwork.oFirstHost().toBinaryStringWithDelimiter(space) + "</br>")
        sResults.extend("LastHost = " + IPInfo.oNetwork.oLastHost().toBinaryStringWithDelimiter(space) + "</br>")
        sResults.extend("</br>")


        
        updateResults(sResults)
        
    }
    func updateResults(results: String){
        //resultsTextView.text = sResults
        let myHTMLString:String! = "<div style=\"font-family:courier;font-size:15pt;text-align:right;\">" + results + "</div>"
        resultsWebView.loadHTMLString(myHTMLString, baseURL: nil)
    }
    func sanitycheck(v:String) -> Bool{
        if count(v) < 19 {
            if v.rangeOfString(".") != nil && v.rangeOfString("/") != nil {
                var a = split(v) {$0 == "/"}
                if a.count == 2 {
                    var b = split(a[0]) {$0 == "."}
                    if b.count == 4 {
                        //var a0 = a[0].toInt()
                        var a1 = a[1].toInt()
                        var b0 = b[0].toInt()
                        var b1 = b[1].toInt()
                        var b2 = b[2].toInt()
                        var b3 = b[3].toInt()
                    if (b0 != nil && b1 != nil && b2 != nil && b3 != nil && a1 != nil){
                        if (
                            b0 >= 0 && b0 <= 255 &&
                            b1 >= 0 && b1 <= 255 &&
                            b2 >= 0 && b2 <= 255 &&
                            b3 >= 0 && b3 <= 255 &&
                            a1 >= 1 && a1 <= 31
                            ){
                            return true
                        }
                    }
                }
                }
            }
        }
        return false
    }
}

