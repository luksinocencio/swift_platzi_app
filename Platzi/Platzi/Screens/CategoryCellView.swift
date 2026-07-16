import SwiftUI

struct CategoryCellView: View {
    let category: Category
    
    var body: some View {
        HStack() {
            AsyncImage(url: category.image) { img in
                img
                    .resizable()
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
            } placeholder: {
                ImagePlaceHolderView()
            }
            Text(category.name)
            Spacer()
        }
    }
}

#Preview {
    CategoryCellView(category: .init(id: 1, name: "teste", image: URL.randomImageURL))
}

