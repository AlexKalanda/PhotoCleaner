//
//  Int64+Ext.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import Foundation

extension Int64 {
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: self)
    }
}
