//
//  ViewController.swift
//  TerraiOSDemo
//
//  Created by Elliott Yu on 12/05/2022.
//

import UIKit
import TerraiOS
import WebKit
import Foundation
import HealthKit

struct TerraWidgetSessionCreateResponse:Decodable{
    var status: String = String()
    var url: String = String()
    var session_id: String = String()
}

struct TerraAuthTokenCreateResponse: Decodable{
    var expires_in: Int = Int()
    var status: String = String()
    var token: String = String()
}
    

extension Date {
    static func todayAt12AM(date: Date) -> Date{
        return Calendar(identifier: .iso8601).startOfDay(for: date)
    }
}

/**
 Function to generate a widget session.
 **Please Generate this in the backend. This is for demo only!!!!!**
 */
func getSessionId() -> String{
    let session_url = URL(string: "https://api.tryterra.co/v2/auth/generateWidgetSession")
    var url = ""
    var request = URLRequest(url: session_url!)
    let requestData = ["reference_id": "testing", "language": "EN"]
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "widget.Terra")
    let jsonData = try? JSONSerialization.data(withJSONObject: requestData)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(DEVID, forHTTPHeaderField: "dev-id")
    request.setValue(XAPIKEY, forHTTPHeaderField: "X-API-Key")
    request.httpBody = jsonData
    let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
        if let data = data{
            let decoder = JSONDecoder()
            do{
                let result = try decoder.decode(TerraWidgetSessionCreateResponse.self, from: data)
                url = result.url
                group.leave()
            }
            catch{
                print(error)
            }
        }
    }
    group.enter()
    queue.async(group:group) {
        task.resume()
    }
    group.wait()
    return url
}

/**
 *Generate an auth token
 **Please Generate this in the backend. This is for demo only!!!!!**
 */
func generateAuthToken() -> String{
    let session_url = URL(string: "https://api.tryterra.co/v2/auth/generateAuthToken")
    var token = ""
    var request = URLRequest(url: session_url!)
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "auth.Terra")
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(DEVID, forHTTPHeaderField: "dev-id")
    request.setValue(XAPIKEY, forHTTPHeaderField: "X-API-Key")
    let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
        if let data = data{
            let decoder = JSONDecoder()
            do{
                let result = try decoder.decode(TerraAuthTokenCreateResponse.self, from: data)
                token = result.token
                group.leave()
            }
            catch{
                print(error)
            }
        }
    }
    group.enter()
    queue.async(group:group) {
        task.resume()
    }
    group.wait()
    return token
}
var terraClient: Terra? = nil
var authResponse: TerraAuthResponse? = nil

class ViewController: UIViewController {

    var activityDate = Date.todayAt12AM(date: Date())
    var bodyDate = Date.todayAt12AM(date: Date())
    var dailyDate = Date.todayAt12AM(date: Date())
    var sleepDate = Date.todayAt12AM(date: Date())

    
    @IBOutlet weak var connect:UIButton!
    
    @IBOutlet weak var readGlucose:UIButton!

    
    @IBOutlet weak var disconnect:UIButton!

    @IBOutlet weak var athlete:UIButton!
    
    @IBOutlet weak var body:UIButton!

    @IBOutlet weak var daily:UIButton!

    @IBOutlet weak var sleep:UIButton!
    
    @IBOutlet weak var activity:UIButton!
        
    @IBOutlet weak var activityDatePicker: UIDatePicker!
    
    @IBOutlet weak var sleepDatePicker: UIDatePicker!

    @IBOutlet weak var bodyDatePicker: UIDatePicker!

    @IBOutlet weak var dailyDatePicker: UIDatePicker!

    @IBOutlet weak var buttonContainer1: UIView!
    @IBOutlet weak var buttonContainer2: UIView!
    @IBOutlet weak var buttonContainer3: UIView!
    @IBOutlet weak var buttonContainer4: UIView!
    @IBOutlet weak var buttonContainer5: UIView!
    @IBOutlet weak var buttonContainer6: UIView!
    @IBOutlet weak var buttonContainer7: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityDatePicker.setValue(UIColor.white, forKeyPath: "textColor")
        activityDatePicker.overrideUserInterfaceStyle = .dark

        bodyDatePicker.setValue(UIColor.white, forKeyPath: "textColor")
        bodyDatePicker.overrideUserInterfaceStyle = .dark
    
        sleepDatePicker.setValue(UIColor.white, forKeyPath: "textColor")
        sleepDatePicker.overrideUserInterfaceStyle = .dark
    
        dailyDatePicker.setValue(UIColor.white, forKeyPath: "textColor")
        dailyDatePicker.overrideUserInterfaceStyle = .dark

