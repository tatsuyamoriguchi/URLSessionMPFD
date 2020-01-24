//
//  ViewController.swift
//  URLSessionMPFD
//
//  Created by Tatsuya Moriguchi on 1/23/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import UIKit

typealias Parameters = [String: String]

class ViewController: UIViewController {

    @IBAction func getRequest(_ sender: Any) {

        // if accessing http, allow arbitrary upload/load, App Transport Security
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }

        var request = URLRequest(url: url)
        let boundary = generateBoundary()
        
        request.setValue("multipart/form=data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let dataBody = createDataBody(withParameters: nil, media: nil, boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options:[])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
        
    }
    
    @IBAction func postRequest(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name =\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        // Pass image
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return Data()
    }

}

extension Data {
    // Since you can't append String to Data
    
    // Whatever it is, it's chainging
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
    
    
}
