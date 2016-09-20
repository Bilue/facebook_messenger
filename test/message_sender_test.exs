
defmodule TestBotOne.MessageSenderTest do
  use ExUnit.Case

  test "creates a correct url" do
    assert FacebookMessenger.Sender.url == "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"
  end

  test "creates a correct payload" do
    assert FacebookMessenger.Sender.message_payload(1055439761215256, "Hello") ==
    %{message: %{text: "Hello"}, recipient: %{id: 1055439761215256}}
  end

  test "creates a correct payload in json" do
    payload = FacebookMessenger.Sender.message_payload(1055439761215256, "Hello")
    assert FacebookMessenger.Sender.json_payload(payload) ==
    "{\"recipient\":{\"id\":1055439761215256},\"message\":{\"text\":\"Hello\"}}"
  end

  test "sends correct message" do
    FacebookMessenger.Sender.send(1055439761215256, "Hello")
    assert_received %{body: "{\"recipient\":{\"id\":1055439761215256},\"message\":{\"text\":\"Hello\"}}", url: "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"}
  end

  test "creates a correct generic template message" do
    element = %{title: "foo", subtitle: "bar", item_url: "https://www.imaurl.com", image_url: "https://www.imaimageurl.com", buttons: [%{type: "postback", title: "Postback", payload: "First bubble payload"}]}
    assert FacebookMessenger.Sender.template_payload(1055439761215256, [element]) == 
    %{recipient: %{id: 1055439761215256}, message: %{attachment: %{type: "template", payload: %{template_type: "generic", elements: [element]}}}}
  end

  test "creates a correct generic template message in json" do
    payload = FacebookMessenger.Sender.template_payload(1055439761215256, [])
  end

end