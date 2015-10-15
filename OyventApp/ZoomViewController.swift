//
//  ZoomViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 4/1/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class ZoomViewController: UIViewController , UIScrollViewDelegate  {

    @IBOutlet weak var mScrollView: UIScrollView!
    var mImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let photo:Photo = appDelegate.zoomedPhoto!
        let imgURL: NSURL! = NSURL(string: photo.largeImageURL)
        // Download an NSData representation of the image at the URL
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        //let urlConnection: NSURLConnection! = NSURLConnection(request: request, delegate: self)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
            if let noerror = data {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let largeImage:UIImage = UIImage(data: noerror)!
                    
                    // 1
                    //let image = UIImage(named: "oyvent")!
                    self.mImageView = UIImageView(image: largeImage)
                    self.mImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: largeImage.size)
                    self.mScrollView.addSubview(self.mImageView)
                    
                    // 2
                    self.mScrollView.contentSize = largeImage.size
                    
                    // 3
                    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
                    doubleTapRecognizer.numberOfTapsRequired = 2
                    doubleTapRecognizer.numberOfTouchesRequired = 1
                    self.mScrollView.addGestureRecognizer(doubleTapRecognizer)
                    
                    // 4
                    let scrollViewFrame = self.mScrollView.frame
                    let scaleWidth = scrollViewFrame.size.width / self.mScrollView.contentSize.width
                    let scaleHeight = scrollViewFrame.size.height / self.mScrollView.contentSize.height
                    let minScale = min(scaleWidth, scaleHeight);
                    self.mScrollView.minimumZoomScale = minScale;
                    
                    // 5
                    self.mScrollView.maximumZoomScale = 1.0
                    self.mScrollView.zoomScale = minScale;
                    
                    // 6
                    self.centerScrollViewContents()
                    
                }
            }
            else {
                print("Error: \(error!.localizedDescription)", terminator: "")
            }
        })

        
        
       
    }
    
    
    
    
    func centerScrollViewContents() {
        let boundsSize = mScrollView.bounds.size
        var contentsFrame = mImageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        mImageView.frame = contentsFrame
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.locationInView(mImageView)
        
        // 2
        var newZoomScale = mScrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, mScrollView.maximumZoomScale)
        
        // 3
        let scrollViewSize = mScrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        // 4
        mScrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?{
        return mImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        // Insert your save data statements in this function
        print("Insert your save data statements in this function", terminator: "")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.zoomedPhoto = nil
        
    }
    

}
