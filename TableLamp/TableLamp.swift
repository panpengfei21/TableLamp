//
//  TableLamp.swift
//  LRNotification_Test
//
//  Created by Liuming Qiu on 16/2/22.
//  Copyright © 2016年 Liuming Qiu. All rights reserved.
//

import AVFoundation

class TableLamp{

    /// 总控
    private let session:AVCaptureSession
    /// 输入设备
    private let device:AVCaptureDevice
    
    /// 灯光的开关
    var lampToggle:Bool{
        set{
            lampToggle(newValue)
        }
        get{
            return device.torchMode == AVCaptureTorchMode.On
        }
    }
    
    /// 台灯的亮度的大小
    var torchLevel:Float = 0.0 {
        didSet{
            setTorchLevel(torchLevel)
        }
    }
    
    /// 台灯的最大值
    var torchMaxLevel:Float{
        return AVCaptureMaxAvailableTorchLevel
    }
    
    /**
     初始化
     
     - returns: 如果不能加灯光，则返回nil
     */
    init?(){
        session = AVCaptureSession()
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // 配制
        session.beginConfiguration()
        defer{
            session.commitConfiguration()
        }
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: device)
            session.addInput(deviceInput)
            if !device.hasTorch{
                print("this device has not a torch.")
                return nil
            }
        }catch let error as NSError{
            print("init Table Lamp`s session is error:\(error)")
            return nil
        }
    }
    
    /**
     台灯开关
     
     - parameter toggle: 开关
     */
    private func lampToggle(toggle:Bool){
        do{
            try device.lockForConfiguration()
            device.torchMode = toggle ? AVCaptureTorchMode.On : AVCaptureTorchMode.Off
            device.unlockForConfiguration()
        }catch let error as NSError{
            print("device cann`t be configuration with error:\(error)")
        }
    }
    
    /**
     设置台灯的亮度
     
     - parameter level: 台灯的亮度的数据 范围 0.0 － 1.0 内, warnning:不能设为0.0 或 1.0，不支持。
     */
    private func setTorchLevel(level:Float){
        guard (try? device.lockForConfiguration()) != nil else{
            print("device.lockFor configuration has error")
            return
        }
        defer {
            device.unlockForConfiguration()
        }
        
        do{
            try device.setTorchModeOnWithLevel(level)
        }catch let error as NSError{
            print("setTorchModeOnWithLevel as error:\(error)")
        }
    }
}