vim.cmd.packadd("SchemaStore.nvim")

return {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    }
  }
}
