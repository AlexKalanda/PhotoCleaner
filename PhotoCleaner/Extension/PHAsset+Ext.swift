//
//  PHAsset+Ext.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import UIKit
import Photos

extension PHAsset {
    
    var size: Int64? {
            let resources = PHAssetResource.assetResources(for: self)
            return resources.first?.value(forKey: "fileSize") as? Int64
        }
    
    func toUIImage(targetSize: CGSize? = nil) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            let size = targetSize ?? CGSize(width: pixelWidth, height: pixelHeight)
            
            manager.requestImage(
                for: self,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                if let image = image {
                    continuation.resume(returning: image)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "PhotoLibrary", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
}
