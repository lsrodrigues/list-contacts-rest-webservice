//
//  UserTableViewController.swift
//  Aula7
//
//  Created by HC5MAC11 on 21/09/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import SystemConfiguration

class UserTableViewController: UITableViewController {

    var users = [User]()
    private var persistentContainer = AppDelegate.persistentContainer
    private var reachability: Reachability?
    private var isInternetAvailable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeHTTPGetRequest()
        
        reachability = Reachability.networkReachabilityForInternetConnection()
        isInternetAvailable = reachability?.currentReachabilityStatus != .notReachable
        
        if reachability?.startNotifier() ?? false {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(reachabilityDidChange(_:)),
                                                   name: ReachabilityDidChangeNotificationName,
                                                   object: nil)
        }
        
        
    }
    
    @objc private func reachabilityDidChange(_ notification: Notification) {
        reachability = notification.object as? Reachability
        isInternetAvailable = reachability?.currentReachabilityStatus != .notReachable
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
    
    func getAll(){
        persistentContainer.performBackgroundTask { [unowned self] (context) in
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            do {
                let retrivedUsers = try context.fetch(fetchRequest)
                for user in retrivedUsers {
                    self.users.append(User(name: user.name!, username:user.username!))
                }
            }catch {
                print("Erro ao recuperar dados! \(error)")
            }
        }
    }
        
    
    func buildJson(){
        let decoder = JSONDecoder()
        do {
            if let reachabilityStatus = Reachability.networkReachabilityForInternetConnection()?.currentReachabilityStatus{
                switch reachabilityStatus{
                    case .notReachable: getAll()
                    case .reachableViaWiFi:  users = try decoder.decode([User].self, from: receivedData)
                    case .reachableViaWWAN:  users = try decoder.decode([User].self, from: receivedData)

                }
            }
        }catch {
            debugPrint(error)
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    
    func saveUser(){
        persistentContainer.performBackgroundTask { [unowned self] (context) in
            let user = UserEntity(context: context)
            
            for oneUser in self.users {
                user.name = oneUser.name
                user.username = oneUser.username
            }
            do {
                try context.save()
            }catch {
                print("Erro ao persistir! \(error)")
            }
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
                saveUser()
        }
    }
}
