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


    
    var messageOriginalCenter: CGPoint!
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
        messageLeft = CGPoint(x: messageView.center.x  + messageLeftOffset, y:messageView.center.y)
        messageRight = CGPoint(x: messageView.center.x  + messageRightOffset, y:messageView.center.y)
        
        self.rescheduleView.hidden = false;
        self.rescheduleView.alpha = 0;
    }
    
    @IBAction func didPanMessage(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            print("Gesture began at: \(translation)")
            messageOriginalCenter = messageView.center
        }
        if sender.state == UIGestureRecognizerState.Changed {
            print("Gesture changed at: \(translation)")
            messageView.center = CGPoint(x: messageOriginalCenter.x + translation.x, y: messageOriginalCenter.y)
        }
        
        if translation.x >= 0 && translation.x <= 50 {
            leftView.backgroundColor = UIColor.init(hexString: "e3e3e3")
            leftViewImage.image = UIImage(named: "archive_icon")
        }
        if translation.x >= 50 && translation.x <= 220 {
            leftView.backgroundColor = UIColor.init(hexString: "70d962")
            leftViewImage.image = UIImage(named: "archive_icon")
        }
        if translation.x >= 220 && translation.x <= 320 {
            leftView.backgroundColor = UIColor.init(hexString: "e21314")
            leftViewImage.image = UIImage(named: "delete_icon")
        }
        
        if translation.x <= 0 && translation.x >= -50 {
            rightView.backgroundColor = UIColor.init(hexString: "e3e3e3")
            rightViewImage.image = UIImage(named: "later_icon")
        }
        if translation.x <= -50 && translation.x >= -220 {
            rightView.backgroundColor = UIColor.init(hexString: "fad233")
            rightViewImage.image = UIImage(named: "later_icon")
        }
        if translation.x <= -220 && translation.x >= -320 {
            rightView.backgroundColor = UIColor.init(hexString: "d8a675")
            rightViewImage.image = UIImage(named: "list_icon")

        }
        
        
        if sender.state == UIGestureRecognizerState.Ended {
            print("Gesture ended at: \(translation)")
            
            UIView.animateWithDuration(0.9, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options:[] , animations: { () -> Void in self.messageView.center = self.messageOriginalCenter
                }, completion: {(Bool) -> Void in
            })
            if velocity.x < -500 {
                print("velocity")
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.rescheduleView.alpha = 1;
                })
            }
        }
        

        
    }



    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rescheduleViewButton(sender: UIButton) {
        self.rescheduleView.alpha = 0;
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
