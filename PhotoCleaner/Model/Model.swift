//
//  Model.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import Foundation
import Photos

struct PhotoGroup: Equatable {
    let category: String
    let photos: [PHAsset]
}
