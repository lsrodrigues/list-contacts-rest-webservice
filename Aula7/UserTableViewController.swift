//
//  UserTableViewController.swift
//  Aula7
//
//  Created by HC5MAC11 on 21/09/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {

    var users: [User]?
    override func viewDidLoad() {
        super.viewDidLoad()
        makeHTTPGetRequest()
    }

    let baseURL = "https://jsonplaceholder.typicode.com/users"
    
    func makeHTTPGetRequest() {
        let cfg = URLSessionConfiguration.default
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        
        let session = URLSession(configuration: cfg, delegate: self as? URLSessionDelegate, delegateQueue: queue)
        let request = URL(string: baseURL)
        
        let task = session.dataTask(with: request!)
        task.resume()
    }
    
    func buildJson(){
        let decoder = JSONDecoder()
        users = try? decoder.decode([User].self, from: receivedData)
        
        let mainQueue = DispatchQueue.main
        
        mainQueue.async {
            self.tableView.reloadData()
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if let user = users{
            return user.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        
        cell.textLabel?.text = users?[indexPath.row].username
        cell.detailTextLabel?.text = users?[indexPath.row].name
        return cell
    }

    
    
    
    var receivedData = Data()
    

}

extension UserTableViewController: URLSessionDataDelegate{
     func urlSession(_ session: URLSession,
                             dataTask: URLSessionDataTask,
                             didReceive data: Data){
        self.receivedData.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil{
                buildJson()
        }
    }
}
