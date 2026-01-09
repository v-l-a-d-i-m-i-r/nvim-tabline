# nvim-tabline

## Project Overview

This project is a Neovim plugin written in Lua that provides a custom tabline. It displays open buffers in the tabline with file-specific icons and custom highlighting to indicate active and modified states. The plugin has an optional dependency on `nvim-web-devicons` for displaying file icons.

The main logic resides in `lua/nvim-tabline/init.lua`. The plugin works by iterating through all open buffers, filtering out special buffers (like NvimTree), and then rendering a tab for each one. The appearance of each tab is customized based on whether the buffer is active or has been modified.

## Building and Running

### Installation

This plugin can be installed using any standard Neovim plugin manager.

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

### Formatting

The project uses `stylua` for code formatting. To format the entire codebase, run the following command:

```sh
make format
```

The configuration for `stylua` can be found in `stylua.toml`.

### Linting & Testing

There are currently no explicit linting or testing configurations set up for this project.
