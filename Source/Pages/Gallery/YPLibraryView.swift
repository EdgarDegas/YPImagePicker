//
//  YPLibraryView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia
import Photos

final class YPLibraryView: UIView {

    let assetZoomableViewMinimalVisibleHeight: CGFloat  = 50
    
    public var nonSquareCropRatio: CGFloat = 1
    
    var currentCropRatio: CropRatio = {
        if YPConfig.library.useSquareCropAsDefault {
            return .square
        } else {
            return .nonSquare
        }
    }() {
        didSet {
            assetViewContainer.squareCropButton.setImage(currentCropRatio.icon, for: .normal)
            handleCropRatioChange(into: currentCropRatio)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var assetZoomableView: YPAssetZoomableView!
    @IBOutlet weak var assetViewContainer: YPAssetViewContainer!
    @IBOutlet weak var assetViewContainerConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var zoomableViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet var zoomableViewEqualWidthConstraint: NSLayoutConstraint!
    @IBOutlet var zoomableViewEqualHeightConstraint: NSLayoutConstraint!
    
    let maxNumberWarningView = UIView()
    let maxNumberWarningLabel = UILabel()
    let progressView = UIProgressView()
    let line = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sv(
            line
        )
        
        layout(
            assetViewContainer!,
            |line| ~ 1
        )
        
        line.backgroundColor = YPConfig.colors.libraryScreenBackgroundColor
        
        setupMaxNumberOfItemsView()
        setupProgressBarView()
        assetViewContainer.squareCropButton.setImage(currentCropRatio.icon, for: .normal)
        assetViewContainer.backgroundColor = YPConfig.colors.libraryScreenBackgroundColor
    }
    
    /// At the bottom there is a view that is visible when selected a limit of items with multiple selection
    func setupMaxNumberOfItemsView() {
        // View Hierarchy
        sv(
            maxNumberWarningView.sv(
                maxNumberWarningLabel
            )
        )
        
        // Layout
        |maxNumberWarningView|.bottom(0)
        if #available(iOS 11.0, *) {
            maxNumberWarningView.Top == safeAreaLayoutGuide.Bottom - 40
            maxNumberWarningLabel.centerHorizontally().top(11)
        } else {
            maxNumberWarningView.height(40)
            maxNumberWarningLabel.centerInContainer()
        }
        
        // Style
        maxNumberWarningView.backgroundColor = YPConfig.colors.libraryScreenBackgroundColor
        maxNumberWarningLabel.font = UIFont(name: "Helvetica Neue", size: 14)
        maxNumberWarningLabel.textColor = YPConfig.colors.tintColor
        maxNumberWarningView.isHidden = true
    }
    
    /// When video is processing this bar appears
    func setupProgressBarView() {
        sv(
            progressView
        )
        
        progressView.height(5)
        progressView.Top == line.Top
        progressView.Width == line.Width
        progressView.progressViewStyle = .bar
        progressView.trackTintColor = YPConfig.colors.progressBarTrackColor
        progressView.progressTintColor = YPConfig.colors.progressBarCompletedColor ?? YPConfig.colors.tintColor
        progressView.isHidden = true
        progressView.isUserInteractionEnabled = false
    }
}

// MARK: - UI Helpers

extension YPLibraryView {
    
    class func xibView() -> YPLibraryView? {
        let bundle = Bundle(for: YPPickerVC.self)
        let nib = UINib(nibName: "YPLibraryView",
                        bundle: bundle)
        let xibView = nib.instantiate(withOwner: self, options: nil)[0] as? YPLibraryView
        return xibView
    }
    
    // MARK: - Grid
    
    func hideGrid() {
        assetViewContainer.grid.alpha = 0
    }
    
    // MARK: - Loader and progress
    
    func fadeInLoader() {
        UIView.animate(withDuration: 0.2) {
            self.assetViewContainer.spinnerView.alpha = 1
        }
    }
    
    func hideLoader() {
        assetViewContainer.spinnerView.alpha = 0
    }
    
    func updateProgress(_ progress: Float) {
        progressView.isHidden = progress > 0.99 || progress == 0
        progressView.progress = progress
        UIView.animate(withDuration: 0.1, animations: progressView.layoutIfNeeded)
    }
    
    // MARK: - Crop Rect
    
    func currentCropRect() -> CGRect {
        guard let cropView = assetZoomableView else {
            return CGRect.zero
        }
        let normalizedX = min(1, cropView.contentOffset.x &/ cropView.contentSize.width)
        let normalizedY = min(1, cropView.contentOffset.y &/ cropView.contentSize.height)
        let normalizedWidth = min(1, cropView.frame.width / cropView.contentSize.width)
        let normalizedHeight = min(1, cropView.frame.height / cropView.contentSize.height)
        return CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    }
    
    // MARK: - Curtain
    
    func refreshImageCurtainAlpha() {
        let imageCurtainAlpha = abs(assetViewContainerConstraintTop.constant)
            / (assetViewContainer.frame.height - assetZoomableViewMinimalVisibleHeight)
        assetViewContainer.curtain.alpha = imageCurtainAlpha
    }
    
    func cellSize() -> CGSize {
        let size = UIScreen.main.bounds.width/4 * UIScreen.main.scale
        return CGSize(width: size, height: size)
    }
}

extension YPLibraryView {
    
    enum CropRatio {
        case square
        case nonSquare
        
        var ratio: CGFloat {
            switch self {
            case .square:
                return 1
            case .nonSquare:
                return YPConfig.library.nonSquareCropRatio ?? 1
            }
        }
        
        var opposite: Self {
            switch self {
            case .square:
                return .nonSquare
            case .nonSquare:
                return .square
            }
        }
        
        var icon: UIImage {
            switch self {
            case .square:
                return YPConfig.icons.cropIconSquare
            case .nonSquare:
                return YPConfig.icons.cropIconNonsquare
            }
        }
    }
}

private extension YPLibraryView {
    func valueOfCropRatio(_ cropRatio: CropRatio) -> CGFloat {
        switch cropRatio {
        case .square:
            return 1
        case .nonSquare:
            return nonSquareCropRatio
        }
    }
    
    func handleCropRatioChange(into cropRatio: CropRatio) {
        guard
            let height = assetZoomableView?.frame.size.height,
            let width = assetZoomableView?.frame.size.width
        else {
            return
        }
        
        let ratioValue = valueOfCropRatio(cropRatio)
        if ratioValue >= 1 {  // w >= h, a wide / square image
            let heightOffset = width - width / ratioValue
            zoomableViewEqualHeightConstraint.constant = -heightOffset
            zoomableViewEqualWidthConstraint.constant = 0
        } else {  // w < h, a long image
            let widthOffset = height - height * ratioValue
            zoomableViewEqualWidthConstraint.constant = -widthOffset
            zoomableViewEqualHeightConstraint.constant = 0
        }
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations:
        {
            self.layoutIfNeeded()
        })
        assetZoomableView.fitImage(withCropRatio: ratioValue)
    }
}
