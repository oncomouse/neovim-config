vim.schedule(function()
  -- We open orgagenda in a whole window (no split)
  vim.keymap.set("n", "q", "<Cmd>bd<CR>", { buf = 0 })
end)
