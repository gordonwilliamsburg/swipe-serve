import SwiftUI
import AVFoundation
import UIKit  // Add this import

class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var photoOutput = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var recentImage: UIImage?
    
    // Get the documents directory path
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Get the path for storing the user's photo
    private static var userPhotoURL: URL {
        getDocumentsDirectory().appendingPathComponent("user_photo.jpg")
    }
    
    // Save image to documents directory
    static func saveImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: userPhotoURL)
        }
    }
    
    // Load image from documents directory
    static func loadSavedImage() -> UIImage? {
        try? UIImage(data: Data(contentsOf: userPhotoURL))
    }
    
    // Add public method to delete saved image
    static func deleteSavedImage() {
        try? FileManager.default.removeItem(at: userPhotoURL)
    }
    
    override init() {
        super.init()
        // Load saved image if it exists
        if let savedImage = CameraManager.loadSavedImage() {
            self.recentImage = savedImage
        }
    }
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            break
        }
    }
    
    func setupCamera() {
        do {
            session.beginConfiguration()
            
            // Use front camera
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            session.commitConfiguration()
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
                self.recentImage = image
                // Save the image to local storage
                CameraManager.saveImage(image)
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct PhotoCaptureView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        VStack {
            Text("Photo Capture")
                .font(StyleSwipeTheme.headlineFont)
                .foregroundColor(StyleSwipeTheme.primary)
            
            Spacer()
            
            // Camera preview
            ZStack {
                if cameraManager.recentImage != nil {
                    Image(uiImage: cameraManager.recentImage!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 400)
                } else {
                    CameraPreview(session: cameraManager.session)
                        .frame(height: 400)
                }
            }
            
            Spacer()
            
            // Show different buttons based on whether photo is taken
            if cameraManager.recentImage != nil {
                // Navigation buttons after photo is taken
                HStack(spacing: 40) {
                    Button(action: {
                        cameraManager.recentImage = nil
                        // Use the public method instead
                        CameraManager.deleteSavedImage()
                    }) {
                        Text("Retake")
                            .font(StyleSwipeTheme.buttonFont)
                            .foregroundColor(StyleSwipeTheme.primary)
                    }
                    .outlinedButtonStyle()
                    
                    // Next button
                    Button(action: {
                        navigationManager.navigate(to: .outfitSwiper)
                    }) {
                        Text("Next")
                            .font(StyleSwipeTheme.buttonFont)
                    }
                    .outlinedButtonStyle()
                }
                .padding(.bottom, 40)
            } else {
                // Capture button when no photo is taken
                Button(action: {
                    cameraManager.takePhoto()
                }) {
                    ZStack {
                        Circle()
                            .fill(StyleSwipeTheme.accent)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .stroke(StyleSwipeTheme.secondary, lineWidth: 3)
                            .frame(width: 70, height: 70)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StyleSwipeTheme.background)
        .onAppear {
            cameraManager.checkPermissions()
            cameraManager.session.startRunning()
        }
        .onDisappear {
            cameraManager.session.stopRunning()
        }
    }
}
