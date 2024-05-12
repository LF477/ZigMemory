// const c = @cImport({
//     @cInclude("heapapi.h");
// });

// const std = @import("std");

// pub fn GetTotalHeapSize() !u64 {
//     var totalHeapSize: u64 = 0;

//     const heapHandles: c.PHANDLE = undefined;
//     const heapCount: u32 = c.GetProcessHeaps(0, null);
//     const a = c.GetProcessHeaps(heapCount, heapHandles);
//     std.debug.print("{}, {}", .{ heapCount, a });
//     for (heapHandles) |heapHandle| {
//         var heapEntry: c.PROCESS_HEAP_ENTRY = .{ .lpData = null };
//         while (c.HeapWalk(heapHandle, &heapEntry)) |status| {
//             switch (status) {
//                 c.HEAP_ENTRY_BUSY => {
//                     totalHeapSize += @intCast(heapEntry.cbData);
//                 },
//                 else => {},
//             }
//         }
//     }

//     return totalHeapSize;
// }

// pub fn main() !void {
//     const totalHeapSize = try GetTotalHeapSize();
//     std.debug.print("Total Heap Size: {}\n", .{totalHeapSize});
// }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// const std = @import("std");
// const heap = @cImport({
//     // @cInclude("stdbool.h");
//     @cInclude("Windows.h");
//     @cInclude("tchar.h");
//     @cInclude("stdio.h");
//     @cInclude("intsafe.h");
// });

// pub fn main() !i8 {
//     var NumberOfHeaps:heap.DWORD = undefined;
//     // const HeapsIndex:heap.DWORD = undefined;
//     var HeapsLength:heap.DWORD = undefined;
//     var hDefaultProcessHeap:heap.HANDLE = undefined;
//     const aHeaps:heap.PHANDLE = undefined;
//     // const BytesToAllocate:heap.SIZE_T = NumberOfHeaps * @sizeOf(heap.PHANDLE);

//     //
//     // Retrieve the number of active heaps for the current process
//     // so we can calculate the buffer size needed for the heap handles.
//     //
//     NumberOfHeaps = heap.GetProcessHeaps(0, null);
//     if (NumberOfHeaps == 0) {
//         _ = heap._tprintf(heap.TEXT("Failed to retrieve the number of heaps with LastError %d.\n"),
//                  heap.GetLastError());
//         return 1;
//     }

//     //
//     // Get a handle to the default process heap.
//     //
//     hDefaultProcessHeap = heap.GetProcessHeap();
//     if (hDefaultProcessHeap == null) {
//         _ = heap._tprintf(heap.TEXT("Failed to retrieve the default process heap with LastError %d.\n"),
//                  heap.GetLastError());
//         return 1;
//     }

//     //
//     // Allocate the buffer from the default process heap.
//     //
//     // aHeaps = heap.HeapAlloc(hDefaultProcessHeap, 0, BytesToAllocate);
//     // if (aHeaps == null) {
//     //     _ = heap._tprintf(heap.TEXT("HeapAlloc failed to allocate %d bytes.\n"),
//     //              BytesToAllocate);
//     //     return 1;
//     // }

//     // 
//     // Save the original number of heaps because we are going to compare it
//     // to the return value of the next GetProcessHeaps call.
//     //
//     HeapsLength = NumberOfHeaps;

//     //
//     // Retrieve handles to the process heaps and print them to stdout. 
//     // Note that heap functions should be called only on the default heap of the process
//     // or on private heaps that your component creates by calling HeapCreate.
//     //
//     NumberOfHeaps = heap.GetProcessHeaps(HeapsLength, aHeaps);
    
//     _ = heap._tprintf(heap.TEXT("Process has %d heaps.\n"), HeapsLength);
//     for (0..HeapsLength) |HeapsIndex| {
//         _ = heap._tprintf(heap.TEXT("Heap %d at address: %#p.\n"),
//                  HeapsIndex,
//                  aHeaps[HeapsIndex]);
//     }
  
