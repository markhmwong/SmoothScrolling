//
//  ImageCell.swift
//  SmoothScrolling
//
//  Created by Mark Wong on 8/3/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

enum ImageQuality: String {
    case regular = "regular"
    case small = "small"
}

class ImageCell: UITableViewCell {
    var delegate: MainView?
    var imageCache = NSCache<NSString, UIImage>()
    var sizeCache: [String : CGSize] = [:]
    
    var imgView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .gray
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        return indicator
    }()
    
    var heightConstraint: NSLayoutConstraint!
    var size: CGSize = CGSize()
    
    var data = [String: Any]() {
        didSet {
            fetchImageFromUrl()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellView() {
        addSubview(imgView)
        addSubview(activityIndicator)
        
        imgView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imgView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imgView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        heightAnchor.constraint(equalTo: imgView.widthAnchor, multiplier: 1.5).isActive = true
    }
    
    fileprivate func fetchImageFromUrl() {
        let urlQualityDict = data["urls"] as! [String : Any]
        let imageQualityUrl = urlQualityDict[ImageQuality.regular.rawValue] as! String
        // make request
        let request = ApiRequest.sharedInstance
        
        imgView.image = nil
        
        // check if image exists in cache / nil if it doesn't exist
        if let cachedItem = imageCache.object(forKey: imageQualityUrl as NSString) {
            //exists
            imgView.image = cachedItem
            return
        }
        
        // put images into an array or cache it
        if (imgView.image == nil) {
            request.fetchImage(url: imageQualityUrl) { (image) in
                
                if (image != nil) {
                    DispatchQueue.main.async {
                        
                        self.imgView.image = image
                        if let im = image {
                            self.imageCache.setObject(im, forKey: imageQualityUrl as NSString)
                            let imageSize = self.imgView.image!.size
                            self.sizeCache[imageQualityUrl] = imageSize
                            
                            guard let d = self.delegate else {
                                return
                            }
                            d.addToSizeCache(url: imageQualityUrl, size: imageSize)
                        }
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    
                    //make another request after timeout
                }
            }
        }
    }
}

