---@diagnostic disable: undefined-global
local has_nvim_dev_icons, nvim_dev_icons = pcall(require, 'nvim-web-devicons')
local utils = require('nvim-tabline.utils')
---@type nvim-tabline.config
local config = require('nvim-tabline.config')
---@type fun():nvim-tabline.line
local Line = require('nvim-tabline.line')

local add_hl_group = utils.add_hl_group
local hl_group_names = config.hl_group_names

local chars = {
  separator = '|',
}
---@type fun(params: {is_active: boolean}): { build: fun():string }
local Separator = require('nvim-tabline.separator')(chars)

---@type string[]
local skipped_buf_names = {
  'NvimTree_1',
  'Trouble',
  'DiffviewFilePanel',
  'null',
  'api.txt',
  '0.fugitiveblame',
  'diffview://',
}

---@param name string
---@return table
local function get_hl(name)
  local hl_group = vim.api.nvim_get_hl(0, { name = name })

  if hl_group.link ~= nil then
    return get_hl(hl_group.link)
  end

  return hl_group
end

local function setup()
  vim.o.showtabline = 2
  vim.o.tabline = '%!v:lua.nvim_tabline()'

  vim.api.nvim_set_hl(0, hl_group_names.fill, { link = 'TabLineFill' })
  vim.api.nvim_set_hl(0, hl_group_names.tab_normal, { link = 'TabLine' })
  vim.api.nvim_set_hl(0, hl_group_names.tab_active, { link = 'TabLineSel' })

  local hl_normal = get_hl(hl_group_names.tab_normal)
  local hl_active = get_hl(hl_group_names.tab_active)
  local hl_warn = get_hl('WarningMsg')

  vim.api.nvim_set_hl(0, hl_group_names.tab_normal_modified, { fg = hl_warn.fg, bg = hl_normal.bg })
  vim.api.nvim_set_hl(0, hl_group_names.tab_active_modified, { fg = hl_warn.fg, bg = hl_active.bg })
  vim.api.nvim_set_hl(0, hl_group_names.sep_normal, { fg = hl_active.bg, bg = hl_normal.bg })
  vim.api.nvim_set_hl(0, hl_group_names.sep_active, { fg = hl_normal.bg, bg = hl_active.bg })

  if has_nvim_dev_icons then
    for _, icon_definition in pairs(require('nvim-web-devicons').get_icons()) do
      local icon_hl_group = 'DevIcon' .. icon_definition.name
      local icon_color = icon_definition.color
      local icon_hl_group_normal = 'TL' .. icon_hl_group .. 'Normal'
      local icon_hl_group_active = 'TL' .. icon_hl_group .. 'Active'

      vim.api.nvim_set_hl(0, icon_hl_group_normal, { fg = hl_active.bg, bg = hl_normal.bg })
      vim.api.nvim_set_hl(0, icon_hl_group_active, { fg = icon_color, bg = hl_active.bg })
    end
  end
end
local function Tabline()
  ---@type fun(params: nvim-tabline.tab.params):{ build: fun():string }
  local Tab = require('nvim-tabline.tab')(nvim_dev_icons, hl_group_names)
  ---@param numbers number[]
  ---@param skipped_buffer_names string[]
  ---@return number[]
  local function filter_buffer_numbers(numbers, skipped_buffer_names)
    local result = {}

    for _, number in ipairs(numbers) do
      if not vim.api.nvim_buf_is_loaded(number) then
        goto continue
      end

      local buf_path = vim.api.nvim_buf_get_name(number)

      if buf_path == '' then
        goto continue
      end

      for _, skipped_buffer_name in ipairs(skipped_buffer_names) do
        if buf_path:find(skipped_buffer_name) ~= nil then
          goto continue
        end
      end

      table.insert(result, number)

      ::continue::
    end

    return result
  end

  ---@param buffer_number number
  ---@return boolean
  local function check_buffer_active(buffer_number)
    local active_buffer_numbers = vim.fn.tabpagebuflist()

    for _, active_buffer_number in ipairs(active_buffer_numbers) do
      if buffer_number == active_buffer_number then
        return true
      end
    end

    return false
  end

  ---@param is_active boolean
  ---@param is_prev_buffer_active boolean
  ---@return string
  local function get_start_separator(is_active, is_prev_buffer_active)
    if is_active ~= is_prev_buffer_active then
      return ' '
    end

    return Separator({ is_active = is_active }).build()
  end

  ---@param buffer_number number
  ---@return string
  local function get_buffer_name_with_extention(buffer_number)
    return vim.fn.expand('#' .. buffer_number .. ':t')
  end

  ---@param buffer_number number
  ---@return string
  local function get_buffer_extention(buffer_number)
    return vim.fn.expand('#' .. buffer_number .. ':e')
  end

  return {
    build = function()
      local nvim_width = vim.go.columns
      local line = Line()
      local buf_nrs = vim.api.nvim_list_bufs()
      local filtered_buffer_numbers = filter_buffer_numbers(buf_nrs, skipped_buf_names)

      local bufs_qty = #filtered_buffer_numbers
      local buf_width = math.min(nvim_width / bufs_qty, 30)

      local is_prev_buffer_active = false
      for i, buffer_number in ipairs(filtered_buffer_numbers) do
        local is_first = i == 1
        local is_last = i == table.getn(filtered_buffer_numbers)
        local is_modified = vim.api.nvim_get_option_value('modified', { buf = buffer_number })
        local is_active = check_buffer_active(buffer_number)

        if not is_first then
          local start_separator = get_start_separator(is_active, is_prev_buffer_active)

          line.add(start_separator)
        end

        local tab = Tab({
          is_active = is_active,
          is_modified = is_modified,
          name_with_extention = get_buffer_name_with_extention(buffer_number),
          extention = get_buffer_extention(buffer_number),
          width = buf_width,
        }).build()

        line.add(tab)

        if is_last and not is_active then
          local end_separator = Separator({ is_active = false }).build()

          line.add(end_separator)
        end

        is_prev_buffer_active = is_active
      end

      line.add(add_hl_group(hl_group_names.fill, ''))

      return line.build()
    end,
  }
end

local tabline = Tabline()

function _G.nvim_tabline()
  return tabline.build()
end

return {
  setup = setup,
}
