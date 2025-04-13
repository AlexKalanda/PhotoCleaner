//
//  MiniPhotoView.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import SwiftUI
import Photos

struct MiniPhotoView: View {
    let asset: PHAsset
    let isCurrent: Bool
    let isSelected: Bool
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(4)
                    .overlay(
                        isCurrent ?
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white, lineWidth: 2) : nil
                    )
                    .overlay(
                        isSelected ?
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.red, lineWidth: 2) : nil
                    )
            } else {
                ProgressView()
                    .frame(width: 60, height: 60)
            }
        }
        .task {
            image = try? await asset.toUIImage(targetSize: CGSize(width: 120, height: 120))
        }
    }
}
