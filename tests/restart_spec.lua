local Restart = require("noice.restart")

describe("restart confirmation", function()
  local enter = vim.fn.maparg("<CR>", "c", false, true)

  after_each(function()
    Restart.disable()
    if not vim.tbl_isempty(enter) then
      vim.fn.mapset("c", false, enter)
    end
  end)

  it("matches only the literal restart Ex command", function()
    assert.is_true(Restart.matches(":", "restart"))
    assert.is_false(Restart.matches(":", "restart!"))
    assert.is_false(Restart.matches(":", "restart +qall!"))
    assert.is_false(Restart.matches("/", "restart"))
  end)

  it("defaults confirmation to Yes and invokes native restart", function()
    local confirm_args
    local restarted = 0
    Restart.confirm({
      confirm = function(...)
        confirm_args = { ... }
        return 1
      end,
      restart = function()
        restarted = restarted + 1
      end,
    })

    assert.same({ "Restart Neovim?", "&Yes\n&No", 1 }, confirm_args)
    assert.equal(1, restarted)
  end)

  it("does not restart when confirmation is rejected or cancelled", function()
    for _, choice in ipairs({ 0, 2 }) do
      local restarted = 0
      Restart.confirm({
        confirm = function()
          return choice
        end,
        restart = function()
          restarted = restarted + 1
        end,
      })
      assert.equal(0, restarted)
    end
  end)

  it("rewrites only the literal restart command", function()
    assert.equal("<C-U>lua require('noice.restart').confirm()<CR>", Restart.expand(":", "restart"))
    assert.equal("<CR>", Restart.expand(":", "restart!"))
    assert.equal("<CR>", Restart.expand(":", "restart +qall!"))
    assert.equal("<CR>", Restart.expand("/", "restart"))
  end)

  it("registers and removes an expression mapping on Neovim 0.12", function()
    Restart.enable(true)

    local mapping = vim.fn.maparg("<CR>", "c", false, true)
    assert.equal(1, mapping.expr)
    assert.equal(1, mapping.noremap)

    Restart.disable()
    assert.same(enter, vim.fn.maparg("<CR>", "c", false, true))
  end)

  it("does not register the mapping on older Neovim versions", function()
    Restart.enable(false)

    assert.same(enter, vim.fn.maparg("<CR>", "c", false, true))
  end)
end)
