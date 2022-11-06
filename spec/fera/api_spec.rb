require 'spec_helper'

describe Fera::API do
  describe "#configure" do
    context "with block" do
      context "with auth token" do
        it "sets the API key in the headers" do
          described_class.configure("ExampleAuthToken") do
            expect(Fera::Base.api_key).to eq("ExampleAuthToken")
            expect(Fera::Base.headers['Authorization']).to eq("Bearer ExampleAuthToken")
          end

          expect(Fera::Base.api_key).to be_nil
        end
      end

      context "with secret key" do
        it "sets the API key in the headers" do
          described_class.configure("sk_abcd123") do
            expect(Fera::Base.api_key).to eq("sk_abcd123")
          end

          expect(Fera::Base.api_key).to be_nil
        end
      end
    end
  end
end
