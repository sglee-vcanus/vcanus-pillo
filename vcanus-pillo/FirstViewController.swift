//
//  FirstViewController.swift
//  vcanus-pillo
//
//  Created by sglee on 15/03/2019.
//  Copyright © 2019 sglee. All rights reserved.
//
import UIKit
import Alamofire
//import SystemConfiguration.CaptiveNetwork

struct SSID : Codable {
    var name: [String]
}

class FirstViewController:
    UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate {

    var ssidArray:[String] = []
//    let url = "http://192.168.1.50:8080/"
    let url = "http://192.168.10.1/"
    
    let requestTimeout: Double = 10
    var selectedNetworkIndex = -1
    var ssid = ""
    @IBOutlet var mode: UITextField!
    @IBOutlet var passwd: UITextField!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        currentMode.font = [UIFont fontWithName:@"System-Regular" size:14];
//        currentMode.textColor = UIColor.black
        mode.placeholder = "no connection"
        
        passwd.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(tableView == self.tableView) {
            return ssidArray.count
//        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        if(tableView == self.tableView) {
            let cell = UITableViewCell(
                style: UITableViewCell.CellStyle.subtitle,
                reuseIdentifier: "TableView")
            cell.textLabel?.text = ssidArray[indexPath.row]
            return cell
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! UITableViewCell
//        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
//        print(cell.textLabel?.text)
        print(indexPath.row)
        self.selectedNetworkIndex = indexPath.row
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -150
    }

    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwd.resignFirstResponder()
        return true
    }
    
    var i = 0
    
    @IBAction func getSsid(_ sender: Any) {
        let headers: HTTPHeaders = [
            //            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Content-Type": "application/json",
            "Accept": "application/json"
            //            "Accept": "text/html"
        ]
        let request = Alamofire.request(
            url, method: .get,
            encoding: URLEncoding.default,
            headers: headers)
        var customRequest:URLRequest = request.request!
        customRequest.timeoutInterval = requestTimeout
        Alamofire.request(customRequest)
            .responseJSON {
                response in
                switch(response.result) {
                case .success(let value):
                    if let ssidArray = value as? NSArray {
                        if(ssidArray.count != 0) {
                            self.ssidArray.removeAll()
                        }
                        let sortedArray = ssidArray.sorted(by: {
                            if let obj0 = $0 as? Dictionary<String, Any> ,
                                let obj1 = $1 as? Dictionary<String, Any> {
                                return obj0["rssi"] as! Int > obj1["rssi"] as! Int
                            }
                            return false
                        })
                        
                        for e in sortedArray {
                            let ssidElement = e as! Dictionary<String, Any>
                            let ssid = ssidElement["ssid"] as! String
                            //                            let rssi = ssidElement["rssi"]
                            self.ssidArray.append(ssid)
                        }
                        self.selectedNetworkIndex = -1
                        self.tableView.reloadData()
                    }
                    break
                case .failure(let error) :
                    print(error)
                    self.showAlert(title: "Error",
                                   message: "Check your network")
                    break
                }
                
                let str = String(self.i)
                self.mode.text = str
                self.i = self.i + 1
            }
    }
    
    @IBAction func connectNetwork(_ sender: Any) {
        let newUrl = url + "mode/"
        let passwd: String? = self.passwd.text
        if(passwd==nil) {
            return
        }
        if(self.selectedNetworkIndex != -1) {
            ssid = self.ssidArray[self.selectedNetworkIndex]
        }
        let parameters = [
            "type": "WIFI_STA",
            "ssid": ssid,
            "passwd" : passwd!
        ]
        let request = Alamofire.request(
            newUrl, method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default)
        var customRequest:URLRequest = request.request!
        customRequest.timeoutInterval = requestTimeout
        Alamofire.request(customRequest)
            .responseJSON {
                response in
                print(".responseJSON")
                switch(response.result) {
                case .success(let value):
                    print(value)
                    break
                case .failure(let error):
                    print(error)
                    self.showAlert(title: "Error",
                                   message: "Check your network")
                    break
                }
            }
            .responseString {
                response in
                print(".responseString")
                switch(response.result) {
                case .success(let value):
                    print(value)
                    break
                case .failure(let error):
                    print(error)
                    self.showAlert(title: "Error",
                                   message: "Check your network")
                    break
                }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: title,
                               style: .default) {
                                ok in
        }
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func disconnectNetwork(_ sender: Any) {
        let newUrl = url + "mode/"
        let passwd: String? = self.passwd.text
        if(passwd==nil) {
            return
        }
        let parameters = [
            "type": "WIFI_AP",
            "ssid": ssid,
            "passwd" : passwd!
        ]
        let request = Alamofire.request(
            newUrl, method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default)
        var customRequest:URLRequest = request.request!
        customRequest.timeoutInterval = requestTimeout
        Alamofire.request(customRequest)
            .responseJSON {
                response in
                print(".responseJSON")
                switch(response.result) {
                case .success(let value):
                    print(value)
                    break
                case .failure(let error):
                    print(error)
                    self.showAlert(title: "Error",
                              message: "Check your network")
                    break
                }
            }
            .responseString {
                response in
                print(".responseString")
                switch(response.result) {
                case .success(let value):
                    print(value)
                    break
                case .failure(let error):
                    print(error)
                    self.showAlert(title: "Error",
                              message: "Check your network")
                    break
                }
        }
    }
}

