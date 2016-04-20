//
//  TwitterTopicsViewController.swift
//  TrendStack
//
//  Created by Chanikya on 28/02/2016.
//  Copyright © 2016 joe. All rights reserved.
//

import UIKit
import TwitterKit
import Firebase

class TwitterTopicsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var topicsData = [AnyObject]()
    var asOf: String = ""
    var timestamp: NSTimeInterval = 0.0
    var refreshTimestamp: NSTimeInterval = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //refreshTimestamp = NSDate().timeIntervalSince1970
    }
    
    override func viewWillAppear(animated: Bool) {
        if (refreshTimestamp == 0.0) || (refreshTimestamp + 60 > NSDate().timeIntervalSince1970) {
            self.getData()
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if topicsData.count > 0 {
            if let trends = (topicsData[0]["trends"]) {
                return trends!.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("topicCell")!
        if topicsData.count > 0 {
            let trends =  (topicsData[0]["trends"])!
            let trend = trends![indexPath.row]
            cell.textLabel?.text = trend["name"] as? String
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("topicDetailSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "topicDetailSegue" {
            let destVC = segue.destinationViewController as! TwitterTopicDetailViewController
            
            let selectedIndex = self.tableView.indexPathForSelectedRow
            let trends =  (topicsData[0]["trends"])!
            let trend = trends![selectedIndex!.row]
            destVC.name = (trend["name"] as? String)!
            destVC.url =  (trend["url"] as? String)!
            destVC.query = (trend["query"] as? String)!
        }
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
                                self.topicsData = jsonResult as [AnyObject]!
                                self.refreshTimestamp = NSDate().timeIntervalSince1970
                                self.saveData()
                            }
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }
                    else {
                        print("Error: \(connectionError)")
                        self.refreshTimestamp = NSDate().timeIntervalSince1970
                    }
                }
            }
            else {
                print("Error: \(clientError)")
                self.refreshTimestamp = NSDate().timeIntervalSince1970
            }
        }
    }
    
    func saveData() {
        // Create a reference to a Firebase location
        let myRootRef = Firebase(url:"https://TrendStack.firebaseio.com")
        // Write data to Firebase
        
        let usersRef = myRootRef.childByAppendingPath("TwitterTrendingTopics")
        let data = ["data": self.topicsData, "timestamp": NSDate().timeIntervalSince1970]    //FirebaseServerValue.timestamp()
        usersRef.setValue(data)
    }
    
    func getData() {
        // Get a reference to our posts
        let ref = Firebase(url:"https://TrendStack.firebaseio.com/TwitterTrendingTopics")
        
        // Attach a closure to read the data at our posts reference
        ref.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            if snapshot.value is NSNull {
                self.loadTopics()
            }
            else  {
                self.topicsData = snapshot.value["data"] as! [AnyObject]
                self.timestamp = snapshot.value["timestamp"] as! NSTimeInterval
                
                let currentDateTime = NSDate()
                
                if self.timestamp + 60.0 < currentDateTime.timeIntervalSince1970 {
                    self.loadTopics()
                }
                    
                else {
                    self.tableView.reloadData()
                }
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
}
