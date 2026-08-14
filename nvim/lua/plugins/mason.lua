-- Tools used by conform / LSP (extras already install language servers)
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "prettier",
        "clang-format",
      })
    end,
  },
}
