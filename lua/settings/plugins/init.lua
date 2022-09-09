local M = {}

---@type SettingsPlugin[]
M.plugins = {}

local function fire(plugin, method, ...)
  if type(plugin[method]) == "function" then
    plugin[method](...)
  end
end

function M.fire(method, ...)
  for _, plugin in pairs(M.plugins) do
    fire(plugin, method, ...)
  end
end

---@param plugin SettingsPlugin
function M.register(plugin)
  table.insert(M.plugins, plugin)
  fire(plugin, "setup")
end

function M.setup()
  M.register({
    get_schema = function()
      local defaults = require("settings.config").defaults
      local ret = require("settings.schema").plugin_schema("settings.nvim", defaults, "Settings for settings.nvim")
      ret.properties["settings.nvim"].properties.plugins.properties.sumneko_lua = {
        type = "object",
        properties = {
          enabled = {
            description = "When null, this will only be enabled for your neovim config",
            type = {
              "boolean",
              "null",
            },
          },
        },
      }
      return ret
    end,
  })
  M.register(require("settings.plugins.lspconfig"))
  M.register(require("settings.plugins.jsonls"))
  M.register(require("settings.plugins.sumneko"))
end

return M
