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

module minexewgames.di.Proxy;

import minexewgames.di.reflection;

import std.traits;

template InterfacesTupleOrThisIfInterface(T) {
    static if (is(T == interface))
        alias InterfacesTupleOrThisIfInterface = T;
    else
        alias InterfacesTupleOrThisIfInterface = InterfacesTuple!T;
}

// magic by Danol
final class Proxy(T) : InterfacesTupleOrThisIfInterface!T {
    private template MethodDeclArguments(Class, string methodName, overload,
            string argName, args...) {
        static if (args.length > 0) {
            alias arg = args[0];
            // FIXME: use ReturnType?
            enum argDecl = fullyQualifiedName!arg ~ " " ~ argName;

            static if (args.length > 1)
                enum MethodDeclArguments = argDecl ~ ", "
                    ~ MethodDeclArguments!(Class, methodName, overload, argName ~ "a", args[1..$]);
            else
                enum MethodDeclArguments = argDecl;
        }
        else
            enum MethodDeclArguments = "";
    }

    private template MethodArguments(Class, string methodName, overload,
            string argName, args...) {
        static if (args.length > 0) {
            alias arg = args[0];

            static if (args.length > 1)
                enum MethodArguments = argName ~ ", "
                    ~ MethodArguments!(Class, methodName, overload, argName ~ "a", args[1..$]);
            else
                enum MethodArguments = argName;

        }
        else
            enum MethodArguments = "";
    }

    private template MethodOverloads(Class, string methodName, overloads...) {
        static if (overloads.length > 0) {
            alias overload = overloads[0];
            enum decl =
                // return type
                fullyQualifiedName!(ReturnType!overload)
                // method name
                ~ " " ~ methodName
                // argument list
                ~ "(" ~ MethodDeclArguments!(Class, methodName, overload, "a", ParameterTypeTuple!overload) ~ ")"
                // proxy method body
                ~ " {\n"
                ~ "\treturn inst." ~ methodName ~ "("
                ~ MethodArguments!(Class, methodName, overload, "a", ParameterTypeTuple!overload) ~ ");\n"
                ~ "}\n";

            static if (overloads.length > 1)
                enum MethodOverloads = decl ~ " " ~ MethodOverloads!(Class, methodName, overloads[1..$]);
            else
                enum MethodOverloads = decl;

        }
        else
            enum MethodOverloads = " ";
    }

    private template ClassMembers(Class, members...) {
        static if (members.length > 0) {
            enum member = members[0];
            enum decl = MethodOverloads!(Class, member, typeof(__traits(getOverloads, Class, member)));

            static if (members.length > 1)
                enum ClassMembers = decl ~ " " ~ ClassMembers!(Class, members[1..$]);
            else
                enum ClassMembers = decl;

        }
        else
            enum ClassMembers = " ";
    }

    private template ClassAndInterfaces(Class, interfaces...) {
        enum decl = ClassMembers!(Class, __traits(allMembers, Class));

        static if (interfaces.length)
            enum ClassAndInterfaces = decl ~ " " ~ ClassAndInterfaces!interfaces;
        else
            enum ClassAndInterfaces = decl;
    }

    T inst;

    this(T inst = null) {
        this.inst = inst;
    }

    T instance() {
        return inst;
    }

    void instance(T inst) {
        this.inst = inst;
    }
    
    mixin(ClassAndInterfaces!T);
}
