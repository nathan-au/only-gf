//
//  ContentView.swift
//  OnlyGF
//
//  Created by Nathan Au on 2025-10-28.
//

import SwiftUI
import Photos

struct ContentView: View {
    @State private var photos: [UIImage] = []
    
    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "heart.circle")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Text("Welcome to OnlyGF")
                    .font(.title)
                Button("Subscribe") { requestPhotoAccess() }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            
                ForEach(photos, id: \.self) { photo in
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                }
            }
            .padding()
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
            imageManager.requestImage(for: asset,
                                      targetSize: PHImageManagerMaximumSize,
                                      contentMode: .aspectFit,
                                      options: requestOptions) { image, info in
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
    
    func requestPhotoAccess() {
        let authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch (authStatus) {
        case .notDetermined:
            print("request photo access")
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { reqStatus in
                    print(reqStatus)
            }
        case .restricted:
            print("sorry this app wont work")
        case .denied:
            print("please change app permissions")
        case .authorized:
            print("thanks for sharing your photos")
            fetchPhotos()
        case .limited:
            print("please change app permission to full access")
        default:
            print("idk bro")
        }
    }
    
}

#Preview {
    ContentView()
}




