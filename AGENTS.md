# nvim-tabline

## Project Overview

This project is a Neovim plugin written in Lua that provides a custom tabline. It displays open buffers in the tabline with file-specific icons and custom highlighting to indicate active and modified states. The plugin has an optional dependency on `nvim-web-devicons` for displaying file icons. The codebase is annotated with EmmyLua for type safety and improved development experience.

The main logic resides in `lua/nvim-tabline/init.lua`. The plugin works by iterating through all open buffers, filtering out special buffers (like NvimTree), and then rendering a tab for each one. The appearance of each tab is customized based on whether the buffer is active or has been modified.

## Building and Running

### Installation

This plugin can be in-stalled using any standard Neovim plugin manager.

**Example with lazy.nvim:**

```lua
{
  'v-l-a-d-i-m-i-r/nvim-tabline',
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Optional, for file icons
  config = function()
    require('nvim-tabline').setup()
  end,
}
```

### Running

Once installed, the plugin is activated by calling the `setup` function in your Neovim configuration, as shown in the installation example above. This sets the `'tabline'` option to use the custom Lua function provided by this plugin.

## Development Conventions

### Code Style

All variable and function names should be in `snake_case`.

### Formatting

The project uses `stylua` for code formatting. To format the entire codebase, run the following command:

```sh
make format
```

The configuration for `stylua` can be found in `stylua.toml`.

### Type Annotations

The project uses EmmyLua for type annotations. This helps with static analysis and provides better autocompletion and type checking in supported editors.

**Guidelines:**

1. **Function parameters and return types** — Always annotate function signatures:
   ```lua
   ---@param buffer_number number
   ---@return string
   local function get_buffer_name(buffer_number)
     return vim.fn.expand('#' .. buffer_number .. ':t')
   end
   ```

2. **Class definitions** — Define complex data structures using `@class`:
   ```lua
   ---@class nvim-tabline.tab.params
   ---@field is_active boolean | nil
   ---@field is_modified boolean | nil
   ---@field name_with_extention string | nil
   ```

3. **Function return objects** — When functions return tables with methods, annotate the structure:
   ```lua
   ---@return { build: fun():string }
   local function Tabline()
     return {
       build = function() ... end,
     }
   end
   ```

4. **Variable type hints** — Use `@type` for variables when the type is not obvious:
   ```lua
   ---@type string[]
   local skipped_buf_names = { 'NvimTree_1', 'Trouble' }
   ```

5. **Union types** — Use pipe (`|`) for multiple possible types:
   ```lua
   ---@field is_active boolean | nil
   ```

Ensure all functions, classes, and exported variables have proper type annotations to maintain code quality and enable IDE support.

### Linting & Testing

The project uses the Lua Diagnostics language server for linting. There are currently no explicit testing configurations set up for this project.

### Fixing Styles

The project uses `stylua` for code formatting. To fix style issues in the codebase:

1. **Format all files:**
   ```sh
   make format
   ```

2. **Format a specific file:**
   ```sh
   stylua <file_path>
   ```

3. **Check formatting without making changes:**
   ```sh
   stylua --check <file_path>
   ```

The `stylua` configuration is defined in `stylua.toml`. Ensure all code changes follow the snake_case naming convention for variables and functions before formatting.
