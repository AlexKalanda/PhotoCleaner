//
//  PhotoThumbnailView.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import SwiftUI
import Photos

struct PhotoThumbnailView: View {
    let asset: PHAsset
    let isSelected: Bool
    let onTap: () -> Void
    let onImageTap: () -> Void
    
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Основное изображение
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(8)
                    .onTapGesture {
                        onImageTap()
                    }
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(.blue.opacity(0.3))
                        .onTapGesture {
                            onImageTap()
                        }
                }
                
                // Кнопка выбора/отмены
                Button(action: {
                    onTap()
                }) {
                    Image(systemName: isSelected ? "checkmark.circle" : "circle")
                        .foregroundColor(isSelected ? .green : .secondary)
                        .padding(4)
                        .clipShape(Circle())
                }
                .padding(8)
                
            } else {
                ProgressView()
                    .frame(width: 150, height: 150)
            }
            
        }
        .task {
            image = try? await asset.toUIImage(targetSize: CGSize(width: 200, height: 200))
        }
    }
}
