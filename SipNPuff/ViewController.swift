//
//  ViewController.swift
//  SipNPuff
//
//  Created by Haitham Maaieh on 12/5/15.
//  Copyright © 2015 haithammaaieh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BLEDelegate {
    let screenSize = UIScreen.mainScreen().bounds
    let wheelchair = UIImageView()
    var chairAngle:CGFloat = 0
    let rotationConstant:CGFloat = 10
    let moveConstant: CGFloat = 10
    let center = UIView()
    let bleShield = BLE()
    var rssiTimer = NSTimer()
    let analogLabel = UILabel()
    var analogReading:Float = 0
    let puffMin = 620
    let puffMax = 700
    let sipMin = 300
    let sipMax = 380
    let rightMax = 600
    let rightMin = 520
    let leftMin = 400
    let leftMax = 480
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true

        //setup bluetooth
        bleShield.controlSetup()
        bleShield.delegate = self
        BLEShieldScan(view)
//        analogLabel.removeFromSuperview()
//        analogLabel.text = "Reading Input..."
//        analogLabel.sizeToFit()
//        analogLabel.center = CGPoint(x: screenSize.midX, y: screenSize.midY)
//        view.addSubview(analogLabel)
        
        wheelchair.removeFromSuperview()
        wheelchair.image = UIImage(named: "wheelchair")
        wheelchair.frame.size.height = 40
        wheelchair.frame.size.width = wheelchair.frame.size.height * wheelchair.image!.size.width / wheelchair.image!.size.height
        wheelchair.center = CGPoint(x: screenSize.midX, y: screenSize.midY)
        view.addSubview(wheelchair)
//
//        center.removeFromSuperview()
//        center.frame.size = CGSize(width: 10, height: 10)
//        center.backgroundColor = UIColor.blackColor()
//        center.center = CGPoint(x: screenSize.midX, y: screenSize.midY)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func controlChair(value: Int) {
        switch value {
        case leftMin...leftMax:
            rotateChair(-1)
        case rightMin...rightMax:
            rotateChair(1)
        case sipMin...sipMax:
            moveChair(-1)
        case puffMin...puffMax:
            moveChair(1)
        default:
            return
        }
    }
    
    func moveChair(direction: Int) {
        var x:CGFloat
        var y:CGFloat
        if direction > 0 {
            x = wheelchair.center.x + (moveConstant * cos(chairAngle/CGFloat(180 * M_PI)))
            y = wheelchair.center.y + (moveConstant * sin(chairAngle/CGFloat(180 * M_PI)))
        } else {
            x = wheelchair.center.x - (moveConstant * cos(chairAngle/CGFloat(180 * M_PI)))
            y = wheelchair.center.y - (moveConstant * sin(chairAngle/CGFloat(180 * M_PI)))
        }
        if x > screenSize.width || x < 0 || y > screenSize.height || y < 0 {
            return
        }
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.wheelchair.center = CGPoint(x: x, y: y)
        }
    }
    
    func rotateChair(direction: Int) {
        if(direction > 0) {
            chairAngle += rotationConstant
            rotateByDegree(wheelchair, degree: chairAngle)
        } else if (direction < 0) {
            chairAngle -= rotationConstant
            rotateByDegree(wheelchair, degree: chairAngle)
        }
    }
    
    func rotateByDegree(transformView: UIView, degree: CGFloat) {
        UIView.animateWithDuration(0.1) { () -> Void in
            transformView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/180)*degree)
        }
    }
    
    //Bluetooth Shield Functions
    func BLEShieldScan(sender: AnyObject) {
//        if (bleShield.activePeripheral) {
//            if bleShield.activePeripheral.state == .Connected {
//                bleShield.CM.cancelPeripheralConnection(bleShield.activePeripheral)
//                return
//            }
//        }
        bleShield.findBLEPeripherals(3)
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "connectionTimer:", userInfo: nil, repeats: false)
    }
    
    func bleDidReceiveData(data: UnsafeMutablePointer<UInt8>, length: Int32) {
//        let s = NSString(data: d, encoding: NSUTF8StringEncoding)
//        print(s!)
//        if(String(s!) == "L") {
//            rotateChair(1)
//        }
        let l = Int(length)
        for var i = 0; i < l; i += 3 {
            if data[i] == 0x0B {
                let firstValue:UInt16 = UInt16(data[i+1]) << UInt16(8)
                let secondValue = UInt16(data[i+2])
                print(firstValue)
                print(secondValue)
                let value = secondValue | firstValue
                print(value)
//                let value:UInt16 = UInt16(data[i + 2]) | UInt16(firstValue)
//                | data[i + 1] << 8
                analogReading = Float(value)*5/1023
                let s = String(value)
                analogLabel.text = s
            }
        }
        
    }
    
//    func bleDidDisconnect() {
//        NSLog("bleDidDisconnect")
//        self.navigationItem.leftBarButtonItem.title = "Connect"
//        activityIndicator.stopAnimating()
//        self.navigationItem.leftBarButtonItem.enabled = true
//        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
//    }
    
    func bleDidDisconnect() {
        print("bleDidDisconnect")
    }
    
    func bleDidConnect() {
        print("bleDidConnect")
    }
    
    func connectionTimer(timer: NSTimer) {
        if bleShield.peripherals == nil {
            BLEShieldScan(wheelchair)
            return
        }
        if bleShield.peripherals.count > 0 {
            bleShield.connectPeripheral(bleShield.peripherals[0] as! CBPeripheral)
        }
    }

}

