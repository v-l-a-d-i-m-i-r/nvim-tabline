local utils = require('nvim-tabline.utils')
local add_hl_group = utils.add_hl_group
local config = require('nvim-tabline.config')
local hl_group_names = config.hl_group_names

---@class nvim-tabline.separator.params
---@field is_active boolean | nil
---
---@class nvim-tabline.separator.chars
---@field separator string
---
---@param chars nvim-tabline.separator.chars
local function Separator(chars)
  ---@param params nvim-tabline.separator.params
  return function(params)
    local is_active = params.is_active or false

    return {
      build = function()
        local separator_highlight_group_name = is_active and hl_group_names.sep_active or hl_group_names.sep_normal

        return add_hl_group(separator_highlight_group_name, chars.separator)
      end,
    }
  end
end

return Separator
