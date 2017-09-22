module minexewgames.n3d2.Camera;

import minexewgames.framework.types;

import dlib.math.affine;

import std.math;
import std.stdio;

enum Projection {
    ortho,
    screenSpaceOrtho,
    perspective
}

// FIXMEEEEEeeeeEEEEeeeEEE
enum gl_renderViewport_x = 1280;
    enum gl_renderViewport_y = 720;

class Camera {
    Projection proj;
    vec3 eye, center, up;
    
    float hfov, vfov;                   // persp
    float left, right, top, bottom;     // ortho
    
    float nearZ, farZ;

    mat4 projection, modelView;

    static void convert( float dist, float angle, float angle2, out vec3 eye, out vec3 center, out vec3 up )
    {
        float ca = cos( angle );
        float sa = sin( angle );
    
        float ca2 = cos( angle2 );
        float sa2 = sin( angle2 );
    
        float radius = ca2 * dist;
        float upRadius = radius - sa2;
    
        immutable vec3 cam = vec3( ca * radius, -sa * radius, sa2 * dist );
    
        eye = center + cam;
        up = vec3( ca * upRadius - cam.x, -sa * upRadius - cam.y, ca2 );
    }
    
    static void convert( const ref vec3 eye, const ref vec3 center, const ref vec3 up,
            out float dist, out float angle, out float angle2 )
    {
        immutable vec3 cam = eye - center;
    
        dist = length( cam );
        angle = atan2( -cam.y, cam.x );
        angle2 = atan2( cam.z, length( vec2( cam ) ) );
    }

    void buildModelView()
    {
        modelView = lookAtMatrix( vec3( eye.x, -eye.y, eye.z ), vec3( center.x, -center.y, center.z ),
                vec3( up.x, -up.y, up.z ) );

        modelView = scale( modelView, vec3( 1.0f, -1.0f, 1.0f ) );
    }
    
    float cameraGetDistance()
    {
        return length( eye - center );
    }
    
    void cameraMove( const ref vec3 vec )
    {
        eye += vec;
        center += vec;
        buildModelView();
    }
    
    void cameraRotateXY( float alpha, bool absolute )
    {
        float dist, angle, angle2;
    
        convert( eye, center, up, dist, angle, angle2 );
    
        if ( absolute )
            angle2 = alpha;
        else
            angle2 += alpha;
    
        convert( dist, angle, angle2, eye, center, up );
        buildModelView();
    }
    
    void cameraRotateZ(float alpha, bool absolute)
    {
        float dist, angle, angle2;
    
        convert( eye, center, up, dist, angle, angle2 );
    
        if ( absolute )
            angle = alpha;
        else
            angle += alpha;
    
        convert( dist, angle, angle2, eye, center, up );
        buildModelView();
    }
    
    void cameraZoom(float amount, bool absolute)
    {
        float dist, angle, angle2;
    
        convert( eye, center, up, dist, angle, angle2 );
        
        if ( absolute )
            dist = amount;
        else if ( dist + amount > 0.0f )
            dist += amount;
    
        convert( dist, angle, angle2, eye, center, up );
        buildModelView();
    }
    
    void setUpMatrices(out mat4 projectionModelView)
    {
        final switch (proj)
        {
            case Projection.ortho:
                projection = orthoMatrix(left, right, bottom, top, nearZ, farZ);
                modelView = mat4x4().identity;
                break;
    
            case Projection.screenSpaceOrtho:
                projection = orthoMatrix(0.0f, cast(float) gl_renderViewport_x, cast(float) gl_renderViewport_y, 0.0f, nearZ, farZ);
                modelView = mat4x4().identity;
                break;
    
            case Projection.perspective:
                projection = frustumMatrix(-hfov, hfov, -vfov, vfov, nearZ, farZ);
                break;
        }

        projectionModelView = projection * modelView;
    }
    
    void setOrtho(float left, float right, float top, float bottom, float nearZ, float farZ)
    {
        proj = Projection.ortho;
        this.left = left;
        this.right = right;
        this.top = top;
        this.bottom = bottom;
        this.nearZ = nearZ;
        this.farZ = farZ;
    }
    
    void setOrthoScreenSpace(float nearZ, float farZ)
    {
        proj = Projection.screenSpaceOrtho;
        this.nearZ = nearZ;
        this.farZ = farZ;
    }
    
    void setPerspective(float nearClip, float farClip) {
        proj = Projection.perspective;
        this.nearZ = nearClip;
        this.farZ = farClip;
    }
    
    void setVFov(float vfov)
    {
        immutable float aspect = cast(float) gl_renderViewport_x / gl_renderViewport_y;
    
        this.vfov = cast( float )( nearZ * tan(vfov / 2.0f) );
        this.hfov = this.vfov * aspect;
    }
    
    void setView(vec3 eye, vec3 center, vec3 up)
    {
        this.eye = eye;
        this.center = center;
        this.up = up;
        buildModelView();
    }
}
