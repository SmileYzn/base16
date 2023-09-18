-- mod-version:3
--
-- Local requirements
local core     = require("core")
local common   = require("core.common")
local config   = require("core.config")
local style    = require("core.style")
--
-- Get installed themes
local function get_installed_themes()
  -- Return table
  local files, themes = {}, {}
  --
  -- Loop data and user directory
  for _, root_dir in ipairs {DATADIR, USERDIR} do
    --
    -- Build themes path from current directory
    local dir = root_dir .. PATHSEP .. "plugins" .. PATHSEP .. "base16" .. PATHSEP .. "themes"
    --
    -- Loop file names
    for _, filename in ipairs(system.list_dir(dir) or {}) do
      --
      -- Get file information
      local file_info = system.get_file_info(dir .. PATHSEP .. filename)
      --
      -- If has file informationm type is file and have .yaml extension
      if file_info and file_info.type == "file" and filename:match("%.yaml$") then
        --
        -- Open file
        local fp = io.open(dir .. PATHSEP .. filename, "r")
        --
        -- Loop lines
        for line in fp:lines() do
          --
          -- Get color name and color values
          local key, value = line:match([[(.*):%s"(.*)"]])
          --
          -- If name and color was found
          if key and value then
            --
            -- If is name or scheme key
            if key == "scheme" then
              if not files[filename] then
                table.insert(themes, {value, filename:gsub("%.yaml$", "")})
              end
              files[filename] = true
            end
          end
        end
        --
        -- Close file
        fp:close()
      end
    end
  end
  -- Return themes table
  return themes
end
--
-- Apply colors to style
local function base16_apply_colors(base16)
  --
  -- Interface colors
  style.background  = {common.color(base16["base00"])} -- Docview
  style.background2 = {common.color(base16["base01"])} -- Treeview
  style.background3 = {common.color(base16["base01"])} -- Command view
  style.text        = {common.color(base16["base05"])} -- Interface Text Color
  style.caret       = {common.color(base16["base04"])} -- Cursor caret
  style.accent      = {common.color(base16["base0D"])} -- Accent Color
  style.dim         = {common.color(base16["base03"])} -- style.dim - text color for nonactive tabs, tabs divider, prefix in log and search result, hotkeys for context menu and command view
  style.divider     = {common.color(base16["base02"])} -- Line between nodes
  style.selection   = {common.color(base16["base02"])} -- Selection background
  --
  -- Line Numbers
  style.line_number      = {common.color(base16["base05"])} -- Color Number
  style.line_number2     = {common.color(base16["base0D"])} -- With cursor (Current line color)
  style.line_highlight   = {common.color(base16["base02"] .. '70')} -- Current selected line background color
  --
  -- Scrollbar colors
  style.scrollbar        = {common.color(base16["base0D"])} -- Scrollbar color
  style.scrollbar2       = {common.color(base16["base0D"])} -- Hovered color
  style.scrollbar_track  = {common.color(base16["base01"])} -- Scroolbar free space color
  --
  -- Notification Bar
  style.nagbar           = {common.color(base16["base0D"])} -- Background color
  style.nagbar_text      = {common.color(base16["base05"])} -- Text Color
  style.nagbar_dim       = {common.color("rgba(0, 0, 0, 0.45)")} -- Interface opacity when nagbar is displayed, use rgba for better result
  --
  -- On Drag / Drop Tab colors
  style.drag_overlay     = {common.color("rgba(255,255,255,0.1)")} -- Opacity of drop overlay area, use rgba for better result
  style.drag_overlay_tab = {common.color(base16["base0D"])} -- Left color when drag tab with mouse cursor
  --
  -- Console Icon Colors
  style.good             = {common.color(base16["base0B"])} -- Succes
  style.warn             = {common.color(base16["base0A"])} -- Warning
  style.error            = {common.color(base16["base08"])} -- Error
  style.modified         = {common.color(base16["base0F"])} -- Info
  --
  -- Syntax colors
  style.syntax["normal"]   = {common.color(base16["base06"])} -- Normal (Undefined symbols)
  style.syntax["symbol"]   = {common.color(base16["base05"])} -- User Defined variables names
  style.syntax["comment"]  = {common.color(base16["base03"])} -- Comment block or line
  style.syntax["keyword"]  = {common.color(base16["base0E"])} -- if, else, switch, case
  style.syntax["keyword2"] = {common.color(base16["base08"])} -- new, Float, boolean, bool
  style.syntax["number"]   = {common.color(base16["base09"])} -- 0 1 2 3 4 5 6 7 8 9 0
  style.syntax["literal"]  = {common.color(base16["base0C"])} -- true, false
  style.syntax["string"]   = {common.color(base16["base0B"])} -- Strings
  style.syntax["operator"] = {common.color(base16["base05"])} -- = + -  < > * % ! ^ |
  style.syntax["function"] = {common.color(base16["base0D"])} -- Function Names
  --
  -- Pawn Language
  style.syntax["native"]  = {common.color(base16["base0D"])} -- Native functions
  style.syntax["forward"] = {common.color(base16["base0D"])} -- Forward functions
  style.syntax["public"]  = {common.color(base16["base0D"])} -- Public functions
  style.syntax["stock"]   = {common.color(base16["base0D"])} -- Stock functions
  --
  -- Log icon colors
  style.log["INFO"]  = {icon = "i", color = style.good}
  style.log["WARN"]  = {icon = "!", color = style.warn}
  style.log["ERROR"] = {icon = "!", color = style.error}
  --
  -- If has scheme and autor values
  if base16["scheme"] and base16["author"] then
    -- Display log message
    core.log(string.format("%s (%s)", base16["scheme"], base16["author"]))
  end
end
--
-- Load theme file
local function base16_load_theme()
  --
  -- Current theme to file name
  local file_name = string.format("%s.yaml", config.plugins.base16.theme) or 'default-dark.yaml'
  --
  -- Loop data and user directory
  for _, root_dir in ipairs {DATADIR, USERDIR} do
    --
    -- Build themes path from current directory
    local theme_file = root_dir .. PATHSEP .. "plugins" .. PATHSEP .. "base16" .. PATHSEP .. "themes" .. PATHSEP .. file_name
    --
    -- Try to open file
    local fp = io.open(theme_file, "r")
    --
    -- If was opened
    if fp then
      --
      -- Base16 current theme colors
      local base16 = {}
      --
      -- Loop
      for line in fp:lines() do
        --
        -- Get color name and color values
        local name, color = line:match([[(.*):%s"(.*)"]])
        --
        -- If name and color was found
        if name and color then
          if name ~= "scheme" and name ~= "author" then
            base16[name] = string.format("#%s", color)
          else
            base16[name] = color
          end
        end
      end
      --
      -- Close file
      fp:close()
      --
      -- If table with base16 colors was loaded
      if base16 then
        base16_apply_colors(base16)
        --
        -- Return true
        return true
      end
    end
  end
  --
  -- Log error
  core.error(string.format("%s was not found on themes directory.", config.plugins.base16.theme))
  --
  -- Return false
  return false
end
--
-- Merge settings to theme widget
config.plugins.base16 = common.merge
({
  theme = "default-dark",
  -- The config specification used by the settings gui
  config_spec =
  {
    name = "Base16 Colors",
    {
      label = "Select theme",
      description = "These schemes are in themes folder",
      path = "theme",
      type = "selection",
      default = "default-dark",
      values = get_installed_themes(),
      on_apply = function(value)
        --
        -- Reload teheme
        base16_load_theme()
      end
    },
  }
}, config.plugins.base16)
--
-- Load Theme in a core thread
core.add_thread(function()
  base16_load_theme()
end)
