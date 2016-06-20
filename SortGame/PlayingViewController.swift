//
//  PlayingViewController.swift
//  SortGame
//
//  Created by 谭钧豪 on 16/6/15.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

import Foundation
import UIKit

class NumberButton: UIButton {
    var rawFrame:CGRect!
    var isRawPoint = true
    var index = 0
    var controller:PlayingViewController!
    init(number:Int,frame:CGRect,color:UIColor,index:Int,controller:PlayingViewController){
        super.init(frame: frame)
        self.rawFrame = frame
        self.index = index
        self.controller = controller
        self.setTitle("\(number)", forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont.systemFontOfSize(32)
        self.titleLabel?.textAlignment = .Center
        self.setTitleColor(color, forState: UIControlState.Normal)
        self.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.8), forState: UIControlState.Highlighted)
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        self.addTarget(self, action: #selector(self.tap), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    /**
     有序数组区域
     */
    func pointWithCount(index:Int) -> CGPoint{
        let x = 15 + CGFloat(index%7)*(screen.width-30)/7
        let size:CGFloat = (screen.width-70)/7.5
        let y = CGFloat(index/7)*(size+5)
        return CGPointMake(x, y)
    }
    
    func tap(){
        if self.controller.startTime == nil{
            self.controller.startTime = NSDate()
            self.controller.gameTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self.controller, selector: #selector(self.controller.timeStep), userInfo: nil, repeats: true)
        }
        if !isRawPoint{
            self.controller.back(self)
        }else{
            let count = self.controller.sortedArray.count
            move(count)
            self.controller.check(self)
        }
    }
    
    func move(index:Int){
        self.titleLabel?.font = UIFont.systemFontOfSize(20)
        self.isRawPoint = false
        self.controller.buttons[self] = index
        self.controller.sortedArray.insert(Int(self.currentTitle!)!, atIndex: index)
        UIView.animateWithDuration(0.1) {
            self.frame.origin = self.pointWithCount(index)
            self.frame.size = CGSizeMake(self.rawFrame.width/1.5, self.rawFrame.height/1.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSMutableArray{
    func containRecord(buttonCount:Int,time:String) -> Bool{
        for object in self{
            if (buttonCount == object[0] as! Int) && (time == object[1] as! String){
                return true
            }
        }
        return false
    }
}

class PlayingViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var array:[Int]!
    var buttons:[NumberButton:Int]!
    var sortedArray:[Int]!
    var startTime:NSDate!
    var timeLabel:UILabel!
    var playingAreaView:UIView!
    var gameTimer:NSTimer!
    var gameMode:Int!
    var scoreTableView:UITableView!
    var historyScores:NSMutableArray!
    var nextLevelButton:UIButton!
    var records:NSMutableArray!
    
    var count:UInt32!{
        didSet{
            if count>25{
                count = 25
            }else if count<5{
                count = 5
            }
        }
    }
    var advanced = false
    
    init(gameMode:Int,count:UInt32){
        if let historyScores = NSUserDefaults.standardUserDefaults().objectForKey("historyScores"){
            self.historyScores = NSMutableArray(array: historyScores as! NSArray)
            records = NSMutableArray(array: self.historyScores[gameMode] as! NSArray)
        }else{
            self.historyScores = NSMutableArray()
            self.historyScores.addObject(NSArray())
            self.historyScores.addObject(NSMutableArray())
            self.historyScores.addObject(NSMutableArray())
            self.historyScores.addObject(NSMutableArray())
            records = self.historyScores[gameMode] as! NSMutableArray
        }
        self.gameMode = gameMode
        self.count = count
        scoreTableView = UITableView(frame: CGRectZero, style: .Plain)
        super.init(nibName: nil, bundle: nil)
    }
    
    func jumpTo(sender:UIButton){
        if sender.tag == 88{
            dismiss()
        }else if sender.tag == 66{
            //jump to history
            displayTableView(nil)
        }
    }
    
    func displayTableView(toShow:Bool?){
        if let toShow = toShow{
            view.bringSubviewToFront(scoreTableView)
            UIView.animateWithDuration(0.2, animations: {
                self.scoreTableView.frame = toShow ? CGRectMake(10, 128, screen.width-20, screen.height-208) : CGRectMake(screen.width-10, 128, 0, 0)
                }, completion: nil)
        }else{
            if scoreTableView.frame.size == CGSizeZero{
                view.bringSubviewToFront(scoreTableView)
                UIView.animateWithDuration(0.2, animations: {
                    self.scoreTableView.frame = CGRectMake(10, 128, screen.width-20, screen.height-208)
                    }, completion: nil)
            }else{
                UIView.animateWithDuration(0.2, animations: {
                    self.scoreTableView.frame = CGRectMake(screen.width-10, 128, 0, 0)
                    })
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        displayTableView(false)
    }
    
    func dismiss(){
        if array != nil{
            array = nil
        }
        if buttons != nil{
            for (button,_) in buttons{
                button.removeFromSuperview()
            }
            buttons = nil
        }
        if sortedArray != nil{
            sortedArray = nil
        }
        if timeLabel != nil{
            timeLabel = nil
        }
        if playingAreaView != nil{
            playingAreaView = nil
        }
        if gameTimer != nil{
            gameTimer.invalidate()
            gameTimer = nil
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundView = UIImageView(image: UIImage(named: "playingBG"))
        backgroundView.contentMode = UIViewContentMode.ScaleToFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundView, atIndex: 0)
        NSLayoutConstraint(item: backgroundView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: backgroundView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: backgroundView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: backgroundView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0).active = true
        
        let backButton = UIButton(type: .System)
        backButton.setTitle("返回主界面", forState: .Normal)
        backButton.addTarget(self, action: #selector(self.jumpTo(_:)), forControlEvents: .TouchUpInside)
        backButton.tag = 88
        backButton.frame = CGRectMake(8, 8, 100, 60)
        view.addSubview(backButton)
        let historyButton = UIButton(type: .System)
        historyButton.setTitle("查看排行榜", forState: .Normal)
        historyButton.addTarget(self, action: #selector(self.jumpTo(_:)), forControlEvents: .TouchUpInside)
        historyButton.tag = 66
        historyButton.frame = CGRectMake(screen.width-108, 8, 100, 60)
        view.addSubview(historyButton)
        scoreTableView.frame = CGRectMake(screen.width-10, 128, 0, 0)
        scoreTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        scoreTableView.delegate = self
        scoreTableView.dataSource = self
        scoreTableView.clipsToBounds = true
        scoreTableView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        scoreTableView.layer.cornerRadius = 8
        view.addSubview(scoreTableView)
        
        timeLabel = UILabel()
        timeLabel.frame = CGRectMake(screen.width/4, 0, screen.width/2, screen.height/4)
        timeLabel.font = UIFont.systemFontOfSize(60)
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.textColor = UIColor.blackColor()
        timeLabel.text = "0.00 s"
        timeLabel.userInteractionEnabled = true
        timeLabel.textAlignment = .Center
        view.addSubview(timeLabel)
        
        nextLevelButton = UIButton(frame: CGRectMake(screen.width/2-45,screen.height-68,90,60))
        nextLevelButton.setTitle("增加难度", forState: UIControlState.Normal)
        nextLevelButton.layer.cornerRadius = 8
        nextLevelButton.clipsToBounds = true
        nextLevelButton.setBackgroundImage(UIImage(named: "purple"), forState: .Normal)
        nextLevelButton.addTarget(self, action: #selector(self.nextLevel), forControlEvents: .TouchUpInside)
        nextLevelButton.hidden = true
        view.addSubview(nextLevelButton)
        
        
        playingAreaView = UIView(frame:CGRectMake(0,0,screen.width,screen.height-timeLabel.frame.height-20))
        view.insertSubview(playingAreaView, aboveSubview: timeLabel)
        playingAreaView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: playingAreaView, attribute: .Top, relatedBy: .Equal, toItem: timeLabel, attribute: .Bottom, multiplier: 1, constant: -(screen.width-70)/7.5).active = true
        NSLayoutConstraint(item: playingAreaView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: playingAreaView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: playingAreaView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0).active = true
        if gameMode == 2{
            advanced = true
        }
        createRandomArray(count,advanced: advanced)
        createButton()
        
//        switch gameMode {
//        case 1:
//            print("递增模式")
//            
//        case 2:
//            print("进阶模式")
//            
//        default:
//            print("自定义模式")
//        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if gameMode == 3{
            let alert = UIAlertController(title: "提示", message: "请输入数字个数(最多25个)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler({ buttonCount in
                buttonCount.delegate = self
                buttonCount.placeholder = "请输入数字个数(不填默认为5)"
                buttonCount.keyboardType = .NumberPad
            })
            alert.addAction(UIAlertAction(title: "普通模式", style: .Default, handler: { action in
                self.count = UInt32((alert.textFields![0].text! as NSString).integerValue ?? 5)
                self.reset(self.count)
            }))
            alert.addAction(UIAlertAction(title: "进阶模式", style: .Default, handler: { action in
                self.count = UInt32((alert.textFields![0].text! as NSString).integerValue ?? 5)
                self.advanced = true
                self.reset(self.count)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    //MARK: 检测输入的按钮个数的字符位数，限制为2位
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.characters.count > 1 && string != ""{
            return false
        }
        
        return true
    }
    //MARK: 排行榜的TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count ?? 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("Cell"){
            let button = (records[indexPath.row] as! NSArray)[0] as! Int
            let time = (records[indexPath.row] as! NSArray)[1] as! String
            cell.selectionStyle = .None
            cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
            cell.textLabel?.text = "个数：\(button)        时间：\(time)       第\(indexPath.row+1)名"
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func nextLevel(){
        nextLevelButton.hidden = true
        displayTableView(false)
        reset(count+1)
    }
    
    func reset(count:UInt32){
        
        self.count = count
        nextLevelButton.hidden = true
        startTime = nil
        if gameTimer != nil{
            gameTimer.fireDate = NSDate.distantFuture()
        }
        gameTimer = nil
        
        timeLabel.text = "0.00 s"
        timeLabel.textAlignment = .Center
        for button in playingAreaView.subviews {
            button.removeFromSuperview()
        }
        createRandomArray(self.count,advanced: advanced)
        createButton()
    }
    
    func resort(){
        startTime = nil
        if gameTimer != nil{
            gameTimer.fireDate = NSDate.distantFuture()
        }
        gameTimer = nil
        for (button,_) in buttons{
            back(button)
        }
        timeLabel.text = "0.00 s"
        timeLabel.textAlignment = .Center
    }
    
    func timeStep(){
        var text = "\(NSDate().timeIntervalSinceDate(startTime))"
        text = text.substringToIndex(text.characters.indexOf(".")!.advancedBy(3)) + " s"
        timeLabel.text = text
    }
    
    func createRandomArray(count:UInt32,advanced:Bool){
        array = [Int]()
        sortedArray = [Int]()
        for _ in 0..<count{
            var randomNumber = Int(arc4random()%(advanced ? count*10 : count))+1
            while array.contains(randomNumber) {
                randomNumber = Int(arc4random()%(advanced ? count*10 : count))+1
            }
            array.append(randomNumber)
        }
    }
    
    func back(sender:NumberButton){
        sender.isRawPoint = true
        let curSortedIndex = buttons[sender]
        for (button,var key) in buttons {
            if key == -1 || key <= curSortedIndex{
                continue
            }
            sortedArray.removeAtIndex(sortedArray.indexOf(Int(button.currentTitle!)!)!)
            key -= 1
            button.move(key)
        }
        sortedArray.removeAtIndex(sortedArray.indexOf(Int(sender.currentTitle!)!)!)
        UIView.animateWithDuration(0.1) {
            sender.titleLabel?.font = UIFont.systemFontOfSize(32)
            self.buttons[sender] = -1
            sender.frame = sender.rawFrame
        }
    }
    
    func compare(object1:AnyObject,object2:AnyObject) -> NSComparisonResult{
        let buttonCount1 = (object1 as! NSArray)[0] as! Int
        let buttonCount2 = (object2 as! NSArray)[0] as! Int
        
        let time1:Double = (((object1 as! NSArray)[1] as! String).stringByReplacingOccurrencesOfString(" s", withString: "") as NSString).doubleValue
        let time2:Double = (((object1 as! NSArray)[1] as! String).stringByReplacingOccurrencesOfString(" s", withString: "") as NSString).doubleValue
        if buttonCount1 == buttonCount2 && time1 == time2{
            return NSComparisonResult.OrderedSame
        }else if buttonCount1 > buttonCount2{
            return NSComparisonResult.OrderedAscending
        }else if time2 > time1{
            return NSComparisonResult.OrderedAscending
        }else{
            return NSComparisonResult.OrderedDescending
        }
    }
    
    var tempDate:NSDate!
    var canMind = true
    func check(sender:NumberButton){
        var gameStatu = true
        let confirmArray = array.sort()
        for i in 0..<sortedArray.count{
            if sortedArray[i] != confirmArray[i]{
                gameStatu = false
            }
        }
        if sortedArray.count == array.count{
            let alert = UIAlertController(title: (gameStatu ? "胜利" : "提示"), message: (gameStatu ? "排列正确" : "排列错误请检查"), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "查看排行榜", style: UIAlertActionStyle.Cancel, handler: {
                _ in
                //save
                if self.records.containRecord(self.buttons.count, time: self.timeLabel.text!){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.displayTableView(true)
                    })
                    return
                }
                self.records.addObject([self.buttons.count,self.timeLabel.text!])
                self.records.sortUsingComparator(self.compare)
                self.historyScores[self.gameMode] = self.records
                NSUserDefaults.standardUserDefaults().setObject(self.historyScores, forKey: "historyScores")
                dispatch_async(dispatch_get_main_queue(), {
                    self.scoreTableView.reloadData()
                    self.displayTableView(true)
                })
            }))
            if gameStatu{
                nextLevelButton.hidden = false
                
                gameTimer.fireDate = NSDate.distantFuture()
                alert.addAction(UIAlertAction(title: "加大难度", style: UIAlertActionStyle.Default, handler: {
                    _ in
                    self.reset(self.count+1)
                }))
            }else{
                alert.addAction(UIAlertAction(title: "重置所有", style: UIAlertActionStyle.Default, handler: {
                    _ in
                    self.resort()
                }))
                alert.addAction(UIAlertAction(title: "好", style: UIAlertActionStyle.Default, handler: nil))
            }
            presentViewController(alert, animated: true, completion: nil)
        }else{
            if !gameStatu && canMind{
                let alert = UIAlertController(title: "提示", message: "出错了", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "不再提醒", style: UIAlertActionStyle.Default, handler: {
                    _ in
                    self.canMind = false
                }))
                alert.addAction(UIAlertAction(title: "撤销", style: UIAlertActionStyle.Default, handler: {
                    _ in
                    self.back(sender)
                }))
                presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    
    /**
     混乱序列区域
     */
    func frameWithIndex(index:Int) -> CGRect{
        let x = 15 + CGFloat(index%5)*(screen.width-30)/5
        let size:CGFloat = (screen.width-70)/5
        let mul = Int(count-1)/5
        let addtionHeight:CGFloat = (size * CGFloat(mul+2)) - 5
        let y = playingAreaView.frame.height - addtionHeight + CGFloat(index/5)*(size+10)
        return CGRectMake(x, y, size, size)
    }
    
    func createButton(){
        buttons = [NumberButton:Int]()
        for index in 0..<array.count{
            let number = array[index]
            let button = NumberButton(number: number, frame: frameWithIndex(index), color: colorWithNumber(number,advanced: advanced),index: index,controller:self)
            buttons[button] = -1
            playingAreaView.addSubview(button)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
