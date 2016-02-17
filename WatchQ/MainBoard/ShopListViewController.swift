//
//  ShopListViewController.swift
//  WatchQ
//
//  Created by Ali on 29/07/2015.
//  Copyright (c) 2015 Ninja Egg. All rights reserved.
//
import UIKit
import StoreKit

class ShopListViewController: UIViewController , BWWalkthroughViewControllerDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    
    let defaults1 = NSUserDefaults.standardUserDefaults();
    
    var diamondsAmount = 0;
    
    @IBOutlet weak var goldenAmountL: UILabel!
    @IBOutlet weak var diamondsAmountL: UILabel!
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)// for in app purchase
        

        diamondsAmount = defaults1.integerForKey("diamondsAmount");
        diamondsAmountL.text = "Diamonds: \(diamondsAmount)";
    }
    
     private let prefixStr = "com.ninjaegg.WatchQ.Diamond"
    private let productIDs : [String] = ["com.ninjaegg.WatchQ.Diamond2","com.ninjaegg.WatchQ.Diamond10", "com.ninjaegg.WatchQ.Diamond24", "com.ninjaegg.WatchQ.Diamond50", "com.ninjaegg.WatchQ.Diamond160" ];
    
    @IBAction func item1(sender: AnyObject)
    {
        buyConsumable(productIDs[0]);
    }
    
    @IBAction func item2(sender: AnyObject)
    {
        buyConsumable(productIDs[1]);
    }
    
    @IBAction func item3(sender: AnyObject)
    {
        buyConsumable(productIDs[2]);
    }
    
    @IBAction func item4(sender: AnyObject)
    {
        buyConsumable(productIDs[3]);
    }
   
    @IBAction func item5(sender: AnyObject)
    {
        buyConsumable(productIDs[4]);
    }
    
    @IBAction func backBtn(sender: AnyObject)
    {
        backToPreviousView();
    }

    @IBAction func lawBtn(sender: AnyObject)
    {
        let url = NSURL(string: "http://ninja-egg.com/minigame/#watchq_attention03")!
        UIApplication.sharedApplication().openURL(url)//open url by web browser
    }
    
    var helper = Helper();
    func backToPreviousView()
    {
        if(defaults1.integerForKey( "messageNo") == 1)
        {// when the pet dead if he payed to keep every things
            defaults1.setInteger(0, forKey: "messageNo");
            let mainStb = UIStoryboard(name: "Main", bundle: nil)
            let quizCategory = mainStb.instantiateViewControllerWithIdentifier("mainView") as! ViewController
            self.presentViewController(quizCategory, animated: false, completion: nil);
        }
        else
        {
            defaults1.setInteger(0, forKey: "pageNo");
            let walkthrough1  = helper.goToPetView();
            self.presentViewController(walkthrough1, animated: false, completion: nil);
        }
        return;
    }
    
    //>--> for In-App Purchase
   // var product_id: NSString?;//to know which id
    
    
   
    func buyConsumable( productID : String)
    {
        if (SKPaymentQueue.canMakePayments())// We check that we are allow to make the purchase.
        {
            let product_id: Set<NSObject> = [productID]
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: product_id as! Set<String>);
            productsRequest.delegate = self;
            productsRequest.start();
            print("Fething Products");
        }
        else
        {
            print("can't make purchases");
        }
    }
    
    
    // Helper Methods
    func buyProduct(product: SKProduct){
        print("Sending the Payment Request to Apple");
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment);
        
    }
    
    
    // Delegate Methods for IAP(in app purchase)
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)
    {
        print("got the request from Apple")
        let count : Int = response.products.count
        print(count)
        if (count>0)
        {
            _ = response.products
            let validProduct: SKProduct = response.products[0]
            
            var foundIt = false;
            
            for( var i = 0; i < productIDs.count; i++)
            {
                if (validProduct.productIdentifier == productIDs[i])
                {
                    print(validProduct.localizedTitle)
                    print(validProduct.localizedDescription)
                    print(validProduct.price)
                    buyProduct(validProduct);
                    foundIt = true;
                    break;
                }
            }
            
            if(!foundIt)
            {
                print(validProduct.productIdentifier)
            }
           
        }
        else
        {
            print("nothing")
        }
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print("La vaina fallo: ");
        print(error, terminator: "");
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        print("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions
        {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction
            {
                switch trans.transactionState
                {
                case .Purchased:
    
                    self.diamondsAmount =  self.defaults1.integerForKey("diamondAmount");
                    
                    if (trans.payment.productIdentifier == productIDs[0])
                    {
                        self.diamondsAmount +=  2 ;
                        print("add \(2)");
                    }
                    else if (trans.payment.productIdentifier == productIDs[1])
                    {
                        self.diamondsAmount +=  10 ;
                        print("add \(10)");
                    }
                    else if (trans.payment.productIdentifier == productIDs[2])
                    {
                        self.diamondsAmount +=  24 ;
                        print("add \(24)");
                    }
                    else if (trans.payment.productIdentifier == productIDs[3])
                    {
                        self.diamondsAmount +=  50 ;
                        print("add \(50)");
                    }
                    else if (trans.payment.productIdentifier == productIDs[4])
                    {
                       self.diamondsAmount +=  160 ;
                        print("add \(160)");
                    }
                    
                     self.defaults1.setInteger(self.diamondsAmount, forKey: "diamondAmount")
                    
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .Failed:
                    print("Purchased Failed");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                    // case .Restored:
                    //[self restoreTransaction:transaction];
                default:
                    break;
                }
            }
        }
        
    }
    //<--< end in-app
    
    // MARK: - Walkthrough delegate -
    func walkthroughPageDidChange(pageNumber: Int)
    {
       // println("Current Page \(pageNumber)")
    }
    
    func walkthroughCloseButtonPressed()
    {
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
