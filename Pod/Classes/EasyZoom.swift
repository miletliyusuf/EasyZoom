/**
 This class provides easy zooming for UIImageViews
 */
import UIKit
import Foundation
import ImageIO

public class EasyZoom: NSObject,UIScrollViewDelegate {
	
	//Instant imageView and ScrollView which will show your image and will make them zoom.
	var instantImageView =  UIImageView()
	var instantScrollView = UIScrollView()
	var instantImage = UIImage()
	var instantView = UIView()
	public var mainView = UIView()
	
	var doubleTapRecognizer:UITapGestureRecognizer
	var singleTapRecognizer:UITapGestureRecognizer
	
	var didDoubleTapped = Bool()
	
	public init(imageView:UIImageView, image:UIImage, superView: UIView) {
		instantView = superView
		instantImageView = imageView
		instantImageView.userInteractionEnabled = true
		instantImage = image
		
		doubleTapRecognizer = UITapGestureRecognizer()
		singleTapRecognizer = UITapGestureRecognizer()
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
		
		instantImage = cropTheImage(instantImage, i_width: instantView.frame.size.width, i_height: instantView.frame.size.height)
		
		//setting instant scrollView frame to user imageView
		instantScrollView.frame = instantView.frame
		instantImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: instantImage.size)

		//setting constraints
		setConstraintsImageAndScroll(instantView)
		
		//setting tap gesture recognizer
		doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "didDoubleTapped:")
		doubleTapRecognizer.numberOfTapsRequired = 2
		doubleTapRecognizer.numberOfTouchesRequired = 1
		instantImageView.addGestureRecognizer(doubleTapRecognizer)
		didDoubleTapped = true
		
		//setting minumum and maximum zoom scale
		setTheZoomScale()
		
		
		//centerizing content
		centerizeContent(instantScrollView, imageView: instantImageView)
	}
	
	func setConstraintsImageAndScroll(superView:UIView) {
		instantScrollView.contentSize = instantImage.size
		
		let viewsDictionary = ["imageView":instantImageView,"scrollView":instantScrollView]
		instantScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
		instantImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		instantScrollView.addSubview(instantImageView)
		superView.addSubview(instantScrollView)
		
		//scrollview constraints
		
		let scrollHCons:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[scrollView]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
		let scrollVCons:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[scrollView]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
		superView.addConstraints(scrollHCons)
		superView.addConstraints(scrollVCons)
		
		instantScrollView.setNeedsLayout()
		instantScrollView.setNeedsDisplay()
		
		//imageView constraints
		let imageViewSize = instantScrollView.frame.size
		let imageViewSizesMetric = ["height":imageViewSize.height,"width":imageViewSize.width]
		let imageViewVCons:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[imageView]", options: NSLayoutFormatOptions(0), metrics: imageViewSizesMetric, views: viewsDictionary)
		let imageViewHCons:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]", options: NSLayoutFormatOptions(0), metrics: imageViewSizesMetric, views: viewsDictionary)
		instantScrollView.addConstraints(imageViewHCons)
		instantScrollView.addConstraints(imageViewVCons)
		
		//fixes image size
		instantImageView.contentMode = .ScaleAspectFit
		instantImageView.image = instantImage
	}
	
	func setTheZoomScale() {
		
		let scrollViewFrame = instantScrollView.frame
		let scaleWidth = scrollViewFrame.size.width / instantScrollView.contentSize.width
		let scaleHeight = scrollViewFrame.size.height / instantScrollView.contentSize.height
		
		let minScale = min(scaleWidth, scaleHeight)
		instantScrollView.minimumZoomScale = minScale
		
		instantScrollView.maximumZoomScale = 1.0
		instantScrollView.zoomScale = minScale
		
	}
	
	/**
		This is for single tap tap to new view which has same features with the normal one
	*/
	public func singleTouchToNewView() {
		singleTapRecognizer = UITapGestureRecognizer(target: self, action: "singleTouchHandler")
		singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
		instantImageView.addGestureRecognizer(singleTapRecognizer)
//		var panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
//		instantScrollView.addGestureRecognizer(panGesture)
	}
	
	func singleTouchHandler() {
		let screenSize:CGRect = UIScreen.mainScreen().bounds.standardizedRect
		var fullSizeView = UIView(frame: screenSize)
		fullSizeView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
		instantImage = cropTheImage(instantImage, i_width: screenSize.width, i_height: screenSize.height)
		mainView.addSubview(fullSizeView)
		setConstraintsImageAndScroll(fullSizeView)
		setTheZoomScale()
		centerizeContent(instantScrollView, imageView: instantImageView)
		instantScrollView.removeGestureRecognizer(singleTapRecognizer)
	}
	
	
//	func panToFullScreenView() {
//		let panToFullScreenRecognizer = UIPanGestureRecognizer(target: self, action: "panToFullScreen:")
//		instantScrollView.addGestureRecognizer(panToFullScreenRecognizer)
//	}
	
//	func panToFullScreen(recognizer:UIPanGestureRecognizer) {
//		let constantFrame:CGRect = instantImageView.frame
//		let translation = recognizer.translationInView(instantView)
//		if let view = recognizer.view {
//			view.center = CGPoint(x: view.center.x + translation.x , y: view.center.y + translation.y)
//			if (view.center.y + instantImageView.bounds.midY > instantView.bounds.midY) {
//				instantView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
//				instantScrollView.zoomScale = 0
//			}
//		}
//		recognizer.setTranslation(CGPointZero, inView: instantView)
//	}
	
	func cropTheImage(sourceImage:UIImage, i_width:CGFloat, i_height:CGFloat) -> UIImage {

//		var oldWidth = sourceImage.size.width
//		var scaleFactor = i_width / oldWidth
//		
//		var newHeight = sourceImage.size.height * scaleFactor
//		var newWidth = oldWidth * scaleFactor
		
		var newHeight = i_width
		var newWidth = i_height
		
		UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
		sourceImage.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
		var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return newImage
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
