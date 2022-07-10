# To-Do List

This project was created as a samplie implementation of [SwiftUI Drag-and-Drop](https://github.com/hellojoelhuber/swiftui-drag-and-drop) library. This README is a mirror of my [personal website](https://www.joelhuber.com/software-documentation/documentation-todo-list/).

![To Do List Drag-And-Drop Demo](/assets/media/documentation-dragdrop-todo-demo.gif){:style="display:block; margin-left:auto; margin-right:auto; width:100%; max-width:250px; border:2px solid;"}

# Overview.

The To Do List project uses drop areas for the three basic operations on a to-do item (Add, Complete, Delete). While better UX exists for these operations, this project shows how one might use drag-and-drop as a way to signal intent in a non-game app.
* There are three (3) `DropReceiver`s, the Complete button, the Delete button, and the List.
* The `Dragable` objects are the list items and the "Add New" button.
* The drop areas only accept certain `Dragable`s. The Complete and Delete drop areas only accept the list items while the List drop area only accepts the "Add New" button.

Additionally, the to-do list view is created with a `VStack` of to-do items, because the `List` and `ScrollView` options cannot be escaped. A draggable View cannot be dragged from one View to another View. This limitation goes back to UIKit and is not unique to SwiftUI.

## Protocol: Dragable

There are two `Dragable` objects, the to-do item and the Add New button.

```swift
struct TodoListItem: Identifiable, Dragable {
    let id: Int
    let title: String   
}
extension TodoListItem: Equatable {
    static func == (lhs: TodoListItem, rhs: TodoListItem) -> Bool {
        lhs.id == rhs.id
    }
}
```

However, only the to-do item needed to be marked as `Dragable`, because the to-do item needs to know something about the item itself when it is dragged or dropped. The Add New button does not need to pass any information about itself to the drag or drop methods, so it does not need to conform to `Dragable`.

## ViewModifier: .dragable(...)

The to-do item uses `.dragable(object:onDragObject:onDropObject:)` while the Add New button uses `.dragable(onDragged:onDropped:)`.

```swift
// ForEach where the to-do Views are created.
    ForEach(model.todoItems) { item in
        TodoListItemView(todoItem: item)
            .dragable(object: item,
                      onDragObject: onDragTodo,
                      onDropObject: onDropTodo)
    }

// How the Add New button is created.
    ActionButtonView(backgroundColor: .blue, imageOverlay: "plus.circle")
        .dragable(onDragged: onDragNew,
                  onDropped: onDropNew)
```

#### onDragged

Because the drop areas for the to-do items and the Add New button are different (to-do item works on the Complete and Trash buttons; Add New works on the to-do list), the ViewModel holds two different methods for checking the drag state:

```swift
    func getDropableState(at position: CGPoint) -> Bool {
        dropReceiverToDo.contains(where: { $0.getDropArea()!.contains(position) })
    }
    
    func getDropableStateAddItem(at position: CGPoint) -> Bool {
        dropReceiverAddNew.getDropArea()!.contains(position)
    }
```

The former method, `getDropableState(at:)`, is looping through an array of drop receivers to find a match, an array that does not include the Add New drop area. Meanwhile, the Add New drop area is stored in its own variable, which the latter method, `getDropableStateAddItem(at:)`, simply accesses to check if the position is in the drop area.

Also, the Add New button toggles a property `@State var addNewDragging: Bool` when moving. This causes the to-do list to be overlaid with a light purple color with a "+" symbol:

```swift
    ZStack {
        Color.purple
            .opacity(0.15)
        HStack {
            Image(systemName: "plus.circle")
            Text("Add New!")
        }.font(.system(size: 40))
            .foregroundColor(.blue)        
    }
```

#### onDropped

The drop methods take different approaches to performing the drop action as well. The to-do item lets the `acceptDropAction(for:at:)` to determine whether the drop is legal, and the Add New button only calls the `addTodoItem()` method _if_ the drop was legal.

```swift
    func onDropTodo(object: Dragable, position: CGPoint) -> Bool {
        model.acceptDropAction(for: object as! TodoListItem,
                               at: position)
        todoDragging = false
        return false
    }
    
    func onDropNew(position: CGPoint) -> Bool {
        addNewDragging = false
        if model.getDropableStateAddItem(at: position) {
            model.addTodoItem()
        }
        return false
    }
```

The `acceptDropAction(for:at:)` method is protected by an `if let`. If no drop area contains the position, nothing happens. 

```swift
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
```

## Protocol: DropReceiver

The drop receivers are simple structs to hold the drop area and the `targetType`. Since there is no real connective tissue between the drop areas, I wrote it as a generic `DropReceivableObject`. 

```swift
struct DropReceivableObject: DropReceiver {
    var dropArea: CGRect? = nil
    let targetType: TargetType
    
    enum TargetType {
        case trash
        case complete
        case new
    }
}
```

It's tempting to think that we could try a struct-per-drop-area with protocol-inheritance to add the `targetType` property to our `DropReceiver`, or even just create a new protocol `Target` which requires the property. It would look something like this:

```swift
protocol DropReceiverObject: DropReceiver {
    var dropArea: CGRect? { get set }
    var targetType: DropReceivableObject.TargetType { get set }
}

struct TrashButtonObject: DropReceiverObject {
    var dropArea: CGRect? = nil
    
    var targetType: DropReceivableObject.TargetType = .trash
}
```

However, back in our ViewModel, if we try to write:

```swift
typealias DropReceivable = DropReceiverObject
```

Xcode will tell us that we no longer conform to the protocol `DropReceivableObservableObject`. We cannot type alias a protocol, and we won't be able to use the same type alias for multiple types; that is, we cannot write:

```swift
typealias DropReceivable = TrashObject
typealias DropReceivable = CompleteObject
```

It's an invalid redeclaration. So in order to conform to `DropReceivableObservableObject`, we must use a generic-ish struct for our drop areas.

## Protocol: DropReceivableObservableObject

The `TodoListViewModel` holds drop receivers two ways: the receivers expecting to-do items are held in an array while the receiver expecting only the Add New button is held in a single `var`. The `setDropArea(_:on:)` method does a switch on the `dropReceiver.targetType` to determine whether to update the variable or append to the array.

```swift
class TodoListViewModel: DropReceivableObservableObject {
    typealias DropReceivable = DropReceivableObject
    
    var dropReceiverToDo: [DropReceivable] = [DropReceivableObject(targetType: .trash),
                                              DropReceivableObject(targetType: .complete)
                                             ]
    var dropReceiverAddNew = DropReceivableObject(targetType: .new)
    
    func setDropArea(_ dropArea: CGRect, on dropReceiver: DropReceivable) {
        switch dropReceiver.targetType {
        case .new:
            dropReceiverAddNew.updateDropArea(with: dropArea)
        default:
            let index = dropReceiverToDo.firstIndex(where: {$0.targetType == dropReceiver.targetType})!
            dropReceiverToDo[index].updateDropArea(with: dropArea)
        }
    }
```

## ViewModifier: .dropReceiver(for:model:)

The `.dropReceiver` for the Add New button is _under_ the to-do list items. This demonstrates one of the values of this library, that, if desired, the drop receiver can be under other views.

```swift
    ZStack {
        Rectangle()
            .foregroundColor(.white)
            .dropReceiver(for: model.dropReceiverAddNew, model: model)
        VStack {
            Text("To Do List").font(.headline)
            ForEach(model.todoItems) { item in
                TodoListItemView(todoItem: item)
                    .dragable(...)
            }
    }
```

The other drop receivers are created in a ForEach loop:

```swift
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
```
