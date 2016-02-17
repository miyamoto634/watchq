//
//  CatchError.swift
//  WatchQ
//
//  Created by H1-2 on 09/11/2015.
//  Copyright © 2015 Ninja Egg. All rights reserved.
//
import UIKit

class CatchError: UIViewController {
    
      let defaults1 = NSUserDefaults.standardUserDefaults();
      let helper = Helper();
    
    @IBOutlet weak var errorTextView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
           _  = NSTimer.scheduledTimerWithTimeInterval(0.2 , target: self, selector: "showError", userInfo: nil, repeats: false)
        
       
    }
    
    func showError()
    {
        //if(defaults.stringForKey("exceptionStr") != nil &&  defaults.stringForKey("exceptionStr")! != "")
        //{
        let exceptionError = defaults1.stringForKey("exceptionStr")!;
        print("fffff: " + exceptionError);
        errorTextView.text = exceptionError;
        
       // print(exceptionError);
        //}
    }
    
  
    @IBAction func closeThisView(sender: AnyObject)
    {
        //self.dismissViewControllerAnimated(true, completion: nil)
        
        defaults1.setInteger(0, forKey: "pageNo");
        
        let walkthrough1  = helper.goToPetView();
        self.presentViewController(walkthrough1, animated: false, completion: nil);
    }
    
}
