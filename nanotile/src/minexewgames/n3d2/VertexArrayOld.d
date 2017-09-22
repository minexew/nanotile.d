module minexewgames.n3d2.VertexArray__;

import std.stdint;
import std.stdio;
import std.c.stdlib;

class VertexArr__ay(T) {
    this() {
        this.elements = null;
        this.capacity = 0;
        this.used = 0;
    }
    
    ~this() {
        free(elements);
    }
    
    T* add(size_t count) {
        reserve((used + count) * T.sizeof);
        
        T* ptr = elements + used;
        used += count;
        return ptr;
    }
    
    void clear() {
        used = 0;
    }
    
    void reserve(size_t capacity) {
        if (capacity > this.capacity) {
            if (capacity < 4096)
                this.capacity = toPowerOf2(capacity);
            else
                this.capacity = alignValue!4096(capacity);
                
            elements = cast (T*) realloc(elements, this.capacity);
        }
    }
    
    T* elements;
    size_t capacity, used;
}