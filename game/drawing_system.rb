module DrawingSystem
  class << self
    def init!
      Entity.find("player").set(
        tile_index: 0)

      Entity.find("window").set(
        render_children: [],
        grid_size:  Size[32,32],
        size_tiles: Size[25,18])

      tiles = Gosu::Image.load_tiles(
          RES_DIR.join("tiled-icons-16x16.png").to_s, 
          16, 16,
          retro: true)

      tiles.each_with_index do |img, ix|
        # Create an Entity for each tile
        Entity.new(tile_index: ix, 
                   tile_image: img,
                   scale:      Vector[2,2])
      end
    end

    def draw!
      window = Entity.find("window")
      
      window.render_children.each do |child|
        modname, methname = child.render_with.split("#")
        mod = Object.const_get(modname)
        meth = mod.method(methname)
        meth.call
      end
    end
  end
end
