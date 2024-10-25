defmodule Azurex.Blob.Container do
  @moduledoc """
  Implementation of Azure Blob Storage
  """
  alias Azurex.Blob.Config
  alias Azurex.Authorization.SharedKey

  def head_container(container, conf_element \\ :azurex) do
    %HTTPoison.Request{
      url: Config.api_url(conf_element) <> "/" <> container,
      params: [restype: "container"],
      method: :head
    }
    |> SharedKey.sign(
      storage_account_name: Config.storage_account_name(conf_element),
      storage_account_key: Config.storage_account_key(conf_element)
    )
    |> HTTPoison.request()
    |> case do
      {:ok, %{status_code: 200, headers: headers}} -> {:ok, headers}
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, :not_found}
      {:ok, err} -> {:error, err}
      {:error, err} -> {:error, err}
    end
  end

  def create(container, conf_element \\ :azurex) do
    %HTTPoison.Request{
      url: Config.api_url(conf_element) <> "/" <> container,
      params: [restype: "container"],
      method: :put
    }
    |> SharedKey.sign(
      storage_account_name: Config.storage_account_name(conf_element),
      storage_account_key: Config.storage_account_key(conf_element),
      content_type: "application/octet-stream"
    )
    |> HTTPoison.request()
    |> case do
      {:ok, %{status_code: 201}} -> {:ok, container}
      {:ok, %HTTPoison.Response{status_code: 409}} -> {:error, :already_exists}
      {:ok, err} -> {:error, err}
      {:error, err} -> {:error, err}
    end
  end
end
