//
//  HomeVC.swift
//  Will API
//
//  Created by Shishir_Mac on 9/2/24.
//

import UIKit
import Alamofire

class HomeVC: UIViewController {
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var postSearchBar: UISearchBar!
    @IBOutlet weak var createPostBarButtonItem: UIBarButtonItem!
    
    let apiManager = APIManager()
    var posts: [Posts] = []
    var filteredPosts: [Posts] = []
    
    let cellIdentifier: String = "PostTableViewCell"
    
    let refreshControl = UIRefreshControl()
    
    // Loading Spinner
    let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        
        postSearchBar.delegate = self
        
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.separatorStyle = .none
        
        self.postsTableView.register(UINib(nibName: "PostTableViewCell", bundle: nil),forCellReuseIdentifier: cellIdentifier)
        
        postsTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
        getAllFetchPosts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postsTableView.reloadData()
    }
    
    // MARK: - Function
    
    @objc private func refreshData() {
        getAllFetchPosts()
    }
    
    // show Post Detail View Controller
    func showPostDetailViewController(post: Posts) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        vc.postId = post.id
        vc.postTitle = post.title
        vc.postBody = post.body
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Action
    @IBAction func createPostBarButtonItemAction(_ sender: UIBarButtonItem) {
        createPostWithAlert()
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postSearchBar.isFirstResponder ? filteredPosts.count : posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = postSearchBar.isFirstResponder ? filteredPosts[indexPath.row] : posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PostTableViewCell {
            cell.configuratePostTheCell(post)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = postSearchBar.isFirstResponder ? filteredPosts[indexPath.row] : posts[indexPath.row]
        showPostDetailViewController(post: selectedPost)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let postToDelete = postSearchBar.isFirstResponder ? filteredPosts[indexPath.row] : posts[indexPath.row]
            
            if let postId = postToDelete.id {
                deletePost(postId)
            } else {
                print("Unable to delete post. Post ID is nil.")
            }
            
            posts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - Alert
extension HomeVC {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // create Post With Alert
    func createPostWithAlert() {
        let alert = UIAlertController(title: "Create Post", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter Title"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Enter Post"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Enter User ID"
            textField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let titleField = alert.textFields?[0],
                  let bodyField = alert.textFields?[1],
                  let userIdField = alert.textFields?[2],
                  let title = titleField.text,
                  let body = bodyField.text,
                  let userIdString = userIdField.text,
                  let userId = Int(userIdString) else {
                      return
                  }
            self?.createPost(title, body, userId)
        }
        
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UISearchBarDelegate
extension HomeVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredPosts(for: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        postSearchBar.text = ""
        filteredPosts(for: "")
        postSearchBar.resignFirstResponder()
    }
    
    func filteredPosts(for searchText: String) {
        if !searchText.isEmpty {
            filteredPosts = posts.filter({ posts in
                return posts.title?.lowercased().contains(searchText.lowercased()) ?? false
            })
        } else {
            filteredPosts = posts
        }
        postsTableView.reloadData()
    }
}

// MARK: - Fetch API
extension HomeVC {
    // get All Fetch Posts
    func getAllFetchPosts() {
        loadingSpinner.startAnimating()
        
        apiManager.userPostsRequest { [weak self] result in
            guard let self = self else { return }
            
            self.loadingSpinner.stopAnimating()
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let posts):
                self.posts = posts
                self.filteredPosts(for: self.postSearchBar.text ?? "")
                DispatchQueue.main.async {
                    self.postsTableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error)")
                self.showAlert(title: "Erroe", message: "Failed to fetch posts. Please try again.")
            }
        }
    }
    
    // create Post
    func createPost(_ title: String, _ body: String, _ userId: Int) {
        apiManager.createPost(title: title, body: body, userId: userId) { result in
            switch result {
            case .success(let response):
                print("Response: \(response)")
                DispatchQueue.main.async {
                    self.postsTableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error)")
                self.showAlert(title: "Erroe", message: "Failed to fetch posts. Please try again.")
            }
        }
    }
    
    // delete Post
    func deletePost(_ postId: Int) {
        apiManager.deletePost(postId: postId) { result in
            switch result {
            case .success(let response):
                print("Response: \(response)")
                DispatchQueue.main.async {
                    self.postsTableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error)")
                self.showAlert(title: "Erroe", message: "Failed to fetch posts. Please try again.")
            }
        }
    }
}
