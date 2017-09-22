module minexewgames.ntile.MainMenu;

import minexewgames.di;
import minexewgames.engine;
//import minexewgames.framework.stream;

import minexewgames.ntile.Resources;
import minexewgames.ntile.WorldBlockGenerator;
import minexewgames.ntile.WorldBlocks;
import minexewgames.ntile.WorldGeom;

import minexewgames.n3d2;

class MainMenu : Scene {
    @Autowired InputInterface input;

    @Autowired Renderer r;
    @Autowired RenderingState rs;
    @Autowired Primitives pr;

    @Autowired Logger logger;

    // Resources
    @Recipe("path=ntile/fonts/fat.zmf,scale=8")
    BitmapFont title;
    
    @Recipe("path=ntile/fonts/fat.zmf,scale=4")
    BitmapFont subtitle;

    @Recipe(FontRecipe.regular)
    BitmapFont regular;

    @Autocreated
    Camera worldCam;
    
    WorldGeom wg;
    WorldBlocks wb;

    float dist = 500.0f;
    float x = 16.0f * 16.0f * 2;
    float y = 16.0f * 16.0f * 2;

    @Initializer
    void init() {
        logger.log(LogLevel.debugInfo, "MainMenu", "init() called!");
        
        wb = diNew!WorldBlocks;
        
        // World Generation
        WorldBlockGenerator gen = diNew!WorldBlockGenerator(wb);
        gen.generate("ntile_src/maps/kyria/shiroi/blocks.cfx2");
        
        wg = diNew!WorldGeom(wb);
        
        wg.clusters = new WorldGeomCluster[][1];
        wg.clusters[0] = new WorldGeomCluster[1];
        wg.clusters[0][0] = diNew!WorldGeomCluster(wg);
        wg.clusters[0][0].intializeTilesInCluster();
        
        // Cam for world
        worldCam.setPerspective(200.0f, 800.0f);
        worldCam.setVFov(45.0f * 3.14f / 180.0f);
        
        // Cam for UI
        auto cam = r.getImmedCamera();
        cam.setOrthoScreenSpace(-1.0f, 1.0f);
        
        rs.setVariable(RenderingStateVariable.culling, 1);
    }

    override void onDraw() {
        r.clear();
        
        //pr.fillRect(vec2(100, 100), vec2(1024, 32), RGBA.red);
        
        rs.setVariable(RenderingStateVariable.depthTest, 1);
        rs.setVariable(RenderingStateVariable.blendMode, BlendMode.alpha);

        static vec3 dir = vec3(0.0f, 1.0f, 1.0f).normalized();
        worldCam.setView(vec3(x, y, 0.0f) + dir * dist, vec3(x, y, 0.0f), vec3(0.0f, -dir.z, dir.y));
        
        wg.draw(worldCam);
        
        //x += 2f;
        //if (x >1024.0f)
        //x = 0.0f; 
        
        rs.setVariable(RenderingStateVariable.depthTest, 0);
        //rs.setVariable(RenderingStateVariable.blendMode, BlendMode.subtract);
        
        title.drawText(640, 340, Align.hcenter | Align.bottom, "NANOTILE", greyRGBA(0x11));
        subtitle.drawText(640, 340, Align.hcenter | Align.top, "QUEST OF KYRIA", greyRGBA(0x55));
        
        regular.drawText(640, 700, Align.hcenter | Align.bottom, "Minexew Games 2014", greyRGBA(0xBB));
        
        r.flush();
    }

    override void onFrame() {
        VkeyState_t vk;

        if (input.getVkeyEventPrelim(&vk)) {
            if (vk.vkey.type == VKEY_SPECIAL && vk.vkey.key == SPECIAL_CLOSE_WINDOW)
                (diGet!MainLoop).stop();
        }
    }
}
