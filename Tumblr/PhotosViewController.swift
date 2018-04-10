//
//  ViewController.swift
//  Tumblr
//
//  Created by Rui Mao on 4/8/18.
//  Copyright © 2018 Rui Mao. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController {
    var posts = [NSDictionary]()

    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 320
        fetchPosts()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    
    func fetchPosts() {
        let apikey = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apikey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request as URLRequest,completionHandler: { (dataOrNil, response, error) in
            //sleep(1)
            //MBProgressHUD.hide(for: self.view, animated: true)
            if let httpError = error {
                print("\(httpError)")
            } else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
            
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                        print("posts:" , self.posts)
                        self.tableView.reloadData()
                    }
                }
            }
            
        });
        task.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        let post = posts[indexPath.row]
        let photos = post.value(forKey: "photos") as? [NSDictionary]
        let imageUrlString = photos![0].value(forKeyPath: "original_size.url") as? String
        let imageUrl = URL(string: imageUrlString!)
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.imageUrl = imageUrl
        
    }
}

extension PhotosViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
}

extension PhotosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoCell
            let post = posts[indexPath.row]
            let content = post["caption"] as? String
        cell.label.text = content?.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
            //let timestamp = post["timestamp"] as? String
            if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
                let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
                if let imageUrl = URL(string: imageUrlString!) {
                    cell.photoImageView.setImageWith(imageUrl)
                } else {
                    print("imageUrl is nil")
                }
            } else {
                print("photos is nil")
                
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        tableView.deselectRow(at: indexPath!, animated: true)
    }
    
}
