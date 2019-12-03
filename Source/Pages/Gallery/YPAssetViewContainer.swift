//
//  YPAssetViewContainer.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import UIKit
import Stevia
import AVFoundation

/// The container for asset (video or image). It containts the YPAssetZoomableView.
public class YPAssetViewContainer: UIView {
    
    public var allowCropping: Bool = true {
        didSet {
            guard YPConfig.library.allowSwitchingCrop else { return }
            squareCropButton.isHidden = !allowCropping
        }
    }
    
    public enum CropRatio {
        case sqaure
        case nonSquare
        
        var ratio: CGFloat {
            switch self {
            case .sqaure:
                return 1
            case .nonSquare:
                return YPConfig.library.nonSquareCropRatio ?? 1
            }
        }
        
        var opposite: Self {
            switch self {
            case .sqaure:
                return .nonSquare
            case .nonSquare:
                return .sqaure
            }
        }
    }
    
    public var currentCropRatio: CropRatio = {
        if YPConfig.library.useSquareCropAsDefault {
            return .sqaure
        } else {
            return .nonSquare
        }
    }() {
        didSet {
            previewView?.cropRatio = currentCropRatio.ratio
        }
    }
    
    public var previewView: AssetPreviewView?
    public let curtain = UIView()
    public let spinnerView = UIView()
    public let squareCropButton = UIButton()
    public var isShown = true
    
    private let spinner = UIActivityIndicatorView(style: .white)
    private var shouldCropToSquare = YPConfig.library.isSquareByDefault
    private var isMultipleSelection = true

    override public func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        
        if let previewView = subviews.first(where: { $0 is AssetPreviewView }) {
            self.previewView = previewView as? AssetPreviewView
        }
        
        // TODO: Add tap gesture to play/pause. Add double tap gesture to square/unsquare
        
        sv(
            spinnerView.sv(
                spinner
            ),
            curtain
        )
        
        spinner.centerInContainer()
        spinnerView.fillContainer()
        curtain.fillContainer()
        
        spinner.startAnimating()
        spinnerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        curtain.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        curtain.alpha = 0
        
        // Crop Button
        squareCropButton.setImage(YPConfig.icons.cropIcon, for: .normal)
        sv(squareCropButton)
        squareCropButton.size(42)
        |-15-squareCropButton
        squareCropButton.Bottom == previewView!.Bottom - 15
    }
    
    // MARK: - Square button

    @objc public func squareCropButtonTapped() {
        currentCropRatio = currentCropRatio.opposite
    }
}


// MARK: - Gesture recognizer Delegate
extension YPAssetViewContainer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIButton)
    }
}
