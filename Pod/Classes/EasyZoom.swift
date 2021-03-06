/**
 This class provides easy zooming for UIImageViews
 */
import UIKit
import Foundation
import ImageIO

public class EasyZoom: NSObject,UIScrollViewDelegate {
	
	//Instant imageView and ScrollView which will show your image and will make them zoom.
	var instantImageView:UIImageView?
	var instantScrollView:UIScrollView = UIScrollView()
	var instantImage:UIImage?
	var instantView:UIView?
	
	public var mainView = UIView()
	
	var doubleTapRecognizer:UITapGestureRecognizer
	var singleTapRecognizer:UITapGestureRecognizer
	var panGesture:UIPanGestureRecognizer
	var touchBack:UITapGestureRecognizer
	
	var didDoubleTapped:Bool = false
	
	public var fadeOutAnimationTime:NSTimeInterval?
	
	public init(imageView:UIImageView, image:UIImage, superView: UIView) {
		instantView = superView
		instantImageView = imageView
		instantImageView?.userInteractionEnabled = true
		instantImage = image
		
		doubleTapRecognizer = UITapGestureRecognizer()
		singleTapRecognizer = UITapGestureRecognizer()
		panGesture = UIPanGestureRecognizer()
		touchBack = UITapGestureRecognizer()

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
	public func zoomForImageView() -> Void {
		
		//delegating of instant scrollView
		instantScrollView.delegate = self
		
		instantImage = cropTheImage(instantImage!, i_width: instantView!.frame.size.width, i_height: instantView!.frame.size.height)
		
		//setting instant scrollView frame to user imageView
		instantScrollView.frame = instantView!.frame
//		instantImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: instantImage.size)

		//setting constraints
		instantScrollView.contentSize = instantImage!.size
		setTheConstraints(instantImageView!, superView: instantScrollView, hConstraints: "|-[subview]", vConstraints: "|-[subview]")
		setTheConstraints(instantScrollView, superView: instantView!, hConstraints: "|-[subview]-|", vConstraints: "|-[subview]-|")
		instantImageView!.contentMode = .ScaleAspectFit
		instantImageView!.image = instantImage
		
		//setting tap gesture recognizer
		doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "didDoubleTapped:")
		doubleTapRecognizer.numberOfTapsRequired = 2
		doubleTapRecognizer.numberOfTouchesRequired = 1
		instantImageView!.addGestureRecognizer(doubleTapRecognizer)
		//didDoubleTapped = true
		
		//setting minumum and maximum zoom scale
		setTheZoomScale()
		
		//centerizing content
		centerizeContent(instantScrollView, imageView: instantImageView!)
		
		//adding tap gesture recognizer
		singleTouchToNewView()
	}
	
	
	/**
	This function makes image view to return its default view format.
	*/
	func returnDefaultState() {
		
		instantImage = cropTheImage(instantImage!, i_width: instantView!.frame.size.width, i_height: instantView!.frame.size.height)
		
		UIView.animateWithDuration(fadeOutAnimationTime!, animations: { () -> Void in
			self.instantScrollView.frame = self.instantView!.frame
			self.instantImageView!.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.instantImage!.size)
		})
		
//		//setting instant scrollView frame to user imageView
//		instantScrollView.frame = instantView!.frame
//		instantImageView!.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: instantImage!.size)

//		//setting constraints
		instantScrollView.contentSize = instantImage!.size
		setTheConstraints(instantImageView!, superView: instantScrollView, hConstraints: "|-[subview]", vConstraints: "|-[subview]")
		instantImageView!.contentMode = .ScaleAspectFit

//		//centerizing content
		centerizeContent(instantScrollView, imageView: instantImageView!)
		
	}
	
	func setTheZoomScale() {
		
		let scrollViewFrame = instantScrollView.frame
		let scaleWidth = scrollViewFrame.size.width / instantScrollView.contentSize.width
		let scaleHeight = scrollViewFrame.size.height / instantScrollView.contentSize.height
		
		let minScale = min(scaleWidth, scaleHeight)
		instantScrollView.minimumZoomScale = minScale
		
		instantScrollView.maximumZoomScale = 10.0
		instantScrollView.zoomScale = minScale
		
	}
	
	func setTheConstraints(subview:UIView, superView:UIView,hConstraints:String,vConstraints:String) {
		let views:Dictionary = ["subview":subview]
		let imageViewSize = instantScrollView.frame.size
		let imageViewSizesMetric = ["height":imageViewSize.height,"width":imageViewSize.width]
		subview.setTranslatesAutoresizingMaskIntoConstraints(false)
		superView.addSubview(subview)
		let vCons:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:\(vConstraints)", options: NSLayoutFormatOptions(0), metrics: imageViewSizesMetric, views: views)
		let hCons:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:\(hConstraints)", options: NSLayoutFormatOptions(0), metrics: imageViewSizesMetric, views: views)
		superView.addConstraints(vCons)
		superView.addConstraints(hCons)
	}
	
	/**
		This is for single tap tap to new view which has same features with the normal one
	*/
	public func singleTouchToNewView() {
		singleTapRecognizer = UITapGestureRecognizer(target: self, action: "singleTouchHandler")
		singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)

		instantScrollView.addGestureRecognizer(singleTapRecognizer)
	}
	
	func singleTouchHandler() {
		let screenSize:CGRect = UIScreen.mainScreen().bounds.standardizedRect
		var fullSizeView = UIView(frame: screenSize)
		//setting constraints of new full size view
		self.setTheConstraints(fullSizeView, superView: mainView, hConstraints: "|-0-[subview]-0-|", vConstraints: "|-0-[subview]-0-|")
		self.setTheConstraints(instantScrollView, superView: fullSizeView, hConstraints: "|-[subview]-|", vConstraints: "|-[subview]-|")
		self.setTheConstraints(instantImageView!, superView: instantScrollView, hConstraints: "|-[subview]", vConstraints: "|-[subview]")
		
		instantScrollView.setNeedsLayout()
		instantScrollView.setNeedsDisplay()
		
		//adding pan recognizer
		panGesture = UIPanGestureRecognizer(target: self, action: "panToFullScreen:")
		touchBack = UITapGestureRecognizer(target: self, action: "touchBackHandler:")
		instantScrollView.addGestureRecognizer(panGesture)
		instantScrollView.addGestureRecognizer(touchBack)
		
		touchBack.requireGestureRecognizerToFail(doubleTapRecognizer)
	}
	
	/**
	Pan gesture recognizer selector function.
	@param recognizer - UIPanGestureRecognizer
	*/
	func panToFullScreen(recognizer:UIPanGestureRecognizer) {
		let screenBounds:CGRect = UIScreen.mainScreen().bounds
		let constantFrame:CGRect = instantImageView!.frame
		let translation = recognizer.translationInView(instantView!)
		
		switch (recognizer.state) {
		case UIGestureRecognizerState.Began:
			println("pan has begun")
			break;
		case UIGestureRecognizerState.Ended:
			returnDefaultState()
			instantScrollView.removeGestureRecognizer(panGesture)
			instantScrollView.removeGestureRecognizer(touchBack)
			println("pan is ended")
			break;
		case UIGestureRecognizerState.Changed:
			println("pan is changed")
			if let view = recognizer.view {
				view.center = CGPoint(x: view.center.x + translation.x , y: view.center.y + translation.y)
			}
			recognizer.setTranslation(CGPointZero, inView: instantView)
			break;
		case UIGestureRecognizerState.Failed:
			println("failed pan");
			break;
		default:
			println("cancelled pan")
			break;
		}
	}
	
	func touchBackHandler(recognizer:UITapGestureRecognizer) {
		returnDefaultState()
		instantScrollView.removeGestureRecognizer(panGesture)
		instantScrollView.removeGestureRecognizer(touchBack)
	}

	func cropTheImage(sourceImage:UIImage, i_width:CGFloat, i_height:CGFloat) -> UIImage {
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

	public func scrollViewDidZoom(scrollView: UIScrollView) {
		centerizeContent(instantScrollView, imageView: instantImageView!)
	}
	
	public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return instantImageView
	}
	
}
