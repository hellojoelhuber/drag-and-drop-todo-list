
import SwiftUI
import DragAndDrop

struct DropReceivableObject: DropReceiver {
    var dropArea: CGRect? = nil
    let targetType: TargetType
    
    enum TargetType {
        case trash
        case complete
        case new
    }
}

