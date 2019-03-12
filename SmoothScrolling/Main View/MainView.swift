//
//  MainView.swift
//  SmoothScrolling
//
//  Created by Mark Wong on 8/3/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class MainView: UIView {
    let cellId = "imageCellId"
    var dataSource = [[String : Any]]()
    var delegate: ViewController?
    
    //To be use for dynamic cell height.
    var imageDataSource = [UIImage]()
    var sizeCache: [String : CGSize] = [:]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupView()
        self.setupAutoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(tableView)
        tableView.register(ImageCell.self, forCellReuseIdentifier: cellId)
        tableView.estimatedRowHeight = 400.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupAutoLayout() {
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func insertDataTo(source: [[String : Any]]) {
        DispatchQueue.main.async {
            self.dataSource = source
            self.tableView.reloadData()
        }
        
    }
    
    func addToSizeCache(url: String, size: CGSize) {
        sizeCache[url] = size
    }
}

extension MainView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == dataSource.count - 1) {
            let pageNumber = (dataSource.count / 10) + 1
            delegate?.makeRequest(pageNumber: pageNumber)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageCell
        cell.data = dataSource[indexPath.row]
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400.0
    }
}
