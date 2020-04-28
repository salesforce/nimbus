package com.salesforce.nimbus.k2v8

internal fun <T> List<T>.valueAtIndex(valueForIndex: (Int) -> T): Boolean {
    return indices.all { index -> get(index) == valueForIndex(index) }
}

internal fun <T, R> List<T>.valueAtIndex(transformValue: (T) -> R, valueForIndex: (Int) -> R): Boolean {
    return indices.all { index -> transformValue(get(index)) == valueForIndex(index) }
}

internal fun <K, V> Map<K, V>.valueForKey(valueForKey: (K) -> V): Boolean {
    return entries.all { (key, value) -> value == valueForKey(key) }
}

internal fun <K, V, R> Map<K, V>.valueForKey(transformKey: (K) -> R, valueForKey: (R) -> V): Boolean {
    return entries.all { (key, value) -> value == valueForKey(transformKey(key)) }
}
