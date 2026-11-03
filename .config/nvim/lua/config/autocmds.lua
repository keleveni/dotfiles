-- グローバルな autocmd / ユーザーコマンド
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- 外部でファイルが変更されたら自動で読み直す
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup,
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})

-- checktime はウィンドウに表示中のバッファしか見ないので、裏に残ったバッファは
-- 外部で変更・削除されても古いままになり、LSP に古い内容が送られ続けて
-- 直したはずのエラーが出続ける。裏のバッファも個別に確認する：
--   削除済み → 閉じる / 変更あり → checktime {buf} で読み直す（autoread）
-- 未保存の新規バッファを巻き込まないよう、一度ディスクと対応したバッファだけを対象にする
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = augroup,
  callback = function(args)
    vim.b[args.buf].on_disk = true
  end,
})
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = augroup,
  callback = function()
    if vim.fn.mode() == "c" then
      return
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      -- 表示中のバッファは上の checktime に任せる
      if vim.api.nvim_buf_is_loaded(buf) and vim.b[buf].on_disk and #vim.fn.win_findbuf(buf) == 0 then
        if vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf)) then
          vim.cmd.checktime(buf)
        elseif not vim.bo[buf].modified then
          vim.api.nvim_buf_delete(buf, {})
        end
      end
    end
  end,
})
