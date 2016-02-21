//
//  MailViewController.swift
//  mailbox
//
//  Created by Daniel Kim on 2/17/16.
//  Copyright © 2016 Daniel Kim. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


class MailViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var leftViewImage: UIImageView!
    @IBOutlet weak var rightViewImage: UIImageView!
    @IBOutlet weak var rescheduleView: UIView!
    @IBOutlet weak var messageViewImage: UIImageView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var feedViewImage: UIImageView!

    
    var messageOriginalCenter: CGPoint!
    var originalMessageViewImageCenter: CGPoint!
    var messageLeftOffset: CGFloat!
    var messageRightOffset: CGFloat!
    var messageRight: CGPoint!
    var messageLeft: CGPoint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: 320, height: 1136)
        
        messageLeftOffset = -320
        messageRightOffset = 320
        messageOriginalCenter = messageView.center
        originalMessageViewImageCenter = messageViewImage.center
        messageLeft = CGPoint(x: messageView.center.x  + messageLeftOffset, y:messageView.center.y)
        messageRight = CGPoint(x: messageView.center.x  + messageRightOffset, y:messageView.center.y)
        
        self.rescheduleView.hidden = false;
        self.rescheduleView.alpha = 0;
    }
    
    @IBAction func didPanMessage(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            print("Gesture began at: \(translation)")
            messageView.center = messageOriginalCenter
            messageViewImage.center = originalMessageViewImageCenter
            leftViewImage.alpha = 0.5
            rightViewImage.alpha = 0.5
            leftView.backgroundColor = UIColor.init(hexString: "e3e3e3")
            rightView.backgroundColor = UIColor.init(hexString: "e3e3e3")
        }
        if sender.state == UIGestureRecognizerState.Changed {
            print("Gesture changed at: \(translation)")

            // move only the message image
            if  translation.x >= -60 && translation.x <=  60{
                messageViewImage.center = CGPoint(x: originalMessageViewImageCenter.x + translation.x, y:originalMessageViewImageCenter.y)
            }
            
            // move everything
            // swipe left, affects rightView
            if translation.x <= -61 {
                messageView.center = CGPoint(x: messageOriginalCenter.x + translation.x + 60, y: messageOriginalCenter.y)
                messageViewImage.center = CGPoint(x: originalMessageViewImageCenter.x - 60, y:originalMessageViewImageCenter.y)
                rightView.backgroundColor = UIColor.init(hexString: "fad233")
                rightViewImage.image = UIImage(named: "later_icon")
            }
            
            if translation.x <= -260 && translation.x >= -320 {
                rightView.backgroundColor = UIColor.init(hexString: "d8a675")
                rightViewImage.image = UIImage(named: "list_icon")
            }
            
            // swipe right, affects leftView
            if translation.x >= 61 && translation.x <= 259 {
                messageView.center = CGPoint(x: messageOriginalCenter.x + translation.x - 60, y: messageOriginalCenter.y)
                messageViewImage.center = CGPoint(x: originalMessageViewImageCenter.x + 60, y:originalMessageViewImageCenter.y)
                leftView.backgroundColor = UIColor.init(hexString: "70d962")
                leftViewImage.image = UIImage(named: "archive_icon")
            }
            
            if translation.x >= 260 && translation.x <= 320 {
                leftView.backgroundColor = UIColor.init(hexString: "e21314")
                leftViewImage.image = UIImage(named: "delete_icon")
            }
        }
        
        
        if sender.state == UIGestureRecognizerState.Ended {
            print("Gesture ended at: \(translation)")
            
            // swipe left, affect rightView
            // if reschedule range
            if translation.x <= -60 && translation.x > -260{
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.messageView.center = CGPoint(x: 220, y: self.messageView.center.y)
                    self.rightViewImage.alpha = 0
                    }, completion: { (complete) -> Void in
                        if (complete) {
                            UIView.animateWithDuration(0.4, animations: { () -> Void in
                                self.rescheduleView.alpha = 1
                            })
                        }
                })
            }
            
            // if list range
            if translation.x <= -260 {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.messageView.center = CGPoint(x: 220, y: self.messageView.center.y)
                    self.rightViewImage.alpha = 0
                    }, completion: { (complete) -> Void in
                        if (complete) {
                            UIView.animateWithDuration(0.4, animations: { () -> Void in
                                self.listView.alpha = 1
                            })
                        }
                })
            }
            
            // swipe right, affect leftView
            // if archive/delete range
            if translation.x >= 60 && translation.x < 260 {
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.messageView.center = CGPoint(x: 740, y: self.messageView.center.y)
                    self.leftViewImage.alpha = 0
                    }, completion: { (complete) -> Void in
                        if (complete) {
                            self.hideMessage()
                        }
                })
            }
            if translation.x >= 260 {
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.messageView.center = CGPoint(x: 740, y: self.messageView.center.y)
                    self.leftViewImage.alpha = 0;
                    }, completion: { (complete) -> Void in
                        if (complete) {
                            self.hideMessage()
                        }
                })
            }
            
        }
        
    }

    func hideMessage() {
        UIView.animateWithDuration(0.5) { () -> Void in
            var messageFrame = self.messageView.frame
            let changeInY = messageFrame.size.height
            messageFrame.size.height = 0
            
            var feedFrame = self.feedViewImage.frame
            feedFrame.origin.y = feedFrame.origin.y - changeInY
            
            self.messageView.frame = messageFrame
            self.feedViewImage.frame = feedFrame
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rescheduleViewButton(sender: UIButton) {
        self.rescheduleView.alpha = 0;
        hideMessage()
    }
    
    @IBAction func listViewButton(sender: UIButton) {
        self.listView.alpha = 0;
        hideMessage()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
