//
//  ARSLinePorgressProtocols.swift
//  ARSLineProgress
//
//
//

import UIKit

@objc protocol ARSLoader {
	var emptyView: UIView { get }
	var backgroundView: UIView { get }
	@objc optional var outerCircle: CAShapeLayer { get set }
	@objc optional var middleCircle: CAShapeLayer { get set }
	@objc optional var innerCircle: CAShapeLayer { get set }
	@objc optional weak var targetView: UIView? { get set }
}
