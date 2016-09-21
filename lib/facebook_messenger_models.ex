
defmodule FacebookMessenger.Message do
  @moduledoc """
  Facebook message structure
  """

  @derive [Poison.Encoder]
  defstruct [:mid, :seq, :text]

  @type t :: %FacebookMessenger.Message{
    mid: String.t,
    seq: integer,
    text: String.t
  }
end

defmodule FacebookMessenger.User do
  @moduledoc """
  Facebook user structure
  """

  @derive [Poison.Encoder]
  defstruct [:id]

  @type t :: %FacebookMessenger.User{
    id: String.t
  }
end

defmodule FacebookMessenger.Postback do
  @moduledoc """
  Facebook postback structure
  """

  @derive [Poison.Encoder]
  defstruct [:payload]

  @type t :: %FacebookMessenger.Postback{
    payload: String.t
  }
end

defmodule FacebookMessenger.ElementPostbackButton do
  @moduledoc """
  Facebook postback button structure
  """
  @derive [Poison.Encoder]
  defstruct [:type, :title, :payload, :url]

  @type t :: %FacebookMessenger.ElementPostbackButton {
    type: String.t,
    title: String.t,
    payload: String.t,
    url: String.t
  }
end

defmodule FacebookMessenger.GenericElement do
  @moduledoc """
  Facebook postback button structure
  """
  @derive [Poison.Encoder]
  defstruct [:title, :item_url, :image_url, :subtitle, :buttons]

  @type t :: %FacebookMessenger.GenericElement {
    title: String.t,
    item_url: String.t,
    image_url: String.t,
    subtitle: String.t,
    buttons: FacebookMessenger.ElementPostbackButton.t,
  }
end

defmodule FacebookMessenger.Messaging do
  @moduledoc """
  Facebook messaging structure, contains the sender, recepient and message info or a postback
  """
  @derive [Poison.Encoder]
  defstruct [:sender, :recipient, :timestamp, :message, :postback]

  @type t :: %FacebookMessenger.Messaging{
    sender: FacebookMessenger.User.t,
    recipient: FacebookMessenger.User.t,
    timestamp: integer,
    message: FacebookMessenger.Message.t,
    postback: FacebookMessenger.Postback.t,
  }
end

defmodule FacebookMessenger.Entry do
  @moduledoc """
  Facebook entry structure
  """
  @derive [Poison.Encoder]
  defstruct [:id, :time, :messaging]

  @type t :: %FacebookMessenger.Entry{
    id: String.t,
    messaging: FacebookMessenger.Messaging.t,
    time: integer
  }
end

defmodule FacebookMessenger.Response do
  @moduledoc """
  Facebook messenger response structure
  """

  @derive [Poison.Encoder]
  defstruct [:object, :entry]

  @doc """
  Decode a map into a `FacebookMessenger.Response`
  """
  @spec parse(map) :: FacebookMessenger.Response.t

  def parse(param) when is_map(param) do
    Poison.Decode.decode(param, as: decoding_map)
  end

  @doc """
  Decode a string into a `FacebookMessenger.Response`
  """
  @spec parse(String.t) :: FacebookMessenger.Response.t

  def parse(param) when is_binary(param) do
    Poison.decode!(param, as: decoding_map)
  end

  @doc """
  Retrun an list of message texts from a `FacebookMessenger.Response`
  """
  @spec message_texts(FacebookMessenger.Response) :: [String.t]
  def message_texts(%{entry: entries}) do
    messaging =
    Enum.flat_map(entries, &Map.get(&1, :messaging))
    |> Enum.map(&( &1 |> Map.get(:message) |> Map.get(:text)))
  end

  @doc """
  Retrun an list of message sender Ids from a `FacebookMessenger.Response`
  """
  @spec message_senders(FacebookMessenger.Response) :: [String.t]
  def message_senders(%{entry: entries}) do
    messaging =
    Enum.flat_map(entries, &Map.get(&1, :messaging))
    |> Enum.map(&( &1 |> Map.get(:sender) |> Map.get(:id)))
  end

  @doc """
  Return a list of postbacks from a 'FacebookMessenger.Response'
  """
  @spec message_postback(FacebookMessenger.Reponse) :: [String.t]
  def message_postback(%{entry: entries}) do
    messaging =
    Enum.flat_map(entries, &Map.get(&1, :messaging))
    |> Enum.map(&( &1 |> Map.get(:postback) |> Map.get(:payload)))
  end


  defp decoding_map do
     messaging_parser =
    %FacebookMessenger.Messaging{
      "sender": %FacebookMessenger.User{},
      "recipient": %FacebookMessenger.User{},
      "message": %FacebookMessenger.Message{},
      "postback": %FacebookMessenger.Postback{},
    }
    %FacebookMessenger.Response{
      "entry": [%FacebookMessenger.Entry{
        "messaging": [messaging_parser]
      }]}
  end

   @type t :: %FacebookMessenger.Response{
    object: String.t,
    entry: FacebookMessenger.Entry.t
  }

end
