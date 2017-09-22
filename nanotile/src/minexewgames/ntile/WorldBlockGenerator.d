module minexewgames.ntile.WorldBlockGenerator;

import minexewgames.cfx2;
import minexewgames.di;
import minexewgames.engine;
import minexewgames.framework.types;

import minexewgames.ntile.WorldBlocks;

import core.stdc.stdlib;

class WorldBlockGenerator {
    @Autowired FileSystem fs;
    
    WorldBlocks wb;
    
    @Initializer
    void init(WorldBlocks world) {
        this.wb = world;
    }
    
    void generate(string path) {
        Node doc = Reader.loadDocument(path, fs.openInput(path));
        
        wb.worldSize = Query.queryValueAs!ivec2(doc, "Area.size");
        assert(wb.worldSize == ivec2(4, 4));
        
        wb.blocks = new WorldBlock*[wb.worldSize.x * wb.worldSize.y];
        
        for (int i = 0; i < wb.worldSize.x * wb.worldSize.y; i++)
            wb.blocks[i] = new WorldBlock;
            
        for (int i = 0; i < wb.worldSize.x * wb.worldSize.y; i++)
            WorldBlockGenerator.generateBlockTiles(wb.blocks[i]);
            
        //foreach (child; doc) {
            //
        //}
    }
    
    static void generateBlockTiles(WorldBlock* block) {
        WorldTile* p_tile = &block.tiles[0][0];

        for (int i = 0; i < BLOCK_WIDTH * BLOCK_HEIGHT; i++) {
            //switch (block.type) {
            //    case BLOCK_SHIROI:
                    p_tile.type = 0;
                    p_tile.flags = 0;
                    p_tile.elev = 24 + (rand() % 8);    // just no.
                    p_tile.material = 0;
                    p_tile.colour[0] = 0xFF;
                    p_tile.colour[1] = 0xFF;
                    p_tile.colour[2] = 0xFF;
            //        break;

                /*case BLOCK_WORLD:
                    p_tile.type = 1;
                    p_tile.flags = 0;
                    p_tile.elev = -2 + (rand() % 5);
                    p_tile.material = 0;
                    p_tile.colour[0] = 0xFF;
                    p_tile.colour[1] = 0xFF;
                    p_tile.colour[2] = 0xFF;
                    break;*/
         //   }

            p_tile++;
        }
    }
}