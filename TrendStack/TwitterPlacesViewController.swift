//
//  SecondViewController.swift
//  TrendStack
//
//  Created by Chanikya on 28/02/2016.
//  Copyright © 2016 joe. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var placesData : [[String:String]] = []  // Array of array ( city, country, woeid)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadPlaces()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("placeCell")!
        if placesData.count != 0 {
            let trend = placesData[indexPath.row]
            cell.textLabel?.text = trend["name"]! + ", " + trend["country"]!
        }
        return cell
    }
    
    func loadPlaces() {
        // Swift
        //let client = TWTRAPIClient()
        
        if let userID = Twitter.sharedInstance().sessionStore.session()!.userID {
            let client = TWTRAPIClient(userID: userID)
            // make requests with client
            let statusesShowEndpoint = "https://api.twitter.com/1.1/trends/available.json"
            //let params = ["id": "1"]
            var clientError : NSError?
            
            let request:NSURLRequest?
            request = client.URLRequestWithMethod("GET", URL: statusesShowEndpoint, parameters: nil, error: &clientError)
            
            if request != nil {
                client.sendTwitterRequest(request!) { (response, data, connectionError) -> Void in
                    if (connectionError == nil) {
                        do {
                            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSArray {
                                print(jsonResult)
                                
                                for (var i = 0; i < jsonResult.count; i++) {
                                    let resDict = jsonResult[i]
                                    let resArr = ["name" : resDict["name"] as! String, "country" : resDict["country"] as! String, "woeid" : String(resDict["woeid"])]
                                        
                                    self.placesData.append(resArr)
                                }
                                
                                //self.placesData = (jsonResult[0]["trends"] as? Array)!
                                print(self.placesData)
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

