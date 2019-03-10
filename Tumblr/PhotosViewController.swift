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
        navigationItem.title = "Tumblr"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 330
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchPosts(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = .white
        tableView.insertSubview(refreshControl, at: 0)
    }

    
    @objc func fetchPosts(_ refreshControl: UIRefreshControl) {
        //create a configuration
        let configuration = URLSessionConfiguration.default
        //create a session
        let session = URLSession(configuration: configuration)
        //Setup the url
        let apikey = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apikey)")
        //Create the task
        let task = session.dataTask(with: url!){
            (data, reponse, error) in
            guard let httpResponse = reponse as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                return
            }
            do {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                    let queue = OperationQueue.main
                    queue.addOperation {
                        self.tableView.reloadData()
                        refreshControl.endRefreshing()
                    }
//                    DispatchQueue.main.async {
//          
//                    }
                }
            }
            
        }
        task.resume()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        let post = posts[indexPath.section]
        let photos = post.value(forKey: "photos") as? [NSDictionary]
        let imageUrlString = photos![0].value(forKeyPath: "original_size.url") as? String
        let imageUrl = URL(string: imageUrlString!)
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.imageUrl = imageUrl
    }
}

extension PhotosViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension PhotosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoCell
            let post = posts[indexPath.section]
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        let profileView = UIImageView(frame: CGRect(x: 10, y: 0, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // set the avatar
        profileView.setImageWith(NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")! as URL)
        headerView.addSubview(profileView)
        let post = posts[section]
        let dateString = post["date"] as! String
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm"
        let label = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 30))
        label.textAlignment = .left
        if let date = dateFormatterGet.date(from: dateString) {
            label.text = dateFormatterPrint.string(from: date)
        } else {
            print("error decoding the string")
        }
        label.textColor = .lightGray
        headerView.addSubview(label)
        return headerView

    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let tableFooterView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingView.startAnimating()
        loadingView.center = tableFooterView.center
        tableFooterView.addSubview(loadingView)
        self.tableView.tableFooterView = tableFooterView
        return tableFooterView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}


