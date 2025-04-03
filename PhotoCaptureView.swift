import SwiftUI
import AVFoundation
import UIKit  // Add this import

class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var photoOutput = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var recentImage: UIImage?
    @Published var isFrontCamera = true // Add this to track camera position
    @Published var isShowingSavedImage = false // Add this to control when to show saved image
    // Add notification when photo is saved
    static let photoSavedNotification = Notification.Name("PhotoSaved")
    
    // Get the documents directory path
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Get the path for storing the user's photo
    private static var userPhotoURL: URL {
        getDocumentsDirectory().appendingPathComponent("user_photo.jpg")
    }
    func flipCamera() {
        session.beginConfiguration()
        
        // Remove existing input
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        session.removeInput(currentInput)
        
        // Get new camera
        let newPosition: AVCaptureDevice.Position = isFrontCamera ? .back : .front
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else { return }
        
        do {
            let newInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                isFrontCamera.toggle()
            }
        } catch {
            print("Error flipping camera: \(error.localizedDescription)")
        }
        
        session.commitConfiguration()
    }
    // Save image to documents directory
    static func saveImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: userPhotoURL)
            NotificationCenter.default.post(name: photoSavedNotification, object: nil)
        }
    }
    
   
    
    // Add public method to delete saved image
    static func deleteSavedImage() {
        try? FileManager.default.removeItem(at: userPhotoURL)
    }
    
     override init() {
        super.init()
        // Don't automatically load saved image on init
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
            
            // Use front camera initially
            let position: AVCaptureDevice.Position = isFrontCamera ? .front : .back
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else { return }
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
    // Make this a static method
    static func loadSavedImage() -> UIImage? {
        try? UIImage(data: Data(contentsOf: userPhotoURL))
    }
    // Add method to load saved image
    func loadSavedImage() {
        if let savedImage = CameraManager.loadSavedImage() {
            self.recentImage = savedImage
            self.isShowingSavedImage = true
        }
    }
    
    // Modify the takePhoto method
    func takePhoto() {
        isShowingSavedImage = false // Reset this flag when taking new photo
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // Modify startNewPhoto method to properly reset everything
    func startNewPhoto() {
        recentImage = nil
        isShowingSavedImage = false
        
        // Make sure we're on the main thread when configuring the session
        DispatchQueue.main.async {
            self.session.startRunning()
            // Ensure camera is properly setup
            self.setupCamera()
        }
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
                    ZStack {
                        CameraPreview(session: cameraManager.session)
                            .frame(height: 400)
                        
                        // Flip camera button
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    cameraManager.flipCamera()
                                }) {
                                    Image(systemName: "camera.rotate")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 20)
                            }
                            Spacer()
                        }
                    }
                }
            }
            
            Spacer()
            
            // Show different buttons based on whether photo is taken
            if cameraManager.recentImage != nil {
                // Navigation buttons after photo is taken
                HStack(spacing: 40) {
                    Button(action: {
                        CameraManager.deleteSavedImage() // Delete saved image first
                        cameraManager.startNewPhoto() // Then start new photo session
                        cameraManager.checkPermissions() // Ensure camera is initialized
                    }) {
                        Text("Retake")
                            .font(StyleSwipeTheme.buttonFont)
                            .foregroundColor(StyleSwipeTheme.primary)
                    }
                    .outlinedButtonStyle()
                    
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
            if cameraManager.recentImage == nil {
                cameraManager.loadSavedImage()
                if cameraManager.recentImage == nil {
                    cameraManager.checkPermissions()
                    cameraManager.session.startRunning()
                }
            }
        }
        .onDisappear {
            cameraManager.session.stopRunning()
        }
    }
}