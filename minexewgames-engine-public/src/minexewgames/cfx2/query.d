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

module minexewgames.cfx2.query;

import minexewgames.cfx2.lexer;
import minexewgames.cfx2.node;

import std.conv;

class Query {
    static Object processCommandAttrib(Node base, string command, int allowModifications) {
        size_t pos = 0;
        Attrib attrib;
    
        /* Read an identifier form the command string. */
        while (pos != command.length && isIdentChar(command[pos]))
            pos++;
        
        if (pos != command.length) {
            switch (command[pos]) {
                case ':':
                case '/':
                case '.':
                    break;
    
                default:
                    return null;
            }
        }
    
        attrib = base.findAttrib(command[0..pos]);
    
        if (attrib is null) {
            /*
                FIXME: Must be an assignment??
                The requested attribute does not exist.
                We'll try to create it then.
                If we aren't allowed to do so, we return NULL.
            */
    
            if (allowModifications) {
                attrib = new Attrib;
                base.attributes ~= attrib;
            }
            else
                return null;
        }
    
        if (pos == command.length || command[pos] == 0)
            return attrib;
        else if (command[pos] == ':' && allowModifications) {
            attrib.text = command[pos + 1..$];
            return attrib;
        }
        else
            return null;
    }

    static Object processCommand(Node base, string command, bool allowModifications) {
        size_t pos = 0;
        Node child;
    
        /* Read an identifier form the command string. */
        while (pos != command.length && isIdentChar(command[pos]))
            pos++;
    
        if (pos != command.length) {
            switch (command[pos]) {
                case ':':
                case '/':
                case '.':
                    break;
    
                default:
                    return null;
            }
        }
    
        if (pos == 0)
            child = base;
        else
            child = base.findChild(command[0..pos]);
    
        if (child is null) {
            /*
                The requested node does not exist.
                We'll try to create it then.
                If we aren't allowed to do so, we return NULL.
            */
    
            if (allowModifications) {
                child = new Node;
                base.children ~= child;
            }
            else
                return null;
        }
    
        if (pos == command.length || command[pos] == 0)
            return child;
        else if (command[pos] == '/')
            return processCommand(child, command[pos + 1..$], allowModifications);
        else if (command[pos] == '.')
            return processCommandAttrib(child, command[pos + 1..$], allowModifications);
        else if (command[pos] == ':' && allowModifications) {
            child.text = command[pos + 1..$];
            return child;
        }
        else
            return null;
    }
    
    alias processCommand query;
    
    static string queryValue(Node base, string command) {
        Object result = query(base, command, false);

        if (Node node = cast(Node) result)
            return node.text;
        else if (Attrib attrib = cast(Attrib) result)
            return attrib.value;
        else
            return null;
    }
    
    static T queryValueAs(T)(Node base, string command) {
        return to!T(queryValue(base, command));
    }
}