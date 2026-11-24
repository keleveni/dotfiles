-- Lean: LSP（lake serve）の起動と infoview は lean.nvim が担う。
-- Lean の言語サーバーはプロジェクトの toolchain（elan で管理）に含まれるため mason では入れない。
-- nvim-lspconfig からも leanls の設定は削除済みで、lean.nvim 側の設定を使う。
return {
  "Julian/lean.nvim",
  event = { "BufReadPre *.lean", "BufNewFile *.lean" },
  -- lean.nvim は setup() を持たず vim.g.lean_config で設定する
  init = function()
    vim.g.lean_config = {
      mappings = true,
    }
  end,
}
