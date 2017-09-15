//
//  ChatViewController.swift
//  SocketIODemoApp
//
//  Created by Pandey on 25/04/17.
//  Copyright © 2017 Pandey. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var lblOtherUserActivityStatus: UILabel!
    @IBOutlet weak var tvMessageEditor: UITextView!
    @IBOutlet weak var conBottomEditor: NSLayoutConstraint!
    @IBOutlet weak var lblNewsBanner: UILabel!
    
    var nickname: String!
    var chatMessages = [[String: AnyObject]]()
    var bannerLabelTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(handleKeyboardDidShowNotification(notification:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHideNotification(notification:)), name: .UIKeyboardDidHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectedUserUpdateNotification(notification:)), name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDisconnectedUserUpdateNotification(notification:)), name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserTypingNotification(notification:)), name: NSNotification.Name(rawValue: "userTypingNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePaymentSuccessNotification(notification:)), name: NSNotification.Name(rawValue: "paymentSuccessNotification"), object: nil)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        swipeGestureRecognizer.direction = .down
        swipeGestureRecognizer.delegate = self
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
        configureNewsBannerLabel()
        configureOtherUserActivityLabel()
        
        tvMessageEditor.delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.chatMessages.append(messageInfo)
                self.tblChat.reloadData()
                self.scrollToBottom()
            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: IBAction Methods
    
    @IBAction func sendMessage(sender: AnyObject) {
        
        if tvMessageEditor.text.characters.count > 0 {
            SocketIOManager.sharedInstance.sendMessage(message: tvMessageEditor.text!, withNickname: nickname)
            tvMessageEditor.text = ""
            tvMessageEditor.resignFirstResponder()
        }
    }
    
    
    // MARK: Custom Methods
    func configureTableView() {
        tblChat.delegate = self
        tblChat.dataSource = self
        tblChat.register(UINib.init(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "idCellChat")
        tblChat.estimatedRowHeight = 90.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        tblChat.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    func configureNewsBannerLabel() {
        lblNewsBanner.layer.cornerRadius = 15.0
        lblNewsBanner.clipsToBounds = true
        lblNewsBanner.alpha = 0.0
    }
    
    
    func configureOtherUserActivityLabel() {
        lblOtherUserActivityStatus.isHidden = true
        lblOtherUserActivityStatus.text = ""
    }
    
    
    func handleKeyboardDidShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                conBottomEditor.constant = keyboardFrame.size.height
                view.layoutIfNeeded()
            }
        }
    }
    
    
    func handleKeyboardDidHideNotification(notification: NSNotification) {
        conBottomEditor.constant = 0
        view.layoutIfNeeded()
    }
    
    
    func scrollToBottom() {
        _ = 0.1 * Double(NSEC_PER_SEC)
        
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
    
    
    
    func dismissKeyboard() {
        if tvMessageEditor.isFirstResponder {
            tvMessageEditor.resignFirstResponder()
            
            SocketIOManager.sharedInstance.sendStopTypingMessage(nickname: nickname)
        }
    }
    
    
    func handleConnectedUserUpdateNotification(notification: NSNotification) {
        let connectedUserInfo = notification.object as! [String: AnyObject]
        let connectedUserNickname = connectedUserInfo["nickname"] as? String
        lblNewsBanner.text = "User \(connectedUserNickname!.uppercased()) was just connected."
        showBannerLabelAnimated()
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
        /*
         let connectedUserNickname = connectedUserInfo["nickname"] as? String
         lblNewsBanner.text = "User \(connectedUserNickname!.uppercased()) was just connected." */
        showBannerLabelAnimated()
    }
    
    
    func handleDisconnectedUserUpdateNotification(notification: NSNotification) {
        let disconnectedUserNickname = notification.object as! String
        lblNewsBanner.text = "User \(disconnectedUserNickname.uppercased()) has left."
        showBannerLabelAnimated()
    }
    
    
    func handleUserTypingNotification(notification: NSNotification) {
        if let typingUsersDictionary = notification.object as? [String: AnyObject] {
            var names = ""
            var totalTypingUsers = 0
            for (typingUser, _) in typingUsersDictionary {
                if typingUser != nickname {
                    names = (names == "") ? typingUser : "\(names), \(typingUser)"
                    totalTypingUsers += 1
                }
            }
            
            if totalTypingUsers > 0 {
                let verb = (totalTypingUsers == 1) ? "is" : "are"
                
                lblOtherUserActivityStatus.text = "\(names) \(verb) now typing a message..."
                lblOtherUserActivityStatus.isHidden = false
            }
            else {
                lblOtherUserActivityStatus.isHidden = true
            }
        }
        
    }
    
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellChat", for: indexPath as IndexPath) as! ChatCell
        
        let currentChatMessage = chatMessages[indexPath.row]
        let senderNickname = currentChatMessage["nickname"] as! String
        let message = currentChatMessage["message"] as! String
        let messageDate = currentChatMessage["date"] as! String
        
        if senderNickname == nickname {
            cell.lblChatMessage.textAlignment = NSTextAlignment.right
            cell.lblMessageDetails.textAlignment = NSTextAlignment.right
            cell.lblChatMessage.textColor = UIColor.blue
            cell.bubbleImage.image = UIImage.init(named: "BubbleOutgoing")?.stretchableImage(withLeftCapWidth: 15, topCapHeight: 14)
        } else {
            cell.bubbleImage.image = UIImage.init(named: "BubbleIncoming")?.stretchableImage(withLeftCapWidth: 15, topCapHeight: 14)
        }
        
        cell.lblChatMessage.text = message
        cell.lblMessageDetails.text = "by \(senderNickname.uppercased()) @ \(messageDate)"
        
        cell.lblChatMessage.textColor = UIColor.blue
        
        return cell
    }
    
    
    // MARK: UITextViewDelegate Methods
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        SocketIOManager.sharedInstance.sendStartTypingMessage(nickname: nickname)
        return true
    }
    
    
    // MARK: UIGestureRecognizerDelegate Methods
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
