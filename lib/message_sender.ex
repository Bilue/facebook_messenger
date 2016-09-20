defmodule FacebookMessenger.Sender do
  @moduledoc """
  Module responsible for communicating back to facebook messenger
  """
  require Logger

  @doc """
  sends a message to the the recepient

    * :recepient - the recepient to send the message to
    * :message - the message to send
  """
  @spec send(String.t, String.t) :: HTTPotion.Response.t
  def send(recepient, message) do
    Logger.debug(url)
    Logger.debug(message_payload(recepient, message))
    res = manager.post(
      url: url,
      body: json_payload(message_payload(recepient, message))
    )
    Logger.info("response from FB #{inspect(res)}")
    res
  end

  @doc """
  sends a generic template to the recepient

    * :recepient - the recepient to send the message to
    * :elements - contains the elements to send 
  """
  @spec send(String.t, Array.t) :: HTTPotion.Response.t
  def send(recepient, elements) do
    Logger.debug(url)
    Logger.debug(template_payload(recepient, elements))
    res = manager.post(
      url: url,
      body: json_payload(template_payload(recepient, elements))
    )
    Logger.info("response from FB #{inspect(res)}")
    res
  end

  @doc """
  sends a sender action to the recipient

    * :recipient - the recipient to send the message to
    * :action - contains a action to the user i.e. "mark_seen" to mark last message as read
  """
  @spec send_action(String.t, String.t) :: HTTPotion.Response.t
  def send_action(recipient, action) do
    Logger.debug(url)
    Logger.debug(action_payload(recipient, action))
    res = manager.post(
      url: url,
      body: json_payload(action_payload(recipient, action))
    )
    Logger.info("response from FB #{inspect(res)}")
    res
  end

  @doc """
  creates a payload to send to facebook

    * :recipient - the recipient to send the message to
    * :message - the message to send
  """
  def message_payload(recipient, message) do
    %{
      recipient: %{id: recipient},
      message: %{text: message}
    }
  end

  @doc """
  creates a template payload to send to facebook

    * :recipient: - the recipient to send the message to
    * :elements - contains the elements to send
  """
  def template_payload(recipient, elements) do
    %{
      recipient: %{id: recipient},
      message: %{attachment: %{type: "template", payload: %{template_type: "generic", elements: elements}}}
    }
  end

  @doc """
  creates an action payload to send to facebook

    * :recipient - the recipient to send the message to
    * :action - the sender action string
  """
  def action_payload(recipient, action) do
    %{
      recipient: %{id: recipient},
      sender_action: action
    }
  end

  @doc """
  creates a json payload to send to facebook

    * :payload - a map of data to be json encoded
  """
  def json_payload(payload) do
    Poison.encode(payload)
    |> elem(1)
  end

  @doc """
  return the url to hit to send the message
  """
  def url do
    query = "access_token=#{page_token}"
    "https://graph.facebook.com/v2.6/me/messages?#{query}"
  end

  defp page_token do
    Application.get_env(:facebook_messenger, :facebook_page_token)
  end

  defp manager do
    Application.get_env(:facebook_messenger, :request_manager) || FacebookMessenger.RequestManager
  end
end
