//
//  FirstViewController.swift
//  vcanus-pillo
//
//  Created by sglee on 15/03/2019.
//  Copyright © 2019 sglee. All rights reserved.
//

import UIKit
//import SystemConfiguration.CaptiveNetwork

class FirstViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate,
    UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var passwd: UITextField!
    @IBOutlet weak var currentMode: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        currentMode.font = [UIFont fontWithName:@"System-Regular" size:14];
        currentMode.textColor = UIColor.black
        currentMode.placeholder = "no connection"
        
        passwd.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        ssidArray.append("000")
        ssidArray.append("111")
//        if let ssid = self.getAllWiFiNameList() {
////            print("SSID: \(ssid)")
//            currentMode.text = ssid
////            networkArray.append(ssid)
//        } else {
//            currentMode.text = "ssid is nill"
//        }
    }
    
    var ssidArray:[String] = []
    
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
    
//    func getAllWiFiNameList() -> String? {
//        var ssid: String?
//        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
//            for interface in interfaces {
//                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
//                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
//                    break
//                }
//            }
//        }
//        return ssid
//    }
    
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
        if let url = URL(string: "http://192.168.1.50:8080/") {
            let urlSession = URLSession.shared
            
            let task = urlSession.dataTask(with: url, completionHandler: {
                (data, response, error) in
                if let nsStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                    let str = String(nsStr) + String(self.i)
                    print(str)
                    self.currentMode.text=str
                    self.i=self.i+1
                    self.currentMode.sendActions(for: .valueChanged)
                }
            })
            task.resume()
        }
    }
}

