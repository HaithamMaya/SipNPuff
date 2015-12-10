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
    let moveConstant: CGFloat = 30
    let bleShield = BLE()
    var rssiTimer = NSTimer()
    let analogLabel = UILabel()
    var analogReading:Float = 0
    let puffMin = 550
    let puffMax = 1023
    let sipMin = 0
    let sipMax = 300
    let rightMax = 530
    let rightMin = 500
    let leftMin = 400
    let leftMax = 470
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        
        var targetViews = Array<UIView>()
        for _ in 0...8 {
            targetViews.append(UIView())
        }
        for target in targetViews {
            target.frame.size.width = screenSize.width/3
            target.frame.size.height = screenSize.height/3
            target.backgroundColor = getRandomColor()
            target.alpha = 0.5
        }
        for i in 1...9 {
            if i%3 == 1%3 {
                targetViews[i-1].frame.origin.x = 0
            } else if i%3 == 2%3 {
                targetViews[i-1].frame.origin.x = screenSize.width/3
            } else {
                targetViews[i-1].frame.origin.x = screenSize.width*2/3
            }
            if(i<=3) {
                targetViews[i-1].frame.origin.y = 0
            } else if i<=6 && i>3 {
                targetViews[i-1].frame.origin.y = screenSize.height/3
            } else {
                targetViews[i-1].frame.origin.y = screenSize.height*2/3
            }
            view.addSubview(targetViews[i-1])
        }
        
        
        //setup bluetooth
        bleShield.controlSetup()
        bleShield.delegate = self
        BLEShieldScan(view)
        analogLabel.removeFromSuperview()
        analogLabel.text = "Reading Input..."
        analogLabel.sizeToFit()
        analogLabel.frame.origin = CGPointZero
        analogLabel.frame.origin.y += 15
        view.addSubview(analogLabel)
        
        wheelchair.removeFromSuperview()
        wheelchair.image = UIImage(named: "wheelchair")
        wheelchair.frame.size.height = 40
        wheelchair.frame.size.width = wheelchair.frame.size.height * wheelchair.image!.size.width / wheelchair.image!.size.height
        wheelchair.center = CGPoint(x: screenSize.midX, y: screenSize.midY)
        view.addSubview(wheelchair)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
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
            x = wheelchair.center.x + (moveConstant * cos(angleToRadian(chairAngle)))
            y = wheelchair.center.y + (moveConstant * sin(angleToRadian(chairAngle)))
        } else {
            x = wheelchair.center.x - (moveConstant * cos(angleToRadian(chairAngle)))
            y = wheelchair.center.y - (moveConstant * sin(angleToRadian(chairAngle)))
        }

        if x > screenSize.width || x < 0 || y > screenSize.height || y < 0 {
            return
        }
        UIView.animateWithDuration(0.5) { () -> Void in
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
        UIView.animateWithDuration(0.5) { () -> Void in
            transformView.transform = CGAffineTransformMakeRotation(self.angleToRadian(degree))
        }
    }
    
    func angleToRadian(angle: CGFloat)->CGFloat {
        return angle*CGFloat(M_PI/180)
    }
    
    //Bluetooth Shield Functions
    func BLEShieldScan(sender: AnyObject) {
        bleShield.findBLEPeripherals(3)
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "connectionTimer:", userInfo: nil, repeats: false)
    }
    
    func bleDidReceiveData(data: UnsafeMutablePointer<UInt8>, length: Int32) {

        let l = Int(length)
        for var i = 0; i < l; i += 3 {
            if data[i] == 0x0B {
                let firstValue:UInt16 = UInt16(data[i+1]) << UInt16(8)
                let secondValue = UInt16(data[i+2])
                print(firstValue)
                print(secondValue)
                let value = secondValue | firstValue
                print(value)
                controlChair(Int(value))
                analogReading = Float(value)*5/1023
                let s = String(value)
                analogLabel.text = s
            }
        }
        
    }
    
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

