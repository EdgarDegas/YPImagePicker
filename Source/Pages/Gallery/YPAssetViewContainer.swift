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
import Photos

/// The container for asset (video or image). It containts the YPGridView and YPAssetZoomableView.
class YPAssetViewContainer: UIView {
    public var zoomableView: YPAssetZoomableView?
    public let grid = YPGridView()
    
    public var allowCropping: Bool = true {
        didSet {
            guard YPConfig.library.allowSwitchingCrop else { return }
            squareCropButton.isHidden = !allowCropping
        }
    }
    
    var cropRatioDidChangeHandler: ((_ ratio: CGFloat) -> Void)?
    
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
        
        var icon: UIImage {
            switch self {
            case .sqaure:
                return YPConfig.icons.cropIconSquare
            case .nonSquare:
                return YPConfig.icons.cropIconNonsquare
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
            
            squareCropButton.setImage(currentCropRatio.icon, for: .normal)
            cropRatioDidChangeHandler?(currentCropRatio.ratio)
        }
    }

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
        
        for sv in subviews {
            if let cv = sv as? YPAssetZoomableView {
                zoomableView = cv
                zoomableView?.myDelegate = self
            }
        }
        
        grid.alpha = 0
        
        let touchDownGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handleTouchDown))
        touchDownGR.minimumPressDuration = 0
        touchDownGR.delegate = self
        addGestureRecognizer(touchDownGR)
        
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
        
        squareCropButton.setImage(currentCropRatio.icon, for: .normal)
        sv(squareCropButton)
        squareCropButton.size(42)
        |-15-squareCropButton
        squareCropButton.Bottom == zoomableView!.Bottom - 15
    }
    
    // MARK: - Square button

    @objc public func squareCropButtonTapped() {
        currentCropRatio = currentCropRatio.opposite
    }
}


// MARK: - ZoomableViewDelegate
extension YPAssetViewContainer: YPAssetZoomableViewDelegate {
    public func ypAssetZoomableViewDidLayoutSubviews(_ zoomableView: YPAssetZoomableView) {
        let newFrame = zoomableView.assetImageView.convert(zoomableView.assetImageView.bounds, to: self)
        
        // update grid position
        grid.frame = frame.intersection(newFrame)
        grid.layoutIfNeeded()
        
        // Update play imageView position - bringing the playImageView from the videoView to assetViewContainer,
        // but the controll for appearing it still in videoView.
        if zoomableView.videoView.playImageView.isDescendant(of: self) == false {
            self.addSubview(zoomableView.videoView.playImageView)
            zoomableView.videoView.playImageView.centerInContainer()
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidZoom() {
        if isShown {
            UIView.animate(withDuration: 0.1) {
                self.grid.alpha = 1
            }
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidEndZooming() {
        UIView.animate(withDuration: 0.3) {
            self.grid.alpha = 0
        }
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
    
    @objc
    private func handleTouchDown(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if isShown {
                UIView.animate(withDuration: 0.1) {
                    self.grid.alpha = 1
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                self.grid.alpha = 0
            }
        default: ()
        }
    }
}
