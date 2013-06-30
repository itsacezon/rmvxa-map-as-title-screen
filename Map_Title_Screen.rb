#==============================================================================
#   ** Map as Title Screen v1.1
#   Author: Acezon
#   Date: 16 June 2013
#------------------------------------------------------------------------------
#   Version 1.1
#   - Merged with the Yami TD compatible script
#   - Now compatible with Khas's Awesome Light Effects script
#   Version 1.0
#   - Initial Release
#------------------------------------------------------------------------------
#   Just credit me. Free to use for commercial/non-commercial games.
#==============================================================================

$imported = {} if $imported.nil?
$imported["Acezon-MapTitleScreen"] = true

#==============================================================================
# ** START Configuration
#==============================================================================
module Config
  # The id of the map you want the title to be displayed.
  Starting_Map_ID = 1

  # Character's position (though he/she is invisible)
  # This feature is useful for large maps.
  X_Pos = 7
  Y_Pos = 6
end
#==============================================================================
# ** END Configuration
#==============================================================================

#==============================================================================
# ** Scene_Title
#==============================================================================
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  def start
    SceneManager.call(Scene_MapTitle)
  end
  #--------------------------------------------------------------------------
  # * Terminate
  #--------------------------------------------------------------------------
  def terminate
    SceneManager.snapshot_for_background
    Graphics.fadeout(Graphics.frame_rate)
  end
end

#==============================================================================
# ** Scene_MapTitle
#==============================================================================
class Scene_MapTitle < Scene_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor   :character_name           # character graphic filename
  attr_accessor   :character_index          # character graphic index
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  def start
    DataManager.create_game_objects
    $game_party.setup_starting_members
    $game_map.setup(Config::Starting_Map_ID)
    $game_player.moveto(Config::X_Pos, Config::Y_Pos)
    $game_player.followers.visible = false
    $game_player.refresh
    $game_player.make_encounter_count

    @character_name = $game_player.character_name
    @character_index = $game_player.character_index
    $game_player.set_graphic('', 0)

    $game_system.menu_disabled = true
    Graphics.frame_count = 0

    super
    create_foreground
    create_background
    create_command_window
    play_title_music
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    # Yami's Title Decoration Compatibility Scriptlet
    if $imported["YSE-TD-VerticalCommand"]
      @command_sprite.each { |sprite|
        sprite.update
        @command_window.index == sprite.id ? sprite.activate : sprite.deactivate
      }
    end

    update_basic
    @spriteset.update
    $game_map.update(true)
    update_scene if scene_change_ok?
  end
  #--------------------------------------------------------------------------
  # * Determine if Debug Call by F9 key
  #--------------------------------------------------------------------------
  def update_call_debug
    # do nothing
  end
  #--------------------------------------------------------------------------
  # * Get Transition Speed
  #--------------------------------------------------------------------------
  def transition_speed
    return 20
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_background
    dispose_foreground
    dispose_command_sprite if $imported["YSE-TD-VerticalCommand"]
    SceneManager.snapshot_for_background
  end
  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    @sprite1 = Sprite.new
    @sprite1.bitmap = Cache.title1($data_system.title1_name)
    @sprite2 = Sprite.new
    @sprite2.bitmap = Cache.title2($data_system.title2_name)
    center_sprite(@sprite1)
    center_sprite(@sprite2)
  end
  #--------------------------------------------------------------------------
  # * Create Foreground
  #--------------------------------------------------------------------------
  def create_foreground
    @foreground_sprite = Sprite.new
    @foreground_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @foreground_sprite.z = 100
    draw_game_title if $data_system.opt_draw_title
  end
  #--------------------------------------------------------------------------
  # * Draw Game Title
  #--------------------------------------------------------------------------
  def draw_game_title
    @foreground_sprite.bitmap.font.size = 48
    rect = Rect.new(0, 0, Graphics.width, Graphics.height / 2)
    @foreground_sprite.bitmap.draw_text(rect, $data_system.game_title, 1)
  end
  #--------------------------------------------------------------------------
  # * Free Background
  #--------------------------------------------------------------------------
  def dispose_background
    @sprite1.bitmap.dispose
    @sprite1.dispose
    @sprite2.bitmap.dispose
    @sprite2.dispose
  end
  #--------------------------------------------------------------------------
  # * Free Foreground
  #--------------------------------------------------------------------------
  def dispose_foreground
    @foreground_sprite.bitmap.dispose
    @foreground_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Move Sprite to Screen Center
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_TitleCommand.new
    @command_window.set_handler(:new_game, method(:command_new_game))
    @command_window.set_handler(:continue, method(:command_continue))
    @command_window.set_handler(:shutdown, method(:command_shutdown))

    if $imported["YSE-TD-VerticalCommand"]
      @command_window.y = Graphics.height
      @command_sprite = []
      i = 0
      @command_window.symbol_list.each { |symbol|
        sprite = Sprite_TitleCommand.new(symbol, i); i += 1
        @command_sprite.push(sprite)
      }
      @command_sprite.each { |sprite| sprite.show }
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose Command Sprites
  #--------------------------------------------------------------------------
  def dispose_command_sprite
    @command_sprite.each { |sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # * Close Command Window
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    update until @command_window.close?
  end
  #--------------------------------------------------------------------------
  # * [New Game] Command
  #--------------------------------------------------------------------------
  def command_new_game
    close_command_window
    fadeout_all
    $game_map.setup($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.followers.visible = true
    $game_player.refresh
    $game_player.set_graphic(@character_name, @character_index)
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # * [Continue] Command
  #--------------------------------------------------------------------------
  def command_continue
    close_command_window
    fadeout_all
    SceneManager.call(Scene_Load)
  end
  #--------------------------------------------------------------------------
  # * [Shut Down] Command
  #--------------------------------------------------------------------------
  def command_shutdown
    close_command_window
    fadeout_all
    SceneManager.exit
  end
  #--------------------------------------------------------------------------
  # * Play Title Screen Music
  #--------------------------------------------------------------------------
  def play_title_music
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end
end
