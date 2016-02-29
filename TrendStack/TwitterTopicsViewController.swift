//
//  TwitterTopicsViewController.swift
//  TrendStack
//
//  Created by Chanikya on 28/02/2016.
//  Copyright © 2016 joe. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterTopicsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var topicsData = [AnyObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadTopics()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("topicCell")!
        if topicsData.count != 0 {
            let trend = topicsData[indexPath.row]
            cell.textLabel?.text = trend["name"] as? String
        }
        return cell
    }
    
    func loadTopics() {
        // Swift
        //let client = TWTRAPIClient()
        
        if let userID = Twitter.sharedInstance().sessionStore.session()!.userID {
            let client = TWTRAPIClient(userID: userID)
            // make requests with client
            let statusesShowEndpoint = "https://api.twitter.com/1.1/trends/place.json"
            let params = ["id": "1"]
            var clientError : NSError?
            
            let request:NSURLRequest?
            request = client.URLRequestWithMethod("GET", URL: statusesShowEndpoint, parameters: params, error: &clientError)
            
            if request != nil {
                client.sendTwitterRequest(request!) { (response, data, connectionError) -> Void in
                    if (connectionError == nil) {
                        do {
                            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSArray {
                                print(jsonResult)
                                self.topicsData = (jsonResult[0]["trends"] as? Array)!
                                print(self.topicsData)
                                self.tableView.reloadData()
                            }
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }
                    else {
                        print("Error: \(connectionError)")
                    }
                }
            }
            else {
                print("Error: \(clientError)")
            }
        }
    }

}
