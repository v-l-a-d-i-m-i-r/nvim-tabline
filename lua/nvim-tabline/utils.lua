local function add_hl_group(hl_group_name, text)
  return '%#' .. hl_group_name .. '#' .. text
end

return {
  add_hl_group = add_hl_group,
}
