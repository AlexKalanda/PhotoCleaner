//
//  MainViewModel+Ext.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import Foundation
import Photos

extension MainViewModel {
    // Отменяем все предыдущие задачи
    func cancelAllClassificationTasks() {
        classificationTasks.forEach { $0.cancel() }
        classificationTasks.removeAll()
    }
    
    // Загрузка фотографий
    func loadPhotos() {
        isLoading = true
        photoGroups = []
        progress = 0.0
        cancelAllClassificationTasks()
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let assets = try await self.fetchPhotos()
                await self.classifyPhotos(assets: assets)
            } catch {
                print("Error loading photos: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
        
        classificationTasks.append(task)
    }
    
    // Получение фотографий из библиотеки
    func fetchPhotos() async throws -> [PHAsset] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        let result = PHAsset.fetchAssets(with: options)
        var assets: [PHAsset] = []
        
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    // Классификация фотографий
    func classifyPhotos(assets: [PHAsset]) async {
        let totalPhotos = assets.count
        var classifiedGroups: [String: [PHAsset]] = [:]
        var processedCount = 0
        
        for asset in assets {
            if Task.isCancelled { break }
            
            do {
                let image = try await asset.toUIImage()
                if let classification = try await imageClassifier.classify(image) {
                    let category = classification.identifier
                    classifiedGroups[category, default: []].append(asset)
                } else {
                    classifiedGroups["Other", default: []].append(asset)
                }
            } catch {
                print("Error classifying photo: \(error)")
                classifiedGroups["Other", default: []].append(asset)
            }
            
            processedCount += 1
            let newProgress = Double(processedCount) / Double(totalPhotos)
            
            DispatchQueue.main.async { [weak self] in
                self?.progress = newProgress
            }
        }
        
        if !Task.isCancelled {
            let sortedGroups = classifiedGroups
                .map { PhotoGroup(category: $0.key, photos: $0.value) }
                .sorted { $0.category < $1.category }
            
            DispatchQueue.main.async { [weak self] in
                self?.photoGroups = sortedGroups
                self?.isLoading = false
            }
        }
    }
    
    func areAllPhotosSelected(in category: String) -> Bool {
        guard let group = photoGroups.first(where: { $0.category == category }) else { return false }
        return !group.photos.isEmpty && group.photos.allSatisfy { selectedPhotos.contains($0) }
    }
    // Удаление из телефона
    func deleteSelectedPhotos() {
            guard !selectedPhotos.isEmpty else { return }
            
            // Вычисляем общий размер перед удалением
            deletedPhotosSize = selectedPhotos.reduce(0) { $0 + ($1.size ?? 0) }
            deletedPhotosCount = selectedPhotos.count
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(self.selectedPhotos as NSArray)
            }) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.removeDeletedPhotosFromGroups()
                        self?.selectedPhotos.removeAll()
                        self?.showDeletionSummary = true
                    } else if let error = error {
                        print("Ошибка удаления: \(error.localizedDescription)")
                    }
                }
            }
        }

    private func removeDeletedPhotosFromGroups() {
        let deletedPhotosSet = Set(selectedPhotos.map { $0.localIdentifier })
        
        photoGroups = photoGroups.compactMap { group in
            let filteredPhotos = group.photos.filter { !deletedPhotosSet.contains($0.localIdentifier) }
            return filteredPhotos.isEmpty ? nil : PhotoGroup(category: group.category, photos: filteredPhotos)
        }
    }
    
}
