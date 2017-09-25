defmodule ShoppingListWeb.ListView do
  use ShoppingListWeb, :view

  def render("scripts.html", params) do
    raw(~s'
      <script>
        require("js/controller.js").initialize(
          #{Poison.encode!(params.conn.assigns.signed_list_id)},
          #{Poison.encode!(Plug.CSRFProtection.get_csrf_token())}
        )
      </script>
    ')
  end
end
