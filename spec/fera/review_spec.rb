require 'spec_helper'

describe Fera::Review do
  before do
    Fera::Api.configure("MOCK_API_KEY")
  end

  describe "#all" do
    let(:result) { described_class.all }

    context "when successful response" do
      before do
        stub_request(:get, /.*\/reviews\.json(\?.*)?/i).to_return(status: 200, body: mocked_responses.to_json, headers: { 'Content-Type': 'application/json' })
      end

      let(:mocked_responses) { { data: response_data, meta: response_meta } }
      let(:response_data) { nil }
      let(:response_meta) { nil }

      context "when empty data response" do
        let(:response_data) { [] }
        let(:response_meta) { { page: 1, per_page: 10, page_count: 1, limit: 10, offset: 0, total_count: 0 } }

        it "returns empty array" do
          expect(result).to be_empty
        end
      end

      context "when array of data response" do
        let(:response_data) { [load_sample_json_file(:review)] }
        let(:response_meta) { { page: 1, per_page: 10, page_count: 1, limit: 10, offset: 0, total_count: 0 } }

        it "returns empty array" do
          expect(result).not_to be_empty
          expect(result.first).to be_a(described_class)
          expect(result.first.id).to eq(response_data.first["id"])
        end
      end
    end
  end
end
