local utils = require('nvim-tabline.utils')
local add_hl_group = utils.add_hl_group

local function Tab(nvim_dev_icons, hl_group_names)
  return function(params)
    local isActive = params.isActive or false
    local isModified = params.isModified or false
    local nameWithExtention = params.nameWithExtention or ''
    local extention = params.extention or ''
    local width = params.width or 0

    local function drawTab(buf_name_with_ext, buf_width)
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

    local function getTabHlGroupName(params)
      local isActive = params.isActive
      local isModified = params.isModified

      local tab_hl_group_name = hl_group_names.tab_normal
      if isActive and isModified then
        tab_hl_group_name = hl_group_names.tab_active_modified
      end
      if not isActive and isModified then
        tab_hl_group_name = hl_group_names.tab_normal_modified
      end
      if isActive and not isModified then
        tab_hl_group_name = hl_group_names.tab_active
      end

      return tab_hl_group_name
    end

    return {
      build = function()
        local buf_icon, iconHighlightGroup = nvim_dev_icons.get_icon(nameWithExtention, extention, { default = true })
        local iconHighlightGroupName = isActive and 'TL' .. iconHighlightGroup .. 'Active' or hl_group_names.tab_normal

        local tab_hl_group_name = getTabHlGroupName({
          isActive = isActive,
          isModified = isModified,
        })
        local buf_name_with_ext_normalized = drawTab(nameWithExtention, width)

        return add_hl_group(tab_hl_group_name, ' ')
          .. add_hl_group(iconHighlightGroupName, buf_icon)
          .. add_hl_group(tab_hl_group_name, ' ')
          .. add_hl_group(tab_hl_group_name, buf_name_with_ext_normalized)
          .. add_hl_group(tab_hl_group_name, ' ')
      end,
    }
  end
end

return Tab
