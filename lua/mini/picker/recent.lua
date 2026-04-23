-- Source: https://github.com/jason0x43/dotfiles/blob/896a7f4a83ad17c8717c6b585d399c612acb6d30/config/nvim/lua/user/mini/picker_recent.lua
---A recent files picker
return function(local_opts)
  vim.v.oldfiles = vim.tbl_filter(function(item)
    return not vim.endswith(item, 'COMMIT_EDITMSG')
  end, vim.v.oldfiles)
  return require('mini.extra').pickers.oldfiles(local_opts)
end
