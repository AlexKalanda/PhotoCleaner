//
//  FullScreenPhotoItem.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import SwiftUI
import Photos

struct FullScreenPhotoItem: View {
    let asset: PHAsset
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .task {
            image = try? await asset.toUIImage()
        }
    }
}
