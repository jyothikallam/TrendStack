//
//  TwitterPlaceDetailViewController.swift
//  TrendStack
//
//  Created by Chanikya on 28/02/2016.
//  Copyright © 2016 joe. All rights reserved.
//

import UIKit

class TwitterPlaceDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
