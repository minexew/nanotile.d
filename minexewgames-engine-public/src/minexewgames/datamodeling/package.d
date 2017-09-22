/*
@AcceptChildren!(Brush, Corridor, Entity)
class Area {
    // attributes
    ivec2 size;
}

struct Brush {
    enum Shape {
        rectangle,
        ellipse
    }
    
    // attributes
    Shape shape;
    ivec3 begin, end;
}

struct Corridor {
    // attributes
    ivec3 begin, end;
}

struct Entity {
    // attributes
    string name;
    ivec3 pos;
}

void visit

//
template(Visitor, Args...)
void readDocument(Visitor v, Node document, Args args) {
    foreach (child; document) {
        switch (child.name) {
            case "Area":
                parse!Area(v, child, args);
                break:
        }
    }
}

template (T) parse(Visitor v, Node node) {
    T data;
    foreach allMembers, T {
        if enum {
        }
        
        if oneOf {
        }
        
        if array {
        }
    }
    v(u)
}*/