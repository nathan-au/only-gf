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
    @State var fetchLimitString: String = "10"
    @State var isLoadingPhotos: Bool = false
    @State var loadingPhotosProgress: Double = 0.0
    
    var body: some View {
        if (photos.isEmpty == false) {
            ZStack {
                if (currentPhotoIndex < photos.count - 1) {
                    Image(uiImage: photos[currentPhotoIndex + 1])
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.7)

                }
                Image(uiImage: photos[currentPhotoIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                dragOffset = gesture.translation
                            }
                            .onEnded { value in
                                
                                dragOffset = CGSize(
                                    width: value.translation.width * 4, // exaggerate direction
                                    height: value.translation.height * 4
                                )
                                if (currentPhotoIndex < photos.count - 1) {
                                    currentPhotoIndex += 1
                                }
                                dragOffset = .zero
                            }
                    )
                    .offset(x: dragOffset.width, y: dragOffset.height)
                    .animation(.interactiveSpring(), value: dragOffset)
            }
            
        }
        else if (isLoadingPhotos) {
            VStack {
                ProgressView(value: loadingPhotosProgress, total: 1.0) { Text("Loading Photos...") }
                    .frame(width: UIScreen.main.bounds.width * 0.5)
            }
            
        }
        else {
            VStack {
                Spacer()
                Image(systemName: "heart.circle")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Text("Welcome to OnlyGF")
                Button("Subscribe") { verifyPhotoAccess() }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                TextField("10", text: $fetchLimitString)
                    .frame(width: UIScreen.main.bounds.width * 0.2)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
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
        self.isLoadingPhotos = true

        var fetchLimit: Int = 10
        if let fetchLimitInt = Int(fetchLimitString) {
            fetchLimit = fetchLimitInt
        }
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = fetchLimit
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResults = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageManager = PHImageManager.default()
        var assetBucket = Array<UIImage?>(repeating: nil, count: fetchResults.count)
        var assetBucketCount: Int = 0
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        for i in 0..<fetchResults.count {
            let asset = fetchResults.object(at: i)
            imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { image, info in
                if let img = image {
                    DispatchQueue.main.async {
                        assetBucket[i] = img
                        assetBucketCount += 1
                        self.loadingPhotosProgress = Double(assetBucketCount) / Double(fetchResults.count)
                        
                        if (assetBucketCount == fetchResults.count) {
                            self.photos = assetBucket.compactMap { asset in
                                asset
                            }
                            self.isLoadingPhotos = false
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
