require 'discordrb'

module Discordrb
  describe Bot do
    subject(:bot) do
      described_class.new(token: 'fake_token')
    end

    fixture :server_data, [:emoji, :emoji_server]
    fixture_property :server_id, :server_data, ['id'], :to_i

    let!(:server) { Discordrb::Server.new(server_data, bot) }

    fixture :dispatch_event, [:emoji, :dispatch_event]
    fixture :dispatch_add, [:emoji, :dispatch_add]
    fixture :dispatch_remove, [:emoji, :dispatch_remove]
    fixture :dispatch_update, [:emoji, :dispatch_update]

    EMOJI1_ID = 10
    EMOJI1_NAME = 'emoji_name_1'.freeze

    EMOJI2_ID = 11
    EMOJI2_NAME = 'emoji_name_2'.freeze
    EDITED_EMOJI_NAME = 'new_emoji_name'.freeze

    EMOJI3_ID = 12
    EMOJI3_NAME = 'emoji_name_3'.freeze

    before do
      bot.instance_variable_set(:@servers, server_id => server)
    end

    it 'should set up' do
      expect(bot.server(server_id)).to eq(server)
      expect(bot.server(server_id).emoji.size).to eq(2)
    end

    describe '#handle_dispatch' do
      it 'handles GUILD_EMOJIS_UPDATE' do
        type = :GUILD_EMOJIS_UPDATE
        expect(bot).to receive(:raise_event).exactly(4).times
        bot.send(:handle_dispatch, type, dispatch_event)
      end
    end

    describe '#update_guild_emoji' do
      it 'removes an emoji' do
        bot.send(:update_guild_emoji, dispatch_remove)
        emojis = bot.server(server_id).emoji
        emoji = emojis[EMOJI1_ID]
        expect(emojis.size).to eq(1)
        expect(emoji.name).to eq(EMOJI1_NAME)
        expect(emoji.server).to eq(server)
        expect(emoji.roles).to eq([])
      end

      it 'adds an emoji' do
        bot.send(:update_guild_emoji, dispatch_add)
        emojis = bot.server(server_id).emoji
        emoji = emojis[EMOJI3_ID]
        expect(emojis.size).to eq(3)
        expect(emoji.name).to eq(EMOJI3_NAME)
        expect(emoji.server).to eq(server)
        expect(emoji.roles).to eq([])
      end

      it 'edits an emoji' do
        bot.send(:update_guild_emoji, dispatch_update)
        emojis = bot.server(server_id).emoji
        emoji = emojis[EMOJI2_ID]
        expect(emojis.size).to eq(2)
        expect(emoji.name).to eq(EDITED_EMOJI_NAME)
        expect(emoji.server).to eq(server)
        expect(emoji.roles).to eq([])
      end
    end
  end
end