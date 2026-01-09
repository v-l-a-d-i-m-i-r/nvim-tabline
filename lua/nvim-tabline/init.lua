local nvim_dev_icons = require('nvim-web-devicons')
local has_nvim_dev_icons = pcall(require, "nvim-web-devicons")
local utils = require('nvim-tabline.utils')
local config = require('nvim-tabline.config')
local Line = require('nvim-tabline.line')

local add_hl_group = utils.add_hl_group
local hl_group_names = config.hl_group_names

local chars = {
  separator = '|',
}
local Separator = require('nvim-tabline.separator')(chars)

local skipped_buf_names = {
  'NvimTree_1',
  'Trouble',
  'DiffviewFilePanel',
  'null',
  'api.txt',
  '0.fugitiveblame',
  'diffview://',
}


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
  local Tab = require('nvim-tabline.tab')(nvim_dev_icons, hl_group_names)
  local function filterBufferNumbers(numbers, skippedBufferNames)
    local result = {}

    for _, number in ipairs(numbers) do
      if not vim.api.nvim_buf_is_loaded(number) then
        goto continue
      end

      local buf_path = vim.api.nvim_buf_get_name(number)

      if buf_path == '' then
        goto continue
      end

      for _, skippedBufferName in ipairs(skippedBufferNames) do
        if buf_path:find(skippedBufferName) ~= nil then
          goto continue
        end
      end

      table.insert(result, number)

      ::continue::
    end

    return result
  end

  local function checkBufferActive(bufferNumber)
    local activeBufferNumbers = vim.fn.tabpagebuflist()

    for _, activeBufferNumber in ipairs(activeBufferNumbers) do
      if bufferNumber == activeBufferNumber then
        return true
      end
    end

    return false
  end

  local function getStartSeparator(isActive, isPrevBufferActive)
    if isActive ~= isPrevBufferActive then
      return ' '
    end

    return Separator({ isActive = isActive }).build()
  end

  local function getBufferNameWithExtention(bufferNumber)
    return vim.fn.expand('#' .. bufferNumber .. ':t')
  end

  local function getBufferExtention(bufferNumber)
    return vim.fn.expand('#' .. bufferNumber .. ':e')
  end

  return {
    build = function()
      local nvim_width = vim.go.columns
      local line = Line()
      local buf_nrs = vim.api.nvim_list_bufs()
      local filterredBufferNumbers = filterBufferNumbers(buf_nrs, skipped_buf_names)

      local bufs_qty = #filterredBufferNumbers
      local buf_width = math.min(nvim_width / bufs_qty, 30)

      local isPrevBufferActive = false
      for i, bufferNumber in ipairs(filterredBufferNumbers) do
        local isFirst = i == 1
        local isLast = i == table.getn(filterredBufferNumbers)
        local isModified = vim.api.nvim_buf_get_option(bufferNumber, 'modified')
        local isActive = checkBufferActive(bufferNumber)

        if not isFirst then
          local startSeparator = getStartSeparator(isActive, isPrevBufferActive)

          line.add(startSeparator)
        end

        local tab = Tab({
          isActive = isActive,
          isModified = isModified,
          nameWithExtention = getBufferNameWithExtention(bufferNumber),
          extention = getBufferExtention(bufferNumber),
          width = buf_width,
        }).build()

        line.add(tab)

        if isLast and not isActive then
          local endSeparator = Separator({ isActive = false }).build()

          line.add(endSeparator)
        end

        isPrevBufferActive = isActive
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
