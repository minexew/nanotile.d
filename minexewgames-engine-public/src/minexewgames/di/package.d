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

module minexewgames.di;

public import minexewgames.di.annotationAwareNew;
public import minexewgames.di.annotations;
public import minexewgames.di.core;

alias DefaultInstanceCreator = BasicInstanceCreatorWithTemplatedManager;
alias DefaultInstanceManager = DefaultInstanceCreator.InstanceManager;

// annotationAwareNew with default Manager and Creator
template diNewBlueprint(T, Args...) {
    alias diNewBlueprint = annotationAwareNew!(DefaultInstanceManager, T, Args);
}

// =============================================================================

// see diGet
T diNew(T, Args...)(auto ref Args args) {
    return diNewBlueprint!(T, Args)(args);
}

// see diCreator, diProvidedBy
void diInject(T)(T inst, bool overwrite = false) {
    DefaultInstanceManager.inject!T(inst, overwrite);
}

// preferred over diNew (unless multiple instances are desired)
T diGet(T)() {
    return DefaultInstanceManager.get!T();
}

// preferred over diInject
void diCreator(T)(T function() createInstance, bool overwrite = false) {
    DefaultInstanceManager.creator!T(createInstance, overwrite);
}

// preferred over diInject
void diProvidedBy(T, TImpl)(bool overwrite = false) {
    static assert(!is(T == TImpl));
    
    DefaultInstanceManager.creator!T(() => cast(T) diGet!TImpl, overwrite);
}

version (unittest) {
    class Abc {
        int value;
    }
    
    class UsesAbc {
        @Autowired
        Abc abc;
        
        @Initializer
        void init() {
            assert(abc !is null);
        }
    }
    
    class NonEmptyInitializer {
        int value;
        
        @Initializer
        void init(int value) {
            this.value = value;
        }
    }
    
    class NoDefaultConstructor_NoDIForMe {
        this (int somerequiredparam) {
        }
        
        @Initializer
        void init() {
            assert(false);
        }
    }
    
    interface MyInterface {
    }
    
    class MyImplementation : MyInterface {
    }
}

unittest {
    // Test diNew
    UsesAbc ua1 = diNew!UsesAbc;
    UsesAbc ua2 = diNew!UsesAbc;
    
    ua1.abc.value = 77;
    assert(ua2.abc.value == 77);
    
    // Test that diGet returns the same object
    assert((diGet!Abc).value == 77);
    
    (diGet!Abc).value = 13;
    assert((diGet!Abc).value == 13);
    
    diNew!NonEmptyInitializer(42);

    try {
        diGet!MyInterface;
        assert(false);
    } catch (InstanceNotProvidedException ex) {
    }
    
    // Provide implementation for the interface
    diProvidedBy!(MyInterface, MyImplementation);
    
    // Implementation provided now
    diGet!MyInterface;
    
    try {
        // Error - overwriting disabled by default
        diInject!MyInterface(new MyImplementation);
        assert(false);
    } catch (InstanceOverwriteException ex) {
    }
    
    // Explicitly overwrite existing instance
    diInject!MyInterface(new MyImplementation, true);
    
    // Can't be instantiated by annotationAwareNew
    try {
        diGet!NoDefaultConstructor_NoDIForMe;
    } catch (InstanceNotProvidedException ex) {
    }
    
    diInject(new NoDefaultConstructor_NoDIForMe(15));
    diGet!NoDefaultConstructor_NoDIForMe;
}
