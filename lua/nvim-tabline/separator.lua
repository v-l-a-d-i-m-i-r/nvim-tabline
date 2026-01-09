local utils = require('nvim-tabline.utils')
local add_hl_group = utils.add_hl_group

local utils = require('nvim-tabline.utils')
local add_hl_group = utils.add_hl_group
local config = require('nvim-tabline.config')
local hl_group_names = config.hl_group_names

local function Separator(chars)
  return function(params)
    local isActive = params.isActive or false

    return {
      build = function()
        local separatorHighlightGroupName = isActive and hl_group_names.sep_active or hl_group_names.sep_normal

        return add_hl_group(separatorHighlightGroupName, chars.separator)
      end,
    }
  end
end

return Separator