---@class nvim-tabline.config
local M = {}

---@type table<string, string>
M.hl_group_names = {
  fill = 'TLFill',
  tab_normal = 'TLTabNormal',
  tab_active = 'TLTabActive',
  tab_normal_modified = 'TLTabNormalModified',
  tab_active_modified = 'TLTabActiveModified',
  sep_normal = 'TLSepNormal',
  sep_active = 'TLSepActive',
}

return M
