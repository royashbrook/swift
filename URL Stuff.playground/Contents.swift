//: Playground - noun: a place where people can play

import UIKit

//Uncomment both lines below if testing on an Xcode playground.
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely()

let urlPath: String = "http://google.com"
var url: NSURL = NSURL(string: urlPath)!
var request1: NSURLRequest = NSURLRequest(URL: url)
var response: AutoreleasingUnsafeMutablePointer<NSURLResponse? >= nil
var error: NSErrorPointer = nil
var dataVal: NSData =  NSURLConnection.sendSynchronousRequest(request1, returningResponse: response, error:nil)!
var err: NSError
println(response)
var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
println("Synchronous \(jsonResult)")
