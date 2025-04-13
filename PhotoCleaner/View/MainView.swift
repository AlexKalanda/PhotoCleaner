//
//  HomeView.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import SwiftUI
import Photos

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @State var showFullScreen = false
    
    var body: some View {
        Group {
            if !viewModel.photoManager.hasAccess && viewModel.photoManager.authorizationStatus != .notDetermined {
                accessDeniedView
            } else if viewModel.isLoading {
                VStack {
                    Text("Анализ фотогалереи...")
                    ProgressView(value: viewModel.progress)
                        .padding()
                }
            } else if viewModel.showDeletionSummary {
                DeletionSummaryView(
                    count: viewModel.deletedPhotosCount,
                    size: viewModel.deletedPhotosSize,
                    onDismiss: {
                        viewModel.showDeletionSummary = false
                    }
                )
            } else {
                NavigationStack {
                    contentView
                        .navigationTitle("Фотоальбом")
                        .toolbar { settingToolbar() }
                }
            }
        }
        .alert(isPresented: $viewModel.showSettingsAlert) { settingsAlert() }
        .fullScreenCover(isPresented: $showFullScreen) {
            if let group = viewModel.selectedCategoryForFullScreen {
                FullScreenPhotoView(
                    group: group,
                    currentIndex: viewModel.currentFullScreenIndex,
                    isPresented: $showFullScreen
                )
                .environmentObject(viewModel)
            }
        }
    }
}
