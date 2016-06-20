//
//  ViewController.swift
//  SortGame
//
//  Created by 谭钧豪 on 16/6/11.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//


let screen = UIScreen.mainScreen().bounds

public func colorWithNumber(number:Int,advanced:Bool) -> UIColor{
    var num = 0
    if !advanced{
        num = number%10
    }else{
        switch number {
        case 1...10:
            num = number
        case 11..<109:
            num = number/10
        case 110..<1000:
            num = number/100
        default:
            num = 99
        }
    }
    switch num {
    case 0:
        return UIColor(red:1.00, green:0.16, blue:0.10, alpha:1.00)
    case 1:
        return UIColor(red:1.00, green:0.58, blue:0.14, alpha:1.00)
    case 2:
        return UIColor(red:1.00, green:0.98, blue:0.21, alpha:1.00)
    case 3:
        return UIColor(red:0.57, green:0.97, blue:0.18, alpha:1.00)
    case 4:
        return UIColor(red:0.00, green:0.97, blue:0.17, alpha:1.00)
    case 5:
        return UIColor(red:0.01, green:0.99, blue:1.00, alpha:1.00)
    case 6:
        return UIColor(red:0.05, green:0.60, blue:0.99, alpha:1.00)
    case 7:
        return UIColor(red:0.06, green:0.25, blue:0.98, alpha:1.00)
    case 8:
        return UIColor(red:0.58, green:0.26, blue:0.98, alpha:1.00)
    case 9:
        return UIColor(red:1.00, green:0.21, blue:0.57, alpha:1.00)
    default:
        return UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
    }
}

import UIKit

class WelcomeViewController: UIViewController {

    var backgroundView:UIImageView!
    var isTransfroming = false
    var imageView0: UIImageView!
    var imageView1: UIImageView!
    var imageView2: UIImageView!
    var imageView3: UIImageView!
    let size = screen.width/6

    @IBAction func play(sender:UIButton){
        if isTransfroming{
            return
        }
        isTransfroming = true
        self.presentViewController(PlayingViewController(gameMode: sender.tag,count: 5), animated: true) {
            self.isTransfroming = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView = UIImageView(image: UIImage(named: "iPhone 6"))
        backgroundView.contentMode = UIViewContentMode.ScaleToFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(backgroundView, atIndex: 0)
        NSLayoutConstraint(item: backgroundView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: backgroundView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: backgroundView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: backgroundView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1, constant: 0).active = true
        imageView0 = UIImageView(image: UIImage(named: "0"))
        imageView0.frame = CGRectMake(screen.width/2, -size, size, size)
        imageView1 = UIImageView(image: UIImage(named: "1"))
        imageView1.frame = CGRectMake(screen.width/2, -size, size, size)
        imageView2 = UIImageView(image: UIImage(named: "2"))
        imageView2.frame = CGRectMake(screen.width/2, -size, size, size)
        imageView3 = UIImageView(image: UIImage(named: "3"))
        imageView3.frame = CGRectMake(screen.width/2, -size, size, size)
        self.view.addSubview(imageView0)
        self.view.addSubview(imageView1)
        self.view.addSubview(imageView2)
        self.view.addSubview(imageView3)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func numberDrop(){
        UIView.animateWithDuration(0.2, animations: {
            self.imageView0.frame.origin = CGPointMake(screen.width/2-self.size/2, screen.height/2-self.size/2)
            }, completion: {
                _ in
                UIView.animateWithDuration(0.2, animations: {
                    self.imageView0.frame.origin = CGPointMake(screen.width/2-self.size*1.5, screen.height/2-self.size/2)
                    self.imageView1.frame.origin = CGPointMake(screen.width/2-self.size/2, screen.height/2-self.size/2)
                    }, completion: {
                        _ in
                        UIView.animateWithDuration(0.2, animations: {
                            self.imageView0.frame.origin = CGPointMake(screen.width/2-self.size*2, screen.height/2-self.size/2)
                            self.imageView1.frame.origin = CGPointMake(screen.width/2-self.size, screen.height/2-self.size/2)
                            self.imageView2.frame.origin = CGPointMake(screen.width/2+self.size/2, screen.height/2-self.size/2)
                            }, completion: {
                                _ in
                                UIView.animateWithDuration(0.2, animations: {
                                    self.imageView0.frame.origin = CGPointMake(screen.width/2-self.size*2, screen.height/2-self.size/2)
                                    self.imageView1.frame.origin = CGPointMake(screen.width/2-self.size, screen.height/2-self.size/2)
                                    self.imageView2.frame.origin = CGPointMake(screen.width/2, screen.height/2-self.size/2)
                                    self.imageView3.frame.origin = CGPointMake(screen.width/2+self.size, screen.height/2-self.size/2)
                                    }, completion: nil)
                        })
                })
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView0.frame.origin = CGPointMake(screen.width/2, -self.size)
        self.imageView1.frame.origin = CGPointMake(screen.width/2, -self.size)
        self.imageView2.frame.origin = CGPointMake(screen.width/2, -self.size)
        self.imageView3.frame.origin = CGPointMake(screen.width/2, -self.size)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        numberDrop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}



