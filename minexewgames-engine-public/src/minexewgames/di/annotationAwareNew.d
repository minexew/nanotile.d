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

module minexewgames.di.annotationAwareNew;

import minexewgames.di.annotations;
import minexewgames.di.diag;
import minexewgames.di.reflection;

import std.array;
import std.conv;
import std.stdio;
import std.traits;
import std.typetuple;

template CopyAnnotated(Class, string classAsString, MethodAnnotation) {
    string[] getInitializerList() {
        string wrappers[];

        foreach (member; __traits(allMembers, Class)) {
            foreach (int i, overload; __traits(getOverloads, Class, member)) {
                static if (staticIndexOf!(MethodAnnotation, TypeTuple!(__traits(getAttributes, overload))) != -1) {
                    enum overloadAsString = "__traits(getOverloads, " ~ classAsString ~ ", \""
                        ~ member ~ "\")[" ~ to!string(i) ~ "]";
                    enum overloadAsStringInst = "__traits(getOverloads, inst, \""
                        ~ member ~ "\")[" ~ to!string(i) ~ "]";

                    enum returnType = "ReturnType!(" ~ overloadAsString ~ ")";
                    enum argsDecl = MethodArguments!(overload, overloadAsString).declare("arg_");
                    enum argsList = MethodArguments!(overload, overloadAsString).list("arg_");

                    enum argsSuffix = argsDecl.empty ? "" : ", " ~ argsDecl;
                    enum return_ = !is(ReturnType!overload == void) ? "return " : "";

                    wrappers ~= "static " ~ returnType ~ " m(" ~ classAsString ~ " inst" ~ argsSuffix ~ ") {\n"
                        ~ "    " ~ return_ ~ overloadAsStringInst ~ "(" ~ argsList ~ ");\n"
                        ~ "}";
                }
            }
        }

        return wrappers;
    }

    string toString() {
        string[] initializers = getInitializerList();

        if (!initializers.empty) {
            string list;

            foreach (i; initializers)
                list ~= i ~ "\n";

            return list;
        }
        else
            return "";
    }
}

class FilteredProxy(Class, Annotation) {
    enum methodProxies = CopyAnnotated!(Class, "Class", Annotation).toString;
    mixin(methodProxies);

    enum empty = methodProxies.empty;
}

T annotationAwareNew(InstanceManager, T, Args...)(ref Args args) {
    diagprint("annotationAwareNew for " ~ to!string(typeid(T)) ~ " using "
        ~ to!string(typeid(InstanceManager)));

    // TODO: is there a clean way to allocate without constructing,
    //       so that we could inject even earlier?
    T inst = new T();

    // annotatedMemberInjection
    foreach (member; __traits(allMembers, T)) {
        static if (__traits(getProtection, __traits(getMember, T, member)) == "public") {
            foreach (attr; __traits(getAttributes, __traits(getMember, T, member))) {
                static if (__traits(compiles, attr.annotatedMemberInjection)) {
                    attr.annotatedMemberInjection!InstanceManager
                            (inst, member, &__traits(getMember, inst, member));
                }
            }
        }
    }

    // annotatedMember
    foreach (member; __traits(allMembers, T)) {
        static if (__traits(getProtection, __traits(getMember, T, member)) == "public") {
            foreach (attr; __traits(getAttributes, __traits(getMember, T, member))) {
                static if (__traits(compiles, attr.annotatedMember)) {
                    attr.annotatedMember
                            (inst, member, &__traits(getMember, inst, member), args);
                }
            }
        }
    }

    // call @Initializer, if present
    alias initializer = FilteredProxy!(T, Initializer);
    //writeln(initializer.methodProxies);

    static if (!initializer.empty)
        initializer.m(inst, args);

    return inst;
}
