import SwiftUI

// MARK: - Native UIKit GIF View
struct GIFView: UIViewRepresentable {
    let gifName: String
    var contentMode: UIView.ContentMode = .scaleAspectFill
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = contentMode
        imageView.backgroundColor = UIColor.clear
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Load and set the animated GIF
        if let gifData = loadGIFData(),
           let animatedImage = UIImage.gif(data: gifData) {
            imageView.image = animatedImage
        } else {
            // Fallback to a static placeholder
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = UIColor.gray
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.contentMode = contentMode
    }
    
    private func loadGIFData() -> Data? {
        // Try to load from bundle first
        if let bundlePath = Bundle.main.path(forResource: gifName, ofType: "gif"),
           let data = NSData(contentsOfFile: bundlePath) {
            return data as Data
        }
        
        // Try to load from bundle resources
        if let bundleData = NSDataAsset(name: gifName)?.data {
            return bundleData
        }
        
        return nil
    }
}

// MARK: - UIImage GIF Extension
extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let count = CGImageSourceGetCount(source)
        var duration: Double = 0
        var images: [UIImage] = []
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
                
                // Get frame duration
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [CFString: Any],
                   let gifDict = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
                    let frameDuration = gifDict[kCGImagePropertyGIFDelayTime] as? Double ?? 0.1
                    duration += frameDuration
                }
            }
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
} 