//
//  DeletionSummaryView.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import SwiftUI

struct DeletionSummaryView: View {
    let count: Int
    let size: Int64
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Удаление завершено")
                .font(.title)
                .bold()
            
            Text("Вы удалили \(count) фотографий (\(size.formattedSize))")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button(action: onDismiss) {
                Text("Вернуться в альбом")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

