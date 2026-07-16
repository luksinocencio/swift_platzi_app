import SwiftUI

struct ImagePlaceHolderView: View {
    let width: CGFloat = 75
    let height: CGFloat = 75
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.0, style: .continuous)
                .fill(Color.gray.opacity(0.15))
                .frame(width: width, height: height)
                .overlay(RoundedRectangle(cornerRadius: 16.0, style: .continuous).stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            
            Image(systemName: "photo")
                .foregroundStyle(.gray.opacity(0.4))
                .font(.system(size: 24))
        }
    }
}


