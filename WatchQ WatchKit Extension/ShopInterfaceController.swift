//
//  ShopInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/07/31.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class ShopInterfaceController: WKInterfaceController
{
    @IBAction func showEquipment()
    {
        presentControllerWithNames(["shoplist", "shoplist"], contexts: ["goldEquip", "diaEquip"])
    }
    
    @IBAction func showConsume()
    {
        presentControllerWithNames(["shoplist", "shoplist"], contexts: ["goldConsume", "diaConsume"])
    }
}
