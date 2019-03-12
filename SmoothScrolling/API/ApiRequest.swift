//
//  ApiRequest.swift
//  SmoothScrolling
//
//  Created by Mark Wong on 8/3/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import Foundation
import UIKit

/// Network layer to encapsulate the fetch requests for a list of photos and the direct url image.
class ApiRequest: NSObject {
    let baseURI = "https://api.unsplash.com"
    let session = URLSession.shared
    class var sharedInstance: ApiRequest {
        struct Static {
            static let instance: ApiRequest = ApiRequest()
        }
        return Static.instance
    }
    
    
    /// fetchList
    /// Ecapsulated by makeRequest() in ViewController. Makes a request to the photos endpoint. Additional parameters in the uri include page, each page contains 10 photos. The function returns void, however the completion handler does populate the dataSource array (dataSource[[String : Any]]) in the view controller, downcasting where required.
    ///  - Parameters:
    ///     - page: The page listing beginning from 0...N.
    ///     - completionHandler: Receives the incoming json data as [Any] type. The handler then continues to parse the data as [[String : Any]] and populate arrays within the viewcontroller and mainview. The capacity of each json array should be of size 10 [0...9].
    ///     - Return: Void.
    func fetchList(page: Int, completionHandler: @escaping ([Any]) -> Void) -> Void {
        let endPoint = "photos"
        let getListURI = "\(baseURI)/\(endPoint)/?page=\(page)&client_id=\(ApiRequestConstants.clientID)"
        
        guard let url = URL(string: getListURI)  else {
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            guard let dataStr = data else {
                return
            }

            guard let res = response as? HTTPURLResponse else {
                return
            }
            
            
            
            do {
                let json = try JSONSerialization.jsonObject(with: dataStr, options: []) as! [Any]
                completionHandler(json)
            } catch let error {
                print(error)
            }
            
        }
        task.resume()
    }
    
    /// fetchImage
    /// This function takes in the direct url for the chosen quality of the image. There are several different qualities the API offers, this app sticks with the lower quality images (regular, small) for a better performance in network, battery and memory. It's called within the image cell, so when the cell itself scrolls into view, we make a request for the image.
    /// - Parameters:
    ///     - urlString: This is the direct url for the target image
    ///     - completionHandler: Once the image has completed the download, we apply the image to the image cell's UIImageView.image property.
    func fetchImage(url urlString: String, completionHandler: @escaping (UIImage?) -> Void ) {
        guard let url = URL(string: urlString)  else {
            return
        }
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print(error!)
                completionHandler(nil)
                return
            }
            
            let image = UIImage(data:data!)
            
            guard let img = image else {
                print("trouble getting image")
                return
            }
            completionHandler(img)

        }
        task.resume()
    }
}
