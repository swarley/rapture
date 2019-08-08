# frozen_string_literal: true

describe Rapture::REST do
  c = Rapture::Client.new("Bot T0K3N")

  RestStub = Struct.new(:body)
  def self.rest_method(client, name, type, data, *args)
    describe name do
      it "makes a request" do
        resp_data = client.stub :request, RestStub.new(data) do
          client.__send__(name, *args)
        end

        if resp_data.is_a? Array
          assert_kind_of(type, resp_data[0])
        else
          assert_kind_of(type, resp_data)
        end
      end
    end
  end

  def self.rest_method_opts(client, name, type, data, *args, **opts)
    describe name do
      it "makes a request" do
        resp_data client.stub :request, RestStub.new(data) do
          client.__send__(name, *args, **opts)
        end

        if resp_data.is_a? Array
          assert_kind_of(type, resp_data[0])
        else
          assert_kind_of(type, resp_data)
        end
      end
    end
  end

  rest_method(c, :get_gateway, Rapture::GatewayInfo, json_data("gateway_info"))
  rest_method(c, :get_gateway_bot, Rapture::GatewayInfo, json_data("gateway_info"))

  rest_method(c, :get_guild_audit_log, Rapture::AuditLog, json_data("audit_log"), nil)

  rest_method(c, :get_guild, Rapture::Guild, json_data("guild"), nil)
  rest_method(c, :get_guild_channels, Rapture::Channel, "[#{json_data("channel")}]", nil)
  rest_method(c, :get_channel, Rapture::Channel, json_data("channel"), nil)
  rest_method(c, :get_guild_member, Rapture::Member, json_data("member"), nil, nil)
  rest_method(c, :get_guild_emoji, Rapture::Emoji, json_data("emoji"), nil, nil)
  rest_method(c, :get_webhook, Rapture::Webhook, json_data("webhook"), nil)
  rest_method(c, :get_webhook_with_token, Rapture::Webhook, json_data("webhook"), nil, nil)
  rest_method(c, :get_channel_webhooks, Rapture::Webhook, "[#{json_data("webhook")}]", nil)
  rest_method(c, :get_guild_webhooks, Rapture::Webhook, "[#{json_data("webhook")}]", nil)
  rest_method(c, :get_current_application_information, Rapture::OauthApplication, json_data("oauth_application"))
  rest_method(c, :get_user, Rapture::User, json_data("user"), nil)
  rest_method(c, :get_current_user, Rapture::User, json_data("user"))
  rest_method(c, :get_current_user_guilds, Rapture::Guild, "[#{json_data("guild")}]")
  rest_method(c, :get_user_dms, Rapture::Channel, "[#{json_data("channel")}]")
  # rest_method(c, :get_user_connections, Rapture::User::Connection, "[#{json_data("connection")}]")

  rest_method(c, :list_guild_emojis, Rapture::Emoji, "[#{json_data("emoji")}]", nil)
  rest_method(c, :list_voice_regions, Rapture::Voice::Region, json_data("voice_regions"))
end
