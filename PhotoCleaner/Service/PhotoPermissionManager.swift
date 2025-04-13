//
//  PhotoPermissionManager.swift
//  PhotoCleaner
//
//  Created by admin on 6/4/2025.
//

import SwiftUI
import Photos

// Сервис для управления доступом к фотоальбому
final class PhotoManager {
    
    // MARK: - Свойства
    
    // Единственный экземпляр менеджера
    static let shared = PhotoManager()
    // Приватный инициализатор предотвращает создание новых экземпляров
    private init() {}
    // Текущий статус доступа к фотоальбому
    var authorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus() // Системный запрос текущего статуса
    }
    // Проверяет, есть ли доступ (авторизован или ограничен)
    var hasAccess: Bool {
        let status = authorizationStatus
        return status == .authorized || status == .limited
    }
    
    // MARK: - Методы
    
    // Запрашивает доступ к фотоальбому
    func requestAccess(completion: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
    // Открывает настройки приложения
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
}


