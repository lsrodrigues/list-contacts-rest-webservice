//
//  UserTableViewController.swift
//  Aula7
//
//  Created by HC5MAC11 on 21/09/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeHTTPGetRequest()
    }

    let baseURL = "https://jsonplaceholder.typicode.com/users"
    
    func makeHTTPGetRequest() {
        let cfg = URLSessionConfiguration.default
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        
        let session = URLSession(configuration: cfg, delegate: self, delegateQueue: queue)
        let request = URL(string: baseURL)
        
        let task = session.dataTask(with: request!)
        task.resume()
    }
    
    func buildJson(){
        let decoder = JSONDecoder()
        do {
            users = try decoder.decode([User].self, from: receivedData)
        }catch {
            debugPrint(error)
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.name
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
