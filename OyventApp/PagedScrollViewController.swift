//
//  PagedScrollViewController.swift
//  OyventApp
//
//  Created by Mehmet Sen on 8/10/15.
//  Copyright (c) 2015 Oyvent. All rights reserved.
//

import UIKit

class PagedScrollViewController: UIViewController , UIScrollViewDelegate{

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    //var scrollViews: [UIScrollView?] = []
  
    var colors:[UIColor] = [UIColor.redColor(), UIColor.blueColor(), UIColor.greenColor(), UIColor.yellowColor(), UIColor.brownColor()]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1
        pageImages = [UIImage(named:"photo1.png")!,
            UIImage(named:"photo2.png")!,
            UIImage(named:"photo3.png")!,
            UIImage(named:"photo4.png")!,
            UIImage(named:"photo5.png")!]
        
        let pageCount = pageImages.count
        
        // 2
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        // 3
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // 4
//        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        doubleTapRecognizer.numberOfTouchesRequired = 1
//        self.scrollView.addGestureRecognizer(doubleTapRecognizer)
//        
        // 5
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(pageImages.count), pagesScrollViewSize.height)
        
        // 4
        let scrollViewFrame = self.scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        self.scrollView.minimumZoomScale = minScale;
        
        // 5
        self.scrollView.maximumZoomScale = 1.5
        self.scrollView.zoomScale = minScale;
        
         self.scrollView.pagingEnabled = true
        
        // 6
        loadVisiblePages()

     
        
    }
    
    func loadPage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // 1
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode =  UIViewContentMode.ScaleAspectFill
            newPageView.frame = frame
            
            //self.scrollView.contentSize = pageImages[page].size
            self.scrollView.addSubview(newPageView)
            
            // 4
            pageViews[page] = newPageView
            
             //self.centerScrollViewContents()
        }
    }
    
    func purgePage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
        
    }
    
    
    
    func loadVisiblePages() {
        
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for var index = firstPage; index <= lastPage; ++index {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    func centerScrollViewContents() {
        let boundsSize = self.scrollView.bounds.size
        var mImageView: UIImageView = self.pageViews[pageControl.currentPage]!
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
    
//    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
//        // 1
//        let pointInView = recognizer.locationInView(mImageView)
//        
//        // 2
//        var newZoomScale = mScrollView.zoomScale * 1.5
//        newZoomScale = min(newZoomScale, self.scrollView.maximumZoomScale)
//        
//        // 3
//        let scrollViewSize = self.scrollView.bounds.size
//        let w = scrollViewSize.width / newZoomScale
//        let h = scrollViewSize.height / newZoomScale
//        let x = pointInView.x - (w / 2.0)
//        let y = pointInView.y - (h / 2.0)
//        
//        let rectToZoomTo = CGRectMake(x, y, w, h);
//        
//        // 4
//        mScrollView.zoomToRect(rectToZoomTo, animated: true)
//    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?{
        return  self.pageViews[pageControl.currentPage]
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
