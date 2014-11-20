require "spec_helper"

describe Violation do
  it { should belong_to(:build) }
  it { should delegate_method(:changed?).to(:line) }
  it { should serialize(:line) }
  it { should delegate_method(:patch_position).to(:line) }

  describe "#add_messages" do
    it "should add the messages" do
      existing_message = "broken"
      new_message = "it's broken again"
      violation = build(:violation, messages: [existing_message])

      messages = violation.add_messages([new_message])

      expect(messages).to match_array([existing_message, new_message])
    end
  end

  describe "#messages" do
    it "should return unique messages" do
      message = "broken"
      all_messages = [message, message]
      violation = build(:violation, messages: all_messages)

      messages = violation.messages

      expect(messages).to match_array([message])
    end
  end
end
