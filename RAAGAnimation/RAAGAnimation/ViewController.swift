//
//  ViewController.swift
//  RAAGAnimation
//
//  Created by Vikram Bisht on 8/21/15.
//  Copyright (c) 2015 Anurag Bisht. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var overlayView: UIView!
    var alertView: UIView!
    var animator: UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var snapBehavior : UISnapBehavior!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator = UIDynamicAnimator(referenceView: view)
        
        createOverlay()
        createAlert()
        // Do any additional setup after loading the view.
    }
    func createOverlay() {
        // Create a gray view and set its alpha to 0 so it isn't visible
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.grayColor()
        overlayView.alpha = 0.0
        view.addSubview(overlayView)
    }
    func createAlert() {
        
        // Here the red alert view is created. It is created with rounded corners and given a shadow around it
        let alertWidth: CGFloat = 250
        let alertHeight: CGFloat = 150
        let alertViewFrame: CGRect = CGRectMake(0, 0, alertWidth, alertHeight)
        alertView = UIView(frame: alertViewFrame)
        alertView.backgroundColor = UIColor.redColor()
        alertView.alpha = 0.0
        alertView.layer.cornerRadius = 10;
        alertView.layer.shadowColor = UIColor.blackColor().CGColor;
        alertView.layer.shadowOffset = CGSizeMake(0, 5);
        alertView.layer.shadowOpacity = 0.3;
        alertView.layer.shadowRadius = 10.0
        
        // Create a button and set a listener on it for when it is tapped. Then the button is added to the alert view
        let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.setTitle("Dismiss", forState: UIControlState.Normal)
        button.backgroundColor = UIColor.whiteColor()
        button.frame = CGRectMake(0, 0, alertWidth, 40.0)
        
        
        button.addTarget(self, action: Selector("dismissAlert"), forControlEvents: UIControlEvents.TouchUpInside)
        
        alertView.addSubview(button)
        view.addSubview(alertView)
        
    }
    
    func showAlert() {
        // When the alert view is dismissed, I destroy it, so I check for this condition here
        // since if the Show Alert button is tapped again after dismissing, alertView will be nil
        // and so should be created again
        if (alertView == nil) {
            createAlert()
        }
        // I create the pan gesture recognizer here and not in ViewDidLoad() to
        // prevent the user moving the alert view on the screen before it is shown.
        // Remember, on load, the alert view is created but invisible to user, so you
        // don't want the user moving it around when they swipe or drag on the screen.
        createGestureRecognizer()
        
        animator.removeAllBehaviors()
        
        // Animate in the overlay
        UIView.animateWithDuration(0.4) {
            self.overlayView.alpha = 1.0
        }
        
        // Animate the alert view using UIKit Dynamics.
        alertView.alpha = 1.0
        
        var snapBehaviour: UISnapBehavior = UISnapBehavior(item: alertView, snapToPoint: view.center)
        animator.addBehavior(snapBehaviour)
        
        
    }
    func dismissAlert() {
        
        animator.removeAllBehaviors()
        
        var gravityBehaviour: UIGravityBehavior = UIGravityBehavior(items: [alertView])
        gravityBehaviour.gravityDirection = CGVectorMake(0.0, 10.0);
        animator.addBehavior(gravityBehaviour)
        
        // This behaviour is included so that the alert view tilts when it falls, otherwise it will go straight down
        var itemBehaviour: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [alertView])
        itemBehaviour.addAngularVelocity(CGFloat(-M_PI_2), forItem: alertView)
        animator.addBehavior(itemBehaviour)
        
        // Animate out the overlay, remove the alert view from its superview and set it to nil
        // If you don't set it to nil, it keeps falling off the screen and when Show Alert button is
        // tapped again, it will snap into view from below. It won't have the location settings we defined in createAlert()
        // And the more it 'falls' off the screen, the longer it takes to come back into view, so when the Show Alert button
        // is tapped again after a considerable time passes, the app seems unresponsive for a bit of time as the alert view
        // comes back up to the screen
        UIView.animateWithDuration(0.4, animations: {
            self.overlayView.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.alertView.removeFromSuperview()
                self.alertView = nil
        })
        
    }
    
    @IBAction func showAlertView(sender: UIButton) {
        showAlert()
    }
    
    func createGestureRecognizer() {
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        if (alertView != nil) {
            let panLocationInView = sender.locationInView(view)
            let panLocationInAlertView = sender.locationInView(alertView)
            
            if sender.state == UIGestureRecognizerState.Began {
                animator.removeAllBehaviors()
                
                let offset = UIOffsetMake(panLocationInAlertView.x - CGRectGetMidX(alertView.bounds), panLocationInAlertView.y - CGRectGetMidY(alertView.bounds));
                attachmentBehavior = UIAttachmentBehavior(item: alertView, offsetFromCenter: offset, attachedToAnchor: panLocationInView)
                
                animator.addBehavior(attachmentBehavior)
            }
            else if sender.state == UIGestureRecognizerState.Changed {
                attachmentBehavior.anchorPoint = panLocationInView
            }
            else if sender.state == UIGestureRecognizerState.Ended {
                animator.removeAllBehaviors()
                
                snapBehavior = UISnapBehavior(item: alertView, snapToPoint: view.center)
                animator.addBehavior(snapBehavior)
                
                if sender.translationInView(view).y > 100 {
                    dismissAlert()
                }
            }
        }
        
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

