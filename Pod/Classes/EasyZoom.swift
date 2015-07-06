/**
 This class provides easy zooming for UIImageViews
 */
import UIKit
import Foundation

public class EasyZoom: NSObject,UIScrollViewDelegate {
	
	//Instant imageView and ScrollView which will show your image and will make them zoom.
	var instantImageView =  UIImageView()
	var instantScrollView = UIScrollView()
	var instantImage = UIImage()
	var instantView = UIView()
	public var mainView = UIView()
	
	var doubleTapRecognizer:UITapGestureRecognizer
	
	var didDoubleTapped = Bool()
	
	public init(imageView:UIImageView, image:UIImage, superView: UIView) {
		instantView = superView
		instantImageView = imageView
		instantImage = image
		doubleTapRecognizer = UITapGestureRecognizer()
		
		//scroll visible
		instantScrollView.showsHorizontalScrollIndicator = false
		instantScrollView.showsVerticalScrollIndicator = false

	}
	
	/**
		This public function adds zoom for imageViews.
	 @param imageView: UIImageView - The imageView where you can place zoom
	 @param image: UIImage - The image of imageView
	 @param superView: UIView - The superView which gonna cover zoomed imageView
	 */
	public func zoomForImageView() ->Void {
		
		//delegating of instant scrollView
		instantScrollView.delegate = self
		
		
		//setting instant scrollView frame to user imageView
		instantScrollView.frame = instantView.frame
		instantImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: instantImage.size)

		//setting zoom area
		instantScrollView.contentSize = instantImage.size
		
		let viewsDictionary = ["imageView":instantImageView,"scrollView":instantScrollView]
		instantScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
		instantImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		instantImageView.image = instantImage
		
		instantScrollView.addSubview(instantImageView)
		instantView.addSubview(instantScrollView)

		//scrollview constraints
		
		let scrollHCons:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[scrollView]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
		let scrollVCons:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[scrollView]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
		instantView.addConstraints(scrollHCons)
		instantView.addConstraints(scrollVCons)
		
		instantScrollView.setNeedsLayout()
		instantScrollView.setNeedsDisplay()
		
		//imageView constraints
		
		let imageViewSize = instantScrollView.frame.size
		let imageViewSizesMetric = ["height":imageViewSize.height,"width":imageViewSize.width]
		let imageViewVCons:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[imageView]", options: NSLayoutFormatOptions(0), metrics: imageViewSizesMetric, views: viewsDictionary)
		let imageViewHCons:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView(width)]", options: NSLayoutFormatOptions(0), metrics: imageViewSizesMetric, views: viewsDictionary)
		instantScrollView.addConstraints(imageViewHCons)
		instantScrollView.addConstraints(imageViewVCons)

		//fixes image size
		instantImageView.contentMode = UIViewContentMode.ScaleAspectFill
		
		//setting tap gesture recognizer
		doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "didDoubleTapped:")
		doubleTapRecognizer.numberOfTapsRequired = 2
		doubleTapRecognizer.numberOfTouchesRequired = 1
		instantScrollView.addGestureRecognizer(doubleTapRecognizer)
		didDoubleTapped = true
		
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
		This is for single tap tap to new view which has same features with the normal one
	*/
	public func singleTouchToNewView() {
		let singleTapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTouchHandler")
		singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
		instantScrollView.addGestureRecognizer(singleTapRecognizer)
		
		var panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
		instantScrollView.addGestureRecognizer(panGesture)
	}
	
	func singleTouchHandler() {
		let screenSize:CGRect = UIScreen.mainScreen().bounds
		var fullSizeView = UIView(frame: screenSize)
		fullSizeView.backgroundColor = UIColor.blueColor()
		mainView.addSubview(fullSizeView)
		fullSizeView.addSubview(instantView)
	}
	
	
	func panToFullScreenView() {
		let panToFullScreenRecognizer = UIPanGestureRecognizer(target: self, action: "panToFullScreen:")
		instantScrollView.addGestureRecognizer(panToFullScreenRecognizer)
	}
	
	func panToFullScreen(recognizer:UIPanGestureRecognizer) {
		let constantFrame:CGRect = instantImageView.frame
		let translation = recognizer.translationInView(instantView)
		if let view = recognizer.view {
			view.center = CGPoint(x: view.center.x + translation.x , y: view.center.y + translation.y)
			if (view.center.y + instantImageView.bounds.midY > instantView.bounds.midY) {
				instantView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
				instantScrollView.zoomScale = 0
			}
		}
		recognizer.setTranslation(CGPointZero, inView: instantView)
	}
	
	/**
	 Centerizing content.
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
	 NSNotification handler method. This methods recognize user tap area and zoom over there.
	 @param recognizer - UITapGestureRecognizer
	 */
	func didDoubleTapped (recognizer:UITapGestureRecognizer) {
		
		if (didDoubleTapped == true) {
			let pointInView = recognizer.locationInView(instantImageView)
			
			var newZoomScale = instantScrollView.zoomScale * 3.5
			newZoomScale = min(newZoomScale, instantScrollView.maximumZoomScale)
			
			let scrollViewSize = instantScrollView.bounds.size
			let w = scrollViewSize.width / newZoomScale
			let h = scrollViewSize.height / newZoomScale
			let x = pointInView.x - (w / 2.0)
			let y = pointInView.y - (h / 2.0)
			
			let rectToZoomTo = CGRectMake(x,y, w, h)
			
			instantScrollView.zoomToRect(rectToZoomTo, animated: true)
			didDoubleTapped = false
		}
		else {
			instantScrollView.zoomScale = 0;
			didDoubleTapped = true
		}
		
	}
	
	//pragma mark UIScrollView Delegate Methods
	public func scrollViewDidZoom(scrollView: UIScrollView) {
		centerizeContent(instantScrollView, imageView: instantImageView)
//		didDoubleTapped = false
	}
	
	public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return instantImageView
	}
	
}
