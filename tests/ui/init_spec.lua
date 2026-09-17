local Ui = require("noice.ui")

describe("ui events", function()
  it("ignores global events so remote UIs can handle them", function()
    local events = {
      "set_title",
      "set_icon",
      "mode_info_set",
      "option_set",
      "chdir",
      "mode_change",
      "mouse_on",
      "mouse_off",
      "busy_start",
      "busy_stop",
      "connect",
      "restart",
      "suspend",
      "update_menu",
      "bell",
      "visual_bell",
      "flush",
      "ui_send",
    }

    for _, event in ipairs(events) do
      assert.is_nil(Ui.get_handler(event))
    end
  end)
end)
