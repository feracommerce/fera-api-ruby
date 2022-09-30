require 'spec_helper'

describe Fera::Order do
  before do
    Fera::API.configure("MOCK_API_KEY")
  end

  let(:order) { described_class.new(id: 1) }

  describe "#pay!" do
    let(:result) { order.pay! }
    let(:mock_response) { { message: 'Order marked as paid.' } }

    context "when successful response" do
      before do
        stub_request(:put, /.*\/orders\/1\/pay\.json(\?.*)?/i).to_return(status: 200, body: mock_response.to_json, headers: { 'Content-Type': 'application/json' })
      end

      it "is successful" do
        expect(result).to be_truthy
        expect(order.paid_at).to be_a(Time)
      end
    end

    context "when order is already paid" do
      let(:mock_response) { { message: 'Order is already marked as paid.' } }

      before do
        stub_request(:put, /.*\/orders\/1\/pay\.json(\?.*)?/i).to_return(status: 400, body: mock_response.to_json, headers: { 'Content-Type': 'application/json' })
      end

      it "raises an error" do
        expect { result }.to raise_error ActiveResource::BadRequest
      end
    end
  end

  describe "#deliver!" do
    let(:result) { order.deliver! }
    let(:mock_response) { { message: 'Order marked as delivered.' } }

    context "when successful response" do
      before do
        stub_request(:put, /.*\/orders\/1\/deliver\.json(\?.*)?/i).to_return(status: 200, body: mock_response.to_json, headers: { 'Content-Type': 'application/json' })
      end

      it "is successful" do
        expect(result).to be_truthy
        expect(order.delivered_at).to be_a(Time)
      end

      context "when delivered_at is a string" do
        let(:result) { order.deliver!("2022-09-23T22:29:46+00:00") }

        it "is successful" do
          expect(result).to be_truthy
        end
      end
    end

    context "when order is already delivered" do
      let(:mock_response) { { message: 'Order is already marked as delivered.' } }

      before do
        stub_request(:put, /.*\/orders\/1\/deliver\.json(\?.*)?/i).to_return(status: 400, body: mock_response.to_json, headers: { 'Content-Type': 'application/json' })
      end

      it "raises an error" do
        expect { result }.to raise_error ActiveResource::BadRequest
      end
    end
  end

  describe "#fulfill!" do
    let(:result) { order.fulfill! }
    let(:mock_response) { { message: 'Order marked as fulfilled.' } }

    context "when successful response" do
      before do
        stub_request(:put, /.*\/orders\/1\/fulfill\.json(\?.*)?/i).to_return(status: 200, body: mock_response.to_json, headers: { 'Content-Type': 'application/json' })
      end

      it "is successful" do
        expect(result).to be_truthy
        expect(order.fulfilled_at).to be_a(Time)
      end
    end

    context "when order is already fulfilled" do
      let(:mock_response) { { message: 'Order is already marked as fulfilled.' } }

      before do
        stub_request(:put, /.*\/orders\/1\/fulfill\.json(\?.*)?/i).to_return(status: 400, body: mock_response.to_json, headers: { 'Content-Type': 'application/json' })
      end

      it "raises an error" do
        expect { result }.to raise_error ActiveResource::BadRequest
      end
    end
  end

  describe "#paid?" do
    subject { order.paid? }

    context "when paid_at is nil" do
      it { is_expected.to be_falsey }
    end

    context "when paid_at is not nil" do
      let(:order) { described_class.new(id: 1, paid_at: Time.now) }

      it { is_expected.to be_truthy }
    end
  end

  describe "#delivered?" do
    subject { order.delivered? }

    context "when delivered_at is nil" do
      it { is_expected.to be_falsey }
    end

    context "when delivered_at is not nil" do
      let(:order) { described_class.new(id: 1, delivered_at: Time.now) }

      it { is_expected.to be_truthy }
    end
  end

  describe "#fulfilled?" do
    subject { order.fulfilled? }

    context "when fulfilled_at is nil" do
      it { is_expected.to be_falsey }
    end

    context "when fulfilled_at is not nil" do
      let(:order) { described_class.new(id: 1, fulfilled_at: Time.now) }

      it { is_expected.to be_truthy }
    end
  end
end
