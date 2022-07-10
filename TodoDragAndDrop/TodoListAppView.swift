
import SwiftUI
import DragAndDrop

struct TodoListAppView: View {
    @StateObject var model = TodoListViewModel()
    @State var addNewDragging: Bool = false
    @State var todoDragging: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                ActionButtonView(backgroundColor: .blue, imageOverlay: "plus.circle")
                    .dragable(onDragged: onDragNew,
                              onDropped: onDropNew)
                    
            }
            .zIndex(addNewDragging ? 3 : 1)
            .padding()
            
            Text("Completed Items: \(model.completedItems)")
            
            Spacer()
            
            TodoListView(addNewDragging: $addNewDragging,
                         todoDragging: $todoDragging)
                .zIndex(todoDragging ? 2 : 0)
                .environmentObject(model)
            
            Spacer()
            
            HStack(spacing: 50) {
                ForEach(model.dropReceiverToDo, id:\.targetType) { receiver in
                    switch receiver.targetType {
                    case .trash:
                        ActionButtonView(backgroundColor: .red, imageOverlay: "trash")
                            .dropReceiver(for: receiver, model: model)
                    case .complete:
                        ActionButtonView(backgroundColor: .green, imageOverlay: "checkmark.seal")
                            .dropReceiver(for: receiver, model: model)
                    default:
                        EmptyView()
                    }
                    
                }
            }
        }
    }
    
    func onDragNew(position: CGPoint) -> DragState {
        addNewDragging = true
        todoDragging = false
        if model.getDropableStateAddItem(at: position) {
            return .accepted
        } else {
            return.unknown
        }
    }
    func onDropNew(position: CGPoint) -> Bool {
        addNewDragging = false
        if model.getDropableStateAddItem(at: position) {
            model.addTodoItem()
        }
        return false
    }
}


struct SquareView_Previews: PreviewProvider {
    struct Preview: View {
        
        var body: some View {
            TodoListAppView()
        }
    }

    static var previews: some View {
        Preview()
    }
}


