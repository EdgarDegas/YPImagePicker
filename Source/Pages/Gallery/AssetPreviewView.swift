//
//  AssetPreviewView.swift
//  YPImagePicker
//
//  Created by iMoe on 2019/12/3.
//  Copyright © 2019 Yummypets. All rights reserved.
//

import UIKit
import Photos
    
final public class AssetPreviewView: UIView {
    var currentAsset: PHAsset?
    
    var cropRatio: CGFloat = 1 {
        didSet {
            configureImageView(withCropRatio: cropRatio)
        }
    }
    
    private(set) weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        load()
    }
    
    private var didLayoutImageView: Bool = false
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard didLayoutImageView == false else { return }
        didLayoutImageView = true
        adjustImageViewLayout()
    }
}


// MARK: - Interfaces
extension AssetPreviewView {
    func setImage(
        _ photo: PHAsset,
        mediaManager: LibraryMediaManager,
        completion: @escaping () -> Void
    ) {
        guard currentAsset != photo else {
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        currentAsset = photo
        
        mediaManager.imageManager?.fetch(photo: photo) { [weak self] image, _ in
            guard let self = self else { return }
            self.imageView.image = image
            completion()
        }
    }
}


// MARK: - Setup
private extension AssetPreviewView {
    func load() {
        backgroundColor = YPConfig.colors.assetViewBackgroundColor
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        self.imageView = imageView
    }
    
    func configureImageView(withCropRatio cropRatio: CGFloat) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .curveEaseOut,
            animations:
        { [weak self] in
            guard let self = self else { return }
            self.adjustImageViewLayout()
        })
    }
    
    func adjustImageViewLayout() {
        self.imageView.frame = self.bounds
        let width = self.bounds.height * cropRatio
        let xOffset = (self.bounds.width - width) / 2
        self.imageView.frame.size.width = width
        self.imageView.frame.origin.x += xOffset
    }
}
