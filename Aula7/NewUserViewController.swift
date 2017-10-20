//
//  NewUserViewController.swift
//  Aula7
//
//  Created by HC5MAC12 on 05/10/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import UIKit
import CoreData

class NewUserViewController: UITableViewController {


    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var siteField: UITextField!
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        self.saveCoreData()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    private var viewContext = AppDelegate.viewContext
    
    var configuration: URLSessionConfiguration {
        let cfg = URLSessionConfiguration.default
        cfg.networkServiceType = .default
        return cfg
    }
    
    var operationQueue: OperationQueue {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 5
        return queue
    }
    
    private var session: URLSession {
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        return session
    }
    
    private func saveCoreData() {
        let user = UserEntity(context: viewContext)
        user.id = Int32(arc4random() % (arc4random() % 100))
        user.name = nameField.text
        user.username = loginField.text
        user.email = emailField.text
        //user.address = AddressEntity(context: viewContext)
        //user.address?.street = streetTextField.text
        //user.address?.suite = suiteTextField.text
        //user.address?.city = cityTextField.text
        //user.address?.zipcode = zipcodeTextField.text
        user.phone = phoneField.text
        user.website = siteField.text
        //user.company = CompanyEntity(context: viewContext)
        //user.company?.name = companyNameTextField.text
        //user.company?.catchPhrase = catchPhraseTextField.text
        //user.company?.bs = bsTextField.text
        
        do {
            try viewContext.save()
            DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
                self.postJSON(user)
            }
        }catch {
            debugPrint(error)
        }
    }
    
    private func postJSON(_ coreDataUser: UserEntity) {
        let user = User(id: coreDataUser.id,
                        name: coreDataUser.name!,
                        username: coreDataUser.username!,
                        email: coreDataUser.email!,
//                        address: Address(street: coreDataUser.address!.street!,
//                                         suite: coreDataUser.address!.suite!,
//                                         city: coreDataUser.address!.city!,
//                                         zipcode: coreDataUser.address!.zipcode!,
//                                         geo: Geo(lat: coreDataUser.address!.geo!.lat!,
//                                                  lng: coreDataUser.address!.geo!.lng!)),
                        phone: coreDataUser.phone!,
                        website: coreDataUser.website!)
//                        company: Company(name: coreDataUser.company!.name!,
//                                         catchPhrase: coreDataUser.company!.catchPhrase!,
//                                         bs: coreDataUser.company!.bs!))
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(user)
            
            if let url = URL(string: "https://jsonplaceholder.typicode.com/users") {
                var request = URLRequest(url:url)
                request.httpMethod = "POST"
                request.timeoutInterval = 10
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let dataTask = session.dataTask(with: request)
                dataTask.resume()
            }
        }catch {
            debugPrint(error)
        }
    }
}


extension NewUserViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let response = task.response as? HTTPURLResponse, response.statusCode == 201 {
            print("201 Criado")
            DispatchQueue.main.async { [unowned self] in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

