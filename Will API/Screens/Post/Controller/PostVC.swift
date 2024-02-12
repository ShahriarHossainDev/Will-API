//
//  PostVC.swift
//  Will API
//
//  Created by Shishir_Mac on 10/2/24.
//

import UIKit

class PostVC: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentTableView: UITableView!
    
    var postTitle: String?
    var postBody: String?
    var postId: Int?
    
    let apiManager = APIManager()
    var comments: [Comments] = []
    
    let cellIdentifier: String = "CommentsTableViewCell"
    
    let refreshControl = UIRefreshControl()
    
    // Loading Spinner
    let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        titleLabel.text = postTitle
        bodyLabel.text = postBody
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.separatorStyle = .none
        
        self.commentTableView.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        commentTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        commentsView.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
        
        getAllFetchComments()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commentTableView.reloadData()
    }
    
    // MARK: - Function
    
    @objc func refreshData() {
        getAllFetchComments()
    }
    
    func getAllFetchComments() {
        loadingSpinner.startAnimating()
        
        guard let postId = postId else {
            return
        }
        
        apiManager.fetchCommentsRequest(postId: postId) { [weak self] result in
            guard let self = self else { return }
            
            self.loadingSpinner.stopAnimating()
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let comments):
                self.comments = comments
                DispatchQueue.main.async {
                    self.commentTableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }

    }
    
    
}

extension PostVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CommentsTableViewCell {
            cell.configurateCommentsTheCell(comment)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}
