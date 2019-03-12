# Smooth Scrolling iOS Project

A small project exploring the asynchronous behavior of URLSession with a UITableView. It uses unsplash.com's awesome API to make URL requests for it's data source. 

## Current Features
- Asynchronous loading via network
- Request to an external API
- Caching Images
- Infinite Scrolling
- Request for data when cell scrolls into view

## Structure

- ViewController (Root)
  - Main View
    - Table View
      - Image Cell
      	- Activity Indicator
	- Image View
	- Cache
- ApiRequest (Singleton)

## Data

There is no persistant store. All the images are streamed to the device. You'll find that there are two main data points for temporary store. 

- ViewController
  - Main View (dataSource)
    - Table View
      - Image Cell (imageCache)

## Network Requests

One network call occurs on start up once the main view has loaded and been displayed in the View Controller method viewDidLoad(). Unsplash's API allows to grab a list of photos allows for 10 images with their respective data. The key value pair I'm currently interested in is the urls key within the JSON response. This is extracted in the Image Cell by a following network request for a single image only if the image hasn't previously been downloaded.

In summary there are two main network requests
   - One called after the view controller's main view is loaded
   - The other is called by each cell if an image does not exists in the cache (imageCache)

## Preview (Video)

![Smooth Scrolling App Video](./SmoothScrolling_Video.GIF)

