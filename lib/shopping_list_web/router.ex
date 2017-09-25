defmodule ShoppingListWeb.Router do
  use ShoppingListWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShoppingListWeb do
    pipe_through :browser # Use the default browser stack

    get "/", ListController, :create

    resources "/lists", ListController, only: [:edit] do
      resources "/entries", EntryController, only: [:create, :update, :delete]
    end
  end
end
