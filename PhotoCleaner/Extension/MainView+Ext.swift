//
//  MainView+Ext.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import SwiftUI

extension MainView {
    
    @ToolbarContentBuilder
    func settingToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if !viewModel.selectedPhotos.isEmpty {
                Button {
                    viewModel.deleteSelectedPhotos()
                } label: {
                    ZStack(alignment: .topLeading) {
                        Image(systemName: "trash")
                            .tint(.red)
                            .font(.body)
                        Text(viewModel.selectedPhotos.count.description)
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(.red)
                            .clipShape(.circle)
                            .offset(x: -5, y: -5)
                    }
                }
            }
        }
    }
    
    func settingsAlert() -> Alert {
        Alert(
            title: Text("Доступ запрещён"),
            message: Text("Пожалуйста, предоставьте доступ к фотоальбому в настройках приложения."),
            primaryButton: .default(Text("Открыть настройки")) {
                viewModel.photoManager.openSettings()
            },
            secondaryButton: .cancel()
        )
    }
    
    var accessDeniedView: some View {
        VStack(spacing: 20) {
            Text("Доступ к фотоальбому запрещен")
                .font(.headline)
            
            Text("Для работы приложения необходимо предоставить доступ к вашим фотографиям")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.requestPhotoAccess()
            }) {
                Text("Разрешить доступ")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func categorySection(for group: PhotoGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(group.category.uppercased()) (\(group.photos.count) шт.)")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                Button(action: {
                    viewModel.selectAllPhotos(in: group.category)
                }) {
                    Text(viewModel.areAllPhotosSelected(in: group.category) ? "Отменить все" : "Выбрать все")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(Array(group.photos.enumerated()), id: \.element.localIdentifier) { index, asset in
                        PhotoThumbnailView(
                            asset: asset,
                            isSelected: viewModel.selectedPhotos.contains(asset),
                            onTap: { viewModel.togglePhotoSelection(asset) },
                            onImageTap: {
                                viewModel.selectedCategoryForFullScreen = group
                                viewModel.currentFullScreenIndex = index
                                showFullScreen = true
                            }
                        )
                        .onTapGesture {
                            viewModel.selectedCategoryForFullScreen = group
                            viewModel.currentFullScreenIndex = index
                            showFullScreen = true
                        }
                    }
                }
            }
        }
    }
    
    
    var contentView: some View {
        ScrollViewReader { proxy in
            countPhoto
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.photoGroups, id: \.category) { group in
                        categorySection(for: group)
                            .id(group.category)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var countPhoto: some View {
        Text("Всего фото - \(viewModel.totalPhotoCount), категорий - \(viewModel.photoGroups.count)")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.top, 8)
    }
    
    
}
