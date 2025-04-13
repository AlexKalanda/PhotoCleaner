//
//  ImageClassifier.swift
//  PhotoCleaner
//
//  Created by admin on 7/4/2025.
//

import UIKit
import Vision

// Класс для классификации фото
final class ImageClassifier {
    func classify(_ image: UIImage) async throws -> ClassificationObservation? {
        guard let image = CIImage(image: image) else { return nil }
        
        do {
            let request = ClassifyImageRequest()
            let result = try await request.perform(on: image)
            return result.max(by: { $0.confidence < $1.confidence })
        } catch {
            print("Classification error: \(error.localizedDescription)")
            return nil
        }
    }
}
