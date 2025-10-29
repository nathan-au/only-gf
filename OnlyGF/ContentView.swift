//
//  ContentView.swift
//  OnlyGF
//
//  Created by Nathan Au on 2025-10-28.
//

import SwiftUI
import Photos

struct ContentView: View {
    @State private var firstImage: UIImage? = nil
    var body: some View {
        VStack {
            Image(systemName: "heart.circle")
                .imageScale(.large)
                .foregroundStyle(.blue)
            Text("Welcome to OnlyGF")
            Button("Request Photo Access") {
                requestPhotoAccess()
            }
            
            if let img = firstImage {
                Image(uiImage: img)

            }

        }
        .padding()
    }
    
    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        
        let fetchResults = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageManager = PHImageManager.default()
        guard let asset = fetchResults.firstObject else {
            return
        }
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil) { image, info in
            
            if let img = image {
                self.firstImage = img

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




