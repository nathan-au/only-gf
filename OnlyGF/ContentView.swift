//
//  ContentView.swift
//  OnlyGF
//
//  Created by Nathan Au on 2025-10-28.
//

import SwiftUI
import Photos

struct ContentView: View {
    @State var photos: [UIImage] = []
    @State var showAccessAlert: Bool = false
    @State var currentPhotoIndex: Int = 0
    @State var dragOffset: CGSize = .zero
    
    var body: some View {
        if (photos.isEmpty == false) {
            Image(uiImage: photos[currentPhotoIndex])
                .resizable()
                .scaledToFit()
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            dragOffset = gesture.translation
                        }
                        .onEnded { value in
                            dragOffset = .zero
                            if (currentPhotoIndex < photos.count - 1) {
                                currentPhotoIndex += 1
                                
                            }
                        }
                )
        }
        else {
            VStack {
                Spacer()
                Image(systemName: "heart.circle")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Text("Welcome to OnlyGF")
                    .font(.title)
                Button("Subscribe") { verifyPhotoAccess() }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                Spacer()
            }
            .alert("Please allow full access to photo library in system settings.", isPresented: $showAccessAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        
    }
        
    func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { reqStatus in
            print(reqStatus)
        }
    }
        
    func verifyPhotoAccess() {
        let authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        if (authStatus == .notDetermined) {
            requestPhotoAccess()
        }
        else if ([.restricted, .denied, .limited].contains(authStatus)) {
            showAccessAlert = true
        }
        else if (authStatus == .authorized) {
            fetchPhotos()
        }
    }
    
    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 10
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResults = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageManager = PHImageManager.default()
        var assetBucket = Array<UIImage?>(repeating: nil, count: fetchResults.count)
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        
        for i in 0..<fetchResults.count {
            let asset = fetchResults.object(at: i)
            imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { image, info in
                if let img = image {
                    DispatchQueue.main.async {
                        assetBucket[i] = img
                        self.photos = assetBucket.compactMap { asset in
                            asset
                        }
                    }
                }
            }
        }
    }
}
    
#Preview {
    ContentView()
}
    
    

