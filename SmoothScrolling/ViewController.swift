//
//  ViewController.swift
//  SmoothScrolling
//
//  Created by Mark Wong on 8/3/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

/*
 
 Using Unsplash's API to scroll through random photos.
 
*/

import UIKit

class ViewController: UIViewController {
    var apiRequest: ApiRequest?
    var dataSource: [[String : Any]] = [[String : Any]]() //moved to imagecell
    var isFetchInProgress: Bool = false
    
    fileprivate lazy var mainView: MainView = {
       let view = MainView(frame: .zero)
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(shared: ApiRequest) {
        self.init(nibName: nil, bundle: nil)
        self.apiRequest = shared
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mainView)

        mainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        makeRequest(pageNumber: 0, reload: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func makeRequest(pageNumber: Int = 0, reload: Bool = false) {
        guard let api = apiRequest else {
            return
        }
        
        if isFetchInProgress == true {
            //
        } else {
            isFetchInProgress = true
            api.fetchList(page: pageNumber) { (response) in
                for item in response {
                    let dict: [String : Any] = item as! [String : Any]
                    self.dataSource.append(dict)
                }
                
                self.isFetchInProgress = false
                self.mainView.insertDataTo(source: self.dataSource, pageNumber: pageNumber) //performs a tableview reload within this function
            }
        }
    }
}

