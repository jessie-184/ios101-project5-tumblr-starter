import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tumblrPosts: [Post] = []
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupRefreshControl()
        fetchPosts()
    }
    
    func setupRefreshControl() {
        // Step 3: Add the refresh control to the table view
        tableView.refreshControl = refreshControl
                
        // Step 2: Set up the action to handle the refresh event
        refreshControl.addTarget(self, action: #selector(refreshFeed(_:)), for: .valueChanged)
    }
    
    @objc func refreshFeed(_ sender: Any) {
        // Step 4: Implement the action to fetch new data and reload the table view
        fetchPosts()
    }
    
    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)
                self.tumblrPosts = blog.response.posts
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print("✅ We got \(self.tumblrPosts.count) posts!")
                    for post in self.tumblrPosts {
                        print("🍏 Summary: \(post.summary)")
                    }
                    
                    // End refreshing after reloading table view data
                    self.refreshControl.endRefreshing()
                }
            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tumblrPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = tumblrPosts[indexPath.row]
        
        // Set the image using Nuke library
        if let imageURL = post.photos.first?.originalSize.url {
            Nuke.loadImage(with: imageURL, into: cell.postImageView)
        }
        
        // Set the summary text
        cell.postLabel.text = post.summary
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

