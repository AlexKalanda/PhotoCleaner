//
//  HomeViewModel.swift
//  PhotoCleaner
//
//  Created by admin on 6/4/2025.
//

import Photos
import UIKit

final class MainViewModel: ObservableObject {
    @Published var showSettingsAlert = false
    @Published var photoGroups: [PhotoGroup] = []
    @Published var progress: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var selectedPhotos: [PHAsset] = []
    @Published var selectedCategoryForFullScreen: PhotoGroup?
    @Published var currentFullScreenIndex: Int = 0
    @Published var showDeletionSummary = false
    @Published var deletedPhotosCount = 0
    @Published var deletedPhotosSize: Int64 = 0
    
    let photoManager = PhotoManager.shared
    let imageClassifier = ImageClassifier()
    var classificationTasks: [Task<Void, Never>] = []
    var totalPhotoCount: Int {
        photoGroups.reduce(0) { $0 + $1.photos.count }
    }
    
    init() { checkPhotoAccess() }
    deinit { cancelAllClassificationTasks() }
    
    // Проверка статуса доступа
    private func checkPhotoAccess() {
        if !photoManager.hasAccess {
            requestPhotoAccess()
        } else {
            loadPhotos()
        }
    }
    // Запрос доступа к фотоальбому
    func requestPhotoAccess() {
        photoManager.requestAccess { [weak self] status in
            guard let self = self else { return }
            
            switch status {
            case .authorized, .limited:
                self.loadPhotos()
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.showSettingsAlert = true
                }
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    // переключение выбора фото
    func togglePhotoSelection(_ asset: PHAsset) {
        if let index = selectedPhotos.firstIndex(of: asset) {
            selectedPhotos.remove(at: index)
        } else {
            selectedPhotos.append(asset)
        }
    }
    
    // выбрать все фото в категории
    func selectAllPhotos(in category: String) {
        guard let group = photoGroups.first(where: { $0.category == category }) else { return }
        
        // Проверяем, все ли уже выбраны
        let allSelected = group.photos.allSatisfy { selectedPhotos.contains($0) }
        
        if allSelected {
            // Снимаем выбор
            selectedPhotos.removeAll { group.photos.contains($0) }
        } else {
            // Добавляем недостающие
            let newSelections = group.photos.filter { !selectedPhotos.contains($0) }
            selectedPhotos.append(contentsOf: newSelections)
        }
    }
    
}
