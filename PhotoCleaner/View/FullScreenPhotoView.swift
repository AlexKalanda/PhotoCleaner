//
//  FullScreenPhotoView.swift
//  PhotoCleaner
//
//  Created by admin on 11/4/2025.
//

import SwiftUI
import Photos

struct FullScreenPhotoView: View {
    let group: PhotoGroup
    @Binding var isPresented: Bool
    @State private var currentIndex: Int
    @State private var scrollPosition: Int?
    
    @EnvironmentObject var viewModel: MainViewModel
    
    init(group: PhotoGroup, currentIndex: Int, isPresented: Binding<Bool>) {
        self.group = group
        self._currentIndex = State(initialValue: currentIndex)
        self._scrollPosition = State(initialValue: currentIndex)
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(group.photos.enumerated()), id: \.element.localIdentifier) { index, asset in
                        FullScreenPhotoItem(asset: asset)
                            .frame(width: UIScreen.main.bounds.width)
                            .containerRelativeFrame(.horizontal)
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrollPosition)
            .scrollTargetBehavior(.paging)
            .onChange(of: scrollPosition) { oldValue, newValue in
                if let newValue = newValue {
                    currentIndex = newValue
                    viewModel.currentFullScreenIndex = newValue
                }
            }
            
            VStack {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        let asset = group.photos[currentIndex]
                        viewModel.togglePhotoSelection(asset)
                    }) {
                        Image(systemName: viewModel.selectedPhotos.contains(group.photos[currentIndex]) ?
                              "checkmark.circle" : "circle")
                        .foregroundColor(viewModel.selectedPhotos.contains(group.photos[currentIndex]) ? .green : .secondary)
                        .padding()
                    }
                }
                .padding()
                
                Spacer()
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(group.photos.enumerated()), id: \.element.localIdentifier) { index, asset in
                                MiniPhotoView(
                                    asset: asset,
                                    isCurrent: index == currentIndex,
                                    isSelected: viewModel.selectedPhotos.contains(asset)
                                )
                                .id(index)
                                .onTapGesture {
                                    withAnimation {
                                        scrollPosition = index
                                        currentIndex = index
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        withAnimation {
                                            viewModel.togglePhotoSelection(asset)
                                        }
                                    } label: {
                                        Label(
                                            viewModel.selectedPhotos.contains(asset) ?
                                            "Убрать из удаления" : "Добавить к удалению",
                                            systemImage: viewModel.selectedPhotos.contains(asset) ? "minus.circle" : "plus.circle"
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(height: 80)
                    .background(Color.black.opacity(0.7))
                    .onAppear {
                        proxy.scrollTo(currentIndex, anchor: .center)
                    }
                    .onChange(of: currentIndex) { _, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}
