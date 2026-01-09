local utils = require('nvim-tabline.utils')
local add_hl_group = utils.add_hl_group

---@class nvim-tabline.tab.params
---@field is_active boolean | nil
---@field is_modified boolean | nil
---@field name_with_extention string | nil
---@field extention string | nil
---@field width number | nil

---@param hl_group_names table<string, string>
---@param params { is_active: boolean, is_modified: boolean }
---@return string
local function get_tab_hl_group_name(hl_group_names, params)
  local is_active = params.is_active
  local is_modified = params.is_modified

  local tab_hl_group_name = hl_group_names.tab_normal
  if is_active and is_modified then
    tab_hl_group_name = hl_group_names.tab_active_modified
  end
  if not is_active and is_modified then
    tab_hl_group_name = hl_group_names.tab_normal_modified
  end
  if is_active and not is_modified then
    tab_hl_group_name = hl_group_names.tab_active
  end

  return tab_hl_group_name
end

---@param nvim_dev_icons table
---@param hl_group_names table<string, string>
local function Tab(nvim_dev_icons, hl_group_names)
  ---@param params nvim-tabline.tab.params
  return function(params)
    local is_active = params.is_active or false
    local is_modified = params.is_modified or false
    local name_with_extention = params.name_with_extention or ''
    local extention = params.extention or ''
    local width = params.width or 0

    ---@param buf_name_with_ext string
    ---@param buf_width number
    ---@return string
    local function draw_tab(buf_name_with_ext, buf_width)
      local buf_name_with_ext_len = string.len(buf_name_with_ext)
      local icon_with_paddings_len = 5

      if buf_name_with_ext_len > (buf_width - icon_with_paddings_len) then
        return string.sub(buf_name_with_ext, 1, (buf_width - icon_with_paddings_len - 1)) .. '~'
      end

      if buf_name_with_ext_len < (buf_width - icon_with_paddings_len) then
        local buf_name_with_ext_normalized = buf_name_with_ext

        while string.len(buf_name_with_ext_normalized) < (buf_width - icon_with_paddings_len - 1) do
          buf_name_with_ext_normalized = buf_name_with_ext_normalized .. ' '
        end

        return buf_name_with_ext_normalized
      end

      return buf_name_with_ext
    end

    return {
      build = function()
        local buf_icon, icon_highlight_group =
          nvim_dev_icons.get_icon(name_with_extention, extention, { default = true })
        local icon_highlight_group_name = is_active and 'TL' .. icon_highlight_group .. 'Active'
          or hl_group_names.tab_normal

        local tab_hl_group_name = get_tab_hl_group_name(hl_group_names, {
          is_active = is_active,
          is_modified = is_modified,
        })
        local buf_name_with_ext_normalized = draw_tab(name_with_extention, width)

        return add_hl_group(tab_hl_group_name, ' ')
          .. add_hl_group(icon_highlight_group_name, buf_icon)
          .. add_hl_group(tab_hl_group_name, ' ')
          .. add_hl_group(tab_hl_group_name, buf_name_with_ext_normalized)
          .. add_hl_group(tab_hl_group_name, ' ')
      end,
    }
  end
end

return Tab
