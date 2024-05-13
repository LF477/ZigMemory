const std = @import("std");
const heap = @cImport({
    @cInclude("Windows.h");
});

pub fn main() !void {

}

pub fn GetTotalHeapSize() c_ulonglong {
    var hHeap: heap.HANDLE = undefined;
    var totalHeapSize: c_ulonglong = undefined;
    var heapEntry: heap.PROCESS_HEAP_ENTRY = undefined;
    var success: c_int = undefined;

    // ' Get the number of heaps in the process
    const numberOfHeaps = heap.GetProcessHeaps(0, null);

    // ' Create an array to hold the heap handles
    var hHeaps: [2000]heap.HANDLE = undefined;
    // ReDim hHeaps(numberOfHeaps - 1)

    // ' Get the handles to all heaps in the process
    _ = heap.GetProcessHeaps(numberOfHeaps, &hHeaps[0]);
    // ' Enumerate all heaps
    for (0..numberOfHeaps) |i|{
        // ' Get a handle to the heap
        hHeap = hHeaps[i];

        // ' Initialize the heap entry structure
        heapEntry.lpData = null;

        // ' Enumerate the memory blocks in the heap
            success = heap.HeapWalk(hHeap, &heapEntry);
            if (success == 1) {
                // ' Check if it is a valid memory block
                if (heapEntry.wFlags == 1 and heap.PROCESS_HEAP_ENTRY_BUSY == 1) {
                    // ' Get the size of the memory block
                    totalHeapSize += heap.HeapSize(hHeap, 0, heapEntry.lpData);
                }
            }
            else {
                // ' If the enumeration fails, break out of the loop
                if (heap.GetLastError() != heap.ERROR_NO_MORE_ITEMS) {
                    std.debug.print("Failed to walk the heap", .{}); 
                }
            }
    }
    return totalHeapSize;
}