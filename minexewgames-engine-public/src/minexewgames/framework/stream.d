/*
    Boost Software License - Version 1.0 - August 17th, 2003
    
    Permission is hereby granted, free of charge, to any person or organization
    obtaining a copy of the software and accompanying documentation covered by
    this license (the "Software") to use, reproduce, display, distribute,
    execute, and transmit the Software, and to prepare derivative works of the
    Software, and to permit third-parties to whom the Software is furnished to
    do so, all subject to the following:
    
    The copyright notices in the Software and this entire statement, including
    the above license grant, this restriction and the following disclaimer,
    must be included in all copies of the Software, in whole or in part, and
    all derivative works of the Software, unless such copies or derivative
    works are solely in the form of machine-executable object code generated by
    a source language processor.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
    SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
    FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
*/

module minexewgames.framework.stream;

public import dlib.core.stream;

import std.stdint;
import undead.stream;

class StdStreamWrapper : minexewgames.framework.stream.IOStream {
    this(undead.stream.Stream input) {
        this.input = input;
    }
    
    override void close() {
        input.close();
    }
    
    override bool readable() {
        return input.readable;
    }
    
    override bool writeable() {
        return input.writeable;
    }
    
    override size_t readBytes(void* buffer, size_t count) {
        return input.readBlock(buffer, count);
    }
    
    override size_t writeBytes(const void* buffer, size_t count) {
        return input.writeBlock(buffer, count);
    }
    
    override void flush() {
    }
    
    override bool seekable() {
        return true;
    }
    
    override uint64_t getPosition() {
        return input.position();
    }
    
    override bool setPosition(uint64_t pos) {
        return input.seek(pos, SeekPos.Set) == pos;
    }
    
    override uint64_t size() {
        return input.size();
    }
    
    undead.stream.Stream input;
}

interface OpenFile {
    IOStream openFile(string fileName, bool readOnly, bool create);
}

class StdOpenFile : OpenFile {
    IOStream openFile(string fileName, bool readOnly, bool create) {
        try {
            if (create)
                return new StdStreamWrapper(new undead.stream.File(fileName, FileMode.In | FileMode.OutNew));
            else if (!readOnly) {
                // will throw if doesn't exist
                new undead.stream.File(fileName, FileMode.In).close();

                return new StdStreamWrapper(new undead.stream.File(fileName, FileMode.In | FileMode.Out));
            }
            else
                return new StdStreamWrapper(new undead.stream.File(fileName, FileMode.In));
        } catch (Exception ex) {
            return null;
        }
    }
}