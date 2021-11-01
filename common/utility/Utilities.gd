extends Node

func pool_string_array_find(array: PoolStringArray, searchString: String, start: int = 0) -> int:
    for i in range(len(array)):
        if i < start:
            continue
        var currentString = array[i]
        if currentString == searchString:
            return i
    return -1

func printNodeNames(array):
    for arr in array:
        print(arr.name)

func printArray(array):
    for arr in array:
        print(arr)
