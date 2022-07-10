
import SwiftUI
import DragAndDrop

struct ActionButtonView: View, DropReceiver {
    var dropArea: CGRect?
    var backgroundColor: Color
    var imageOverlay: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(backgroundColor.opacity(0.5))
            Image(systemName: imageOverlay)
        }
        .frame(width: 100, height: 50)
    }
    
}

struct ActionButtonView_Previews: PreviewProvider {
    struct Preview: View {
        
        var body: some View {
            ActionButtonView(backgroundColor: .green,
                             imageOverlay: "checkmark.seal")
        }
    }
    static var previews: some View {
        Preview()
    }
}
