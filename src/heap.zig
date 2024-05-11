const std = @import("std");
const heap = @cImport({
    @cInclude("heapapi.h");
});

pub fn main() !void {
    std.debug.print("\nHeap memory: {any}", .{GetTotalHeapSize()});
}

pub fn GetTotalHeapSize() !u32 {
    const hHeap = heap.HANDLE;
    // Dim lpMem As Any Ptr
    // Dim dwFlags As DWORD
    const totalHeapSize: u32 = 0;
    const heapEntry = heap.PROCESS_HEAP_ENTRY;
    var success: u32 = 0;

    // Get the number of heaps in the process
    const numberOfHeaps = heap.GetProcessHeaps(0, null);
    std.debug.print("HEAP HANDE: {}\nTotal Heap Size: {any}\nHeap Entry: {any}\nSuccess: {any}\nNumber Of Heaps: {any}", .{ hHeap, totalHeapSize, heapEntry, success, numberOfHeaps });
    // // ' Create an array to hold the heap handles
    // Dim hHeaps() As HANDLE
    // ReDim hHeaps(numberOfHeaps - 1)
    // const hHeaps = [numberOfHeaps]heap.HANDLE;
    // const hHeaps = heap.HANDLE;

    // // ' Get the handles to all heaps in the process
    // heap.GetProcessHeaps(numberOfHeaps, &hHeaps);

    // ' Enumerate all heaps
    // for (0..numberOfHeaps) |u| {
    //     // ' Get a handle to the heap
    //     // hHeap = hHeaps(u);
    //     std.debug.print("{}: {}", .{ u, hHeap });

    //     // ' Initialize the heap entry structure
    //     // heapEntry.lpData = null;

    //     // ' Enumerate the memory blocks in the heap
    success = heap.HeapWalk(hHeap, &heapEntry);
    //     if (success) {
    //         // ' Check if it is a valid memory block
    //         if ((heapEntry.wFlags and heap.PROCESS_HEAP_ENTRY_BUSY) != 0) {
    //             // ' Get the size of the memory block
    //             totalHeapSize += heap.HeapSize(hHeap, 0, heapEntry.lpData);
    //         }
    //     } else {
    //         std.debug.print("Failed to walk the heap", .{});
    //     }
    // }

    return totalHeapSize;
}
// #include "windows.bi"

// // Function to get the total heap size
// Function GetTotalHeapSize() As ULong
//     Dim hHeap As HANDLE
//     Dim lpMem As Any Ptr
//     Dim dwFlags As DWORD
//     Dim totalHeapSize As ULong
//     Dim heapEntry As PROCESS_HEAP_ENTRY
//     Dim success As Integer

//     // ' Get the number of heaps in the process
//     Dim numberOfHeaps As DWORD
//     numberOfHeaps = GetProcessHeaps(0, NULL)

//     // ' Create an array to hold the heap handles
//     Dim hHeaps() As HANDLE
//     ReDim hHeaps(numberOfHeaps - 1)

//     // ' Get the handles to all heaps in the process
//     GetProcessHeaps(numberOfHeaps, @hHeaps(0))

//     // ' Enumerate all heaps
//     For i As Integer = 0 To numberOfHeaps - 1
//         // ' Get a handle to the heap
//         hHeap = hHeaps(i)

//         // ' Initialize the heap entry structure
//         heapEntry.lpData = NULL

//         // ' Enumerate the memory blocks in the heap
//         Do
//             success = HeapWalk(hHeap, @heapEntry)
//             If success Then
//                 // ' Check if it is a valid memory block
//                 If (heapEntry.wFlags And PROCESS_HEAP_ENTRY_BUSY) <> 0 Then
//                     // ' Get the size of the memory block
//                     totalHeapSize += HeapSize(hHeap, 0, heapEntry.lpData)
//                 End If
//             Else
//                 // ' If the enumeration fails, break out of the loop
//                 If GetLastError() <> ERROR_NO_MORE_ITEMS Then
//                     Print "Failed to walk the heap"
//                 End If
//                 Exit Do
//             End If
//         Loop
//     Next i

//     Return totalHeapSize
// End Function
