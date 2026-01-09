---@class nvim-tabline.utils
---@field add_hl_group fun(hl_group_name: string, text: string):string

---@param hl_group_name string
---@param text string
---@return string
local function add_hl_group(hl_group_name, text)
  return '%#' .. hl_group_name .. '#' .. text
end

---@type nvim-tabline.utils
return {
  add_hl_group = add_hl_group,
}
