local Cmdline = require("noice.ui.cmdline")
local Manager = require("noice.message.manager")
local Message = require("noice.message")
local Restart = require("noice.restart")

describe("cmdline confirm", function()
  local handle_confirm
  local is_confirming

  before_each(function()
    handle_confirm = Cmdline.handle_confirm
    is_confirming = Restart.is_confirming
    Cmdline.handle_confirm = true
    Cmdline.confirm_message = nil
    Cmdline._on_hide = nil
  end)

  after_each(function()
    Cmdline.handle_confirm = handle_confirm
    Restart.is_confirming = is_confirming
    Cmdline.confirm_message = nil
    Cmdline._on_hide = nil
  end)

  it("hides the cursor only for restart confirmations", function()
    local Hacks = require("noice.util.hacks")
    local hide_cursor = Hacks.hide_cursor
    local show_cursor = Hacks.show_cursor
    local hidden = 0
    local shown = 0
    Hacks.hide_cursor = function()
      hidden = hidden + 1
    end
    Hacks.show_cursor = function()
      shown = shown + 1
    end
    Restart.is_confirming = function()
      return true
    end
    local message = Message("msg_show", "confirm", "Restart Neovim? ")

    Cmdline.on_confirm(message)
    Cmdline.on_show("cmdline_show", {}, 0, "", " &Yes\n&No", 0, 1)
    Cmdline.on_hide("cmdline_hide", 1)

    Hacks.hide_cursor = hide_cursor
    Hacks.show_cursor = show_cursor
    assert.equal(1, hidden)
    assert.equal(1, shown)
  end)

  it("keeps the cursor behavior unchanged for other confirmations", function()
    local Hacks = require("noice.util.hacks")
    local hide_cursor = Hacks.hide_cursor
    local hidden = 0
    Hacks.hide_cursor = function()
      hidden = hidden + 1
    end
    Restart.is_confirming = function()
      return false
    end
    local message = Message("msg_show", "confirm", "Save changes? ")

    Cmdline.on_confirm(message)
    Cmdline.on_show("cmdline_show", {}, 0, "", " &Yes\n&No", 0, 1)

    Hacks.hide_cursor = hide_cursor
    assert.equal(0, hidden)
  end)

  it("separates the confirm message from the cmdline prompt", function()
    local message = Message("msg_show", "confirm", "Save changes? ")

    assert.is_true(Cmdline.on_confirm(message))
    Cmdline.on_show("cmdline_show", {}, 0, "", " &Yes\n&No", 0, 1)

    assert.equal("Save changes? \n &Yes\n&No", message:content())
    assert.is_true(Manager.has(message, { history = true }))
  end)

  it("does not add an extra separator when the confirm message already ends with an empty line", function()
    local message = Message("msg_show", "confirm", "Save changes? \n")

    assert.is_true(Cmdline.on_confirm(message))
    Cmdline.on_show("cmdline_show", {}, 0, "", " &Yes\n&No", 0, 1)

    assert.equal("Save changes? \n &Yes\n&No", message:content())
  end)

  it("does not handle confirm messages on Neovim versions without cmdline confirm prompts", function()
    Cmdline.handle_confirm = false

    local message = Message("msg_show", "confirm", "Save changes? ")

    assert.is_false(Cmdline.on_confirm(message))
    assert.equal("Save changes? ", message:content())
    assert.is_nil(Cmdline.confirm_message)
  end)
end)
