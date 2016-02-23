//
//  ViewController.swift
//  TableLamp
//
//  Created by Liuming Qiu on 16/2/22.
//  Copyright © 2016年 PPF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI outlet
    @IBOutlet weak var toggleB: UIButton!
    @IBOutlet weak var timeHourL: UILabel!
    @IBOutlet weak var timeMinuteL: UILabel!
    @IBOutlet weak var timeSecondL: UILabel!
    
    @IBOutlet weak var torchLevelL: UILabel!
    @IBOutlet weak var torchLevelS: UISlider!

    @IBOutlet weak var timeOfTurnOffL: UILabel!
    
    //状态栏颜色
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - 功能
    
    /// 台灯关闭的时间
    var lampTurnOff:NSDate?
    
    /// 计时器
    var timer:NSTimer!
    
    /// 台灯
    var tableLamp:TableLamp!
    
    /// 当前台灯的亮度
    var currentLampLevel:Float = 0.0{
        didSet{
            torchLevelS.setValue(currentLampLevel, animated: true)
            tableLamp.torchLevel = currentLampLevel
        }
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableLamp = TableLamp()
        
        timer = NSTimer(timeInterval: 1, target: self, selector: Selector("updateTime:"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //关闭自动锁屏
        UIApplication.sharedApplication().idleTimerDisabled = true
        updateTimeUI()
    }
    override func viewWillDisappear(animated: Bool) {
        //开启自动锁屏
        UIApplication.sharedApplication().idleTimerDisabled = false
        super.viewWillDisappear(animated)
    }
    
    // 设备支持的方向，这个要和General 里的 device orientation 里的四个选项配合使用
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }

    // MARK: - action
    @IBAction func lampToggle(sender: UIButton) {
        if tableLamp.lampToggle{
            tableLamp.lampToggle = false
            torchLevelS.setValue(0, animated: true)
            lampTurnOff = nil
        }else{
            tableLamp.torchLevel = 0.1
        }
    }
    
    // 调节台灯的亮度
    @IBAction func lampSliderAction(sender: UISlider) {
        torchLevelL.text = String(format: "台灯亮度:%.2f", sender.value)
        
        if sender.value == 0 {
            tableLamp.lampToggle = false
            lampTurnOff = nil
        }else if sender.value == 1.0{
        }else{
            tableLamp.torchLevel = sender.value
        }
    }

    @IBAction func setupTurnOffTime(sender: AnyObject) {
        self.performSegueWithIdentifier("showTimerPicker", sender: nil)
    }
    
    @IBAction func datePickerVC(sender:UIStoryboardSegue){
        guard let stvc = sender.sourceViewController as? SetupTimerViewController else{
            return
        }
        let currentDate = stvc.datePicker.date
        
        let calender = NSCalendar.currentCalendar()
        let component = calender.components(NSCalendarUnit.Second, fromDate: NSDate(), toDate: currentDate, options: NSCalendarOptions.MatchStrictly)
        
        if component.second > 10{
            lampTurnOff = currentDate
            currentLampLevel = 0.1
        }
    }
    
    // MARK: - update UI
    func updateTime(timer:NSTimer){
        updateTimeUI()
    }
    
    /**
     更新时间UI
     */
    private func updateTimeUI(){
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([NSCalendarUnit.Hour,NSCalendarUnit.Minute,NSCalendarUnit.Second], fromDate: NSDate())
        timeHourL.text   = components.hour < 10 ? "0\(components.hour)" : "\(components.hour)"
        timeMinuteL.text =  components.minute < 10 ? "0\(components.minute)" : "\(components.minute)"
        timeSecondL.text = components.second < 10 ? "0\(components.second)" : "\(components.second)"
        
        if let d = lampTurnOff{
            let calender = NSCalendar.currentCalendar()
            let componentsTO = calender.components([NSCalendarUnit.Minute,NSCalendarUnit.Second], fromDate: NSDate(), toDate: d, options: NSCalendarOptions.MatchStrictly)
            
            timeOfTurnOffL.text = "离关灯还有 \(componentsTO.minute)分 \(componentsTO.second)秒"
            
            if componentsTO.minute == 0 && componentsTO.second == 0 {
                tableLamp.lampToggle = false
                torchLevelS.setValue(0, animated: true)
                lampTurnOff = nil
            }
            
        }else if timeOfTurnOffL.text != "关灯定时"{
            timeOfTurnOffL.text = "关灯定时"
        }
    }
}

