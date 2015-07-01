/**
 This class provides easy zooming for UIImageViews
 */
import UIKit
import Foundation

public class EasyZoom: NSObject,UIScrollViewDelegate {
	
	//Instant imageView and ScrollView which will show your image and will make them zoom.
	var instantImageView =  UIImageView()
	var instantScrollView = UIScrollView()
	
	/**
		This public function adds zoom for imageViews.
	 @param imageView: UIImageView - The imageView where you can place zoom
	 @param image: UIImage - The image of imageView
	 @param superView: UIView - The superView which gonna cover zoomed imageView
	 */
	public func zoomForImageView(imageView:UIImageView, image:UIImage, superView:UIView) {
		
		//delegating of instant scrollView
		instantScrollView.delegate = self
		//setting instant scrollView frame to user imageView
		instantScrollView.frame = superView.frame
		imageView.removeFromSuperview()
		instantImageView.image = image
		instantImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
		instantScrollView.addSubview(instantImageView)
		
		superView.addSubview(instantScrollView)
		
		instantScrollView.contentSize = image.size
		
		//setting tap gesture recognizer
		var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "didDoubleTapped:")
		doubleTapRecognizer.numberOfTapsRequired = 2
		doubleTapRecognizer.numberOfTouchesRequired = 1
		instantScrollView.addGestureRecognizer(doubleTapRecognizer)
		
		
		//setting minumum and maximum zoom scale
		let scrollViewFrame = instantScrollView.frame
		let scaleWidth = scrollViewFrame.size.width / instantScrollView.contentSize.width
		let scaleHeight = scrollViewFrame.size.height / instantScrollView.contentSize.height
		let minScale = min(scaleWidth, scaleHeight)
		instantScrollView.minimumZoomScale = minScale
		
		instantScrollView.maximumZoomScale = 1.0
		instantScrollView.zoomScale = minScale
	
		//centerizing content
		centerizeContent(instantScrollView, imageView: instantImageView)
	}
	/**
	 Centerizing content in this instance method.
	 @param scrollView - UIScrollView
	 @param imageView - UIImageView
	 */
	func centerizeContent(scrollView:UIScrollView, imageView:UIImageView) {
		let boundSize = scrollView.bounds.size
		var contentsFrame = imageView.frame
		
		if contentsFrame.size.width < boundSize.width {
			contentsFrame.origin.x = (boundSize.width - contentsFrame.size.width) / 2.0
		}
		else {
			contentsFrame.origin.x = 0.0
		}
		if contentsFrame.size.height < boundSize.height {
			contentsFrame.origin.y = (boundSize.height - contentsFrame.size.height) / 2.0
		}
		else {
			contentsFrame.origin.y = 0.0
		}
		
		imageView.frame = contentsFrame
	}
	
	/**
	 NSNotification handler method.
	 @param recognizer - UITapGestureRecognizer
	 */
	func didDoubleTapped (recognizer:UITapGestureRecognizer) {

		let pointInView = recognizer.locationInView(instantImageView)
		
		var newZoomScale = instantScrollView.zoomScale * 1.5
		newZoomScale = min(newZoomScale, instantScrollView.maximumZoomScale)
		
		let scrollViewSize = instantScrollView.bounds.size
		let w = scrollViewSize.width / newZoomScale
		let h = scrollViewSize.height / newZoomScale
		let x = pointInView.x - (w / 2.0)
		let y = pointInView.y - (h / 2.0)
		
		let rectToZoomTo = CGRectMake(x,y, w, h)
		
		instantScrollView.zoomToRect(rectToZoomTo, animated: true)
	}
	
	//pragma mark UIScrollView Delegate Methods
	public func scrollViewDidZoom(scrollView: UIScrollView) {
		centerizeContent(instantScrollView, imageView: instantImageView)
	}
	
	public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return instantImageView
	}
	
}