        buttonContainer1.layer.cornerRadius = 20
        buttonContainer2.layer.cornerRadius = 20
        buttonContainer3.layer.cornerRadius = 20
        buttonContainer4.layer.cornerRadius = 20
        buttonContainer5.layer.cornerRadius = 20
        buttonContainer6.layer.cornerRadius = 20
        buttonContainer7.layer.cornerRadius = 20
        readGlucose.layer.cornerRadius = 10
        readGlucose.setTitle("Glucose", for: .normal)
        connect.layer.cornerRadius = 10
        connect.setTitle("Connect", for: .normal)
        athlete.layer.cornerRadius = 10
        athlete.setTitle("Athlete", for: .normal)
        body.layer.cornerRadius = 10
        body.setTitle("Body", for: .normal)
        daily.layer.cornerRadius = 10
        daily.setTitle("Daily", for: .normal)
        sleep.layer.cornerRadius = 10
        sleep.setTitle("Sleep", for: .normal)
        activity.layer.cornerRadius = 10
        activity.setTitle("Activity", for: .normal)
        disconnect.layer.cornerRadius = 10
        disconnect.setTitle("Disconnect", for: .normal)
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func athleteAction(_ sender: UIButton){
        terraClient?.getAthlete(type: .APPLE_HEALTH){(success, data) -> Void in
            print("Done function")
            print(data)
        }
    }

    @IBAction func bodyAction(_ sender: UIButton){
        terraClient?.getBody(type: .APPLE_HEALTH, startDate: bodyDate, endDate: bodyDate.addingTimeInterval(86400)){(success, data) -> Void in
            print("Done function")
            print(data)
        }
    }

    @IBAction func dailyAction(_ sender: UIButton){
        terraClient?.getDaily(type: .APPLE_HEALTH, startDate: Date().addingTimeInterval(-86400), endDate: Date()){(success, data) -> Void in
            print("Done function")
            print(data)
        }
    }

    @IBAction func sleepAction(_ sender: UIButton){
        terraClient?.getSleep(type: .APPLE_HEALTH, startDate: sleepDate, endDate: sleepDate.addingTimeInterval(86400)){(success, data) -> Void in
            print("Done function")
            print(data)
        }
    }

    @IBAction func activityAction(_ sender: UIButton){
        terraClient?.getActivity(type: .APPLE_HEALTH, startDate: activityDate, endDate: activityDate.addingTimeInterval(86400)){(success, data) -> Void in
            print("Done function")
            print(data)
        }
    }

    @IBAction func readGlucose(_ sender: UIButton){
        try! terraClient?.readGlucoseData()
    }

    @IBAction func connectAction(){
    //        let vc = (self.storyboard?.instantiateViewController(withIdentifier:"WebViewController"))
    //        self.navigationController?.pushViewController(vc!, animated: true)
    //        let vc = UIStoryboard.init(name: "Main", bundle:
        performSegue(withIdentifier: "PresentWebView", sender: nil)
    }
    
    @IBAction func activityDateChange(_ sender: UIDatePicker){
        activityDate = sender.date
    }
    @IBAction func bodyDateChange(_ sender: UIDatePicker){
        bodyDate = sender.date
    }
    @IBAction func sleepDateChange(_ sender: UIDatePicker){
        sleepDate = sender.date
    }
    @IBAction func dailyDateChange(_ sender: UIDatePicker){
        dailyDate = sender.date
    }
    
//    //This will get you a user_id and an authentication URL for which you will need to show to your user for auth.
//    //The url is on fitbit's end and after completion, you can use the user_id to get data.
//    var terraAuthClient = TerraAuthClient(devId: <#T##String#>, xAPIKey: <#T##String#>).authenticateUser(resource: <#T##String#>)
//
//    
//    //Insert the user ID here from step before
//    var terra = TerraClient(userId: <#T##String#>, devId: <#T##String#>, xAPIKey: <#T##String#>)
//    ... terra.getActivity()
}


class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 400), configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        var myURL: URL!
        myURL = URL(string: getSessionId())
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
             if let urlStr = navigationAction.request.url?.absoluteString {
                 print(urlStr)
                 if urlStr.contains("success?resource=apple") {
                     webView.stopLoading()
                     let terraClient = Terra(devId: "DEV_ID", referenceId: "REFERENCE_ID", bodyTimer: 60, dailyTimer: 60, nutritionTimer: 60, sleepTimer: 60)
                     
                     terraClient.initConnection(type: Connections.APPLE_HEALTH, token: "TOKEN", permissions: Set([Permissions.NUTRITION, Permissions.ACTIVITY, Permissions.ATHLETE, Permissions.SLEEP, Permissions.BODY, Permissions.DAILY]), schedulerOn: false){success in
                        
                         terraClient?.getDaily(type: .APPLE_HEALTH, startDate: Date().addingTimeInterval(-86400), endDate: Date()){(success, data) in
                             print(data)
                         }
                     }
                     
                     terraClient?.initConnection(type: .FREESTYLE_LIBRE, token: generateAuthToken())
                     

                     self.dismiss(animated: true, completion: nil)
                     webView.removeFromSuperview()
                 }
             }
            decisionHandler(.allow)
        }

}

