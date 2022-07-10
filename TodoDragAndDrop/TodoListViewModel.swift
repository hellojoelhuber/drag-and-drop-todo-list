
import SwiftUI
import DragAndDrop

class TodoListViewModel: DropReceivableObservableObject {
    typealias DropReceivable = DropReceivableObject
    @Published var completedItems: Int = 0
    
    var dropReceiverToDo: [DropReceivable] = [DropReceivableObject(targetType: .trash),
                                           DropReceivableObject(targetType: .complete)
                                           ]
    var dropReceiverAddNew = DropReceivableObject(targetType: .new)
    
    @Published var todoItems: [TodoListItem] = [TodoListItem(id: 0, title: "Buy milk"),
                                                TodoListItem(id: 1, title: "Buy eggs"),
                                                TodoListItem(id: 2, title: "Buy cheese"),
                                                TodoListItem(id: 3, title: "Return pants")]
    
    func setDropArea(_ dropArea: CGRect, on dropReceiver: DropReceivable) {
        switch dropReceiver.targetType {
        case .new:
            dropReceiverAddNew.updateDropArea(with: dropArea)
        default:
            let index = dropReceiverToDo.firstIndex(where: {$0.targetType == dropReceiver.targetType})!
            dropReceiverToDo[index].updateDropArea(with: dropArea)
        }
    }
    
    func getDropableState(at position: CGPoint) -> Bool {
        dropReceiverToDo.contains(where: { $0.getDropArea()!.contains(position) })
    }
    
    func getDropableStateAddItem(at position: CGPoint) -> Bool {
        dropReceiverAddNew.getDropArea()!.contains(position)
    }
    
    func addTodoItem() {
        todoItems.append(TodoListItem(id: (todoItems.last?.id ?? -1) + 1, title: "New item"))
    }
    
    func acceptDropAction(for todo: TodoListItem, at position: CGPoint) {
        if let dropReceiver = dropReceiverToDo.first(where: { $0.getDropArea()!.contains(position) }) {
            switch dropReceiver.targetType {
            case .complete:
                completedItems += 1
                removeItem(todo)
            case .trash:
                removeItem(todo)
            default:
                break
            }
        }
    }
    
    private func removeItem(_ todo: TodoListItem) {
        let index = todoItems.firstIndex(where: {$0.id == todo.id})!
        todoItems.remove(at: index)
    }
}