//     //
//     // Release memory allocated from default process heap.
//     //
//     if (heap.HeapFree(hDefaultProcessHeap, 0, aHeaps) == false) {
//         _ = heap._tprintf(heap.TEXT("Failed to free allocation from default process heap.\n"));
//     }

//     return 0;
// }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
const std = @import("std");
const heap = @cImport({
    // @cInclude("heapapi.h");
    // @cInclude("errhandlingapi.h");
    @cInclude("Windows.h");
});

pub fn main() !void {
    const size = GetTotalHeapSize();
    std.debug.print("\nHeap memory: {any}", .{size});
}

pub fn GetTotalHeapSize() !c_ulonglong {
    const hHeap: heap.HANDLE = heap.GetProcessHeap();
    const numberOfHeaps: c_ulong = heap.GetProcessHeaps(0, null);
    // var totalHeapSize: c_ulonglong = undefined;
    var heapEntry: heap.PROCESS_HEAP_ENTRY = undefined;
    var success: c_int = undefined;
    const memPointer: heap.HANDLE = heap.HeapAlloc(hHeap, 0, numberOfHeaps * @sizeOf(heap.PHANDLE));
    std.debug.print("K: {any}", .{memPointer});
    // heapEntry.lpData = null;
    success = heap.HeapWalk(memPointer, &heapEntry);
    std.debug.print("K: {any}", .{heapEntry});
    const totalHeapSize = heap.HeapSize(hHeap, 0, heapEntry.lpData);
    return totalHeapSize;
    // std.debug.print("K: {any}", .{numberOfHeaps});

    // ' Create an array to hold the heap handles
    // const hHeaps: heap.PHANDLE = undefined;
    // Dim hHeaps() As HANDLE
    // ReDim hHeaps(numberOfHeaps - 1)
    
    // ' Get the handles to all heaps in the process
    // numberOfHeaps = heap.GetProcessHeaps(numberOfHeaps, memPointer);

    // const hHeap: heap.HANDLE = heap.GetProcessHeap();
    // Dim lpMem As Any Ptr
    // Dim dwFlags As DWORD
    // var heapEntry: heap.PROCESS_HEAP_ENTRY = undefined;
    // const success = heap.HeapWalk(hHeap, &heapEntry);

    // Get the number of heaps in the process
    // // ' Create an array to hold the heap handles
    // Dim hHeaps() As HANDLE
    // ReDim hHeaps(numberOfHeaps - 1)
    // const hHeaps = [numberOfHeaps]heap.HANDLE;
    // const hHeaps: heap.PHANDLE = undefined;

    // // ' Get the handles to all heaps in the process
    // std.debug.print("Prev error: {any}\n", .{heap.GetLastError()});
    // const binded_heaps = heap.GetProcessHeaps(0, hHeaps);
    // std.debug.print("binded_heaps: {any}\n", .{binded_heaps});
    // ' Enumerate all heaps
    // for (0..numberOfHeaps) |u| {
    // ' Get a handle to the heap
    // std.debug.print("{any}", .{hHeaps});
    // hHeap = hHeaps[u];
    // std.debug.print("{}: {any}", .{ u, hHeap });

    // // ' Initialize the heap entry structure
    // heapEntry.lpData = null;

    // // ' Enumerate the memory blocks in the heap
    // success = heap.HeapWalk(hHeap, &heapEntry);
    // if (success) {
    //     // ' Check if it is a valid memory block
    //     if ((heapEntry.wFlags and heap.PROCESS_HEAP_ENTRY_BUSY) != 0) {
    //         // ' Get the size of the memory block
    //         totalHeapSize += heap.HeapSize(hHeap, 0, heapEntry.lpData);
    //     }
    // } else {
    //     std.debug.print("Failed to walk the heap", .{});
    // }
    // }

}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
