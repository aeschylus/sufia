require 'spec_helper'

describe UserUnfollowEventJob do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:third_user) { create(:user) }
  let(:mock_time) { Time.zone.at(1) }
  let(:event) { { action: "User <a href=\"/users/#{user.to_param}\">#{user.user_key}</a> has unfollowed <a href=\"/users/#{another_user.to_param}\">#{another_user.user_key}</a>", timestamp: '1' } }

  before do
    third_user.follow(user)
    user.follow(another_user)
    allow(Time).to receive(:now).at_least(:once).and_return(mock_time)
  end

  it "logs the event to the unfollower's dashboard, the unfollowee's dashboard, and followers' dashboards" do
    expect {
      described_class.perform_now(user.user_key, another_user.user_key)
    }.to change { user.events.length }.by(1)
      .and change { another_user.events.length }.by(1)
      .and change { third_user.events.length }.by(1)

    expect(user.events.first).to eq(event)
    expect(another_user.events.first).to eq(event)
    expect(third_user.events.first).to eq(event)
  end
end
