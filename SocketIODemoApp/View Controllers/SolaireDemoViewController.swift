//
//  SolaireDemoViewController.swift
//  SocketIODemoApp
//
//  Created by Pandey on 25/04/17.
//  Copyright © 2017 Pandey. All rights reserved.
//

import UIKit

class SolaireDemoViewController: UIViewController {
    
    @IBOutlet weak var lblNewsBanner: UILabel!
    var bannerLabelTimer: Timer!
    @IBOutlet weak var lblCurrentStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNewsBannerLabel()
        
        SocketIOManager.sharedInstance.closeConnection()
        lblCurrentStatus.text = "Disconnected"
        lblCurrentStatus.textColor = UIColor.red
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePaymentSuccessNotification(notification:)), name: NSNotification.Name(rawValue: "paymentSuccessNotification"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNewsBannerLabel() {
        lblNewsBanner.layer.cornerRadius = 15.0
        lblNewsBanner.clipsToBounds = true
        lblNewsBanner.alpha = 0.0
    }
    
    func handlePaymentSuccessNotification(notification: NSNotification) {
        let connectedUserInfo = notification.object as! [String: AnyObject]
        
        if let isPaymentSuccessfull = connectedUserInfo["isPaymentSuccessfull"]?.boolValue {
            if isPaymentSuccessfull {
                lblNewsBanner.text = "Your Payment is Successful"
            } else {
                lblNewsBanner.text = "Payment Failed"
            }
        }
        showBannerLabelAnimated()
    }
    
    func showBannerLabelAnimated() {
        UIView.animate(withDuration: 0.75, animations: { () -> Void in
            self.lblNewsBanner.alpha = 1.0
            
        }) { (finished) -> Void in
            self.bannerLabelTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ChatViewController.hideBannerLabel), userInfo: nil, repeats: false)
        }
    }
    
    
    func hideBannerLabel() {
        if bannerLabelTimer != nil {
            bannerLabelTimer.invalidate()
            bannerLabelTimer = nil
        }
        
        UIView.animate(withDuration: 0.75, animations: { () -> Void in
            self.lblNewsBanner.alpha = 0.0
            
        }) { (finished) -> Void in
        }
    }
    
    @IBAction func openConnection(_ sender: Any) {
        SocketIOManager.sharedInstance.establishConnection()
        lblNewsBanner.text = "You are connected"
        lblCurrentStatus.text = "Connected"
        lblCurrentStatus.textColor = UIColor.green
        showBannerLabelAnimated()
    }
    
    @IBAction func closeConnection(_ sender: Any) {
        SocketIOManager.sharedInstance.closeConnection()
        lblNewsBanner.text = "You are disconnected"
        lblCurrentStatus.text = "Disconnected"
        lblCurrentStatus.textColor = UIColor.red
        showBannerLabelAnimated()
    }
}
