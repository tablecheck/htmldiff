# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe HTMLDiff::OperationGenerator do
  describe ".generate_operations" do
    context "with empty inputs" do
      it "returns empty operations for empty tokens" do
        operations = HTMLDiff::OperationGenerator.generate_operations([], [])
        expect(operations).to be_empty
      end
    end

    context "with insertion operations" do
      it "generates an insert operation when adding new content" do
        operations = HTMLDiff::OperationGenerator.generate_operations([], ["a", "b", "c"])
        
        expect(operations.size).to eq(1)
        expect(operations[0].action).to eq(:insert)
        expect(operations[0].start_in_old).to eq(0)
        expect(operations[0].end_in_old).to eq(0)
        expect(operations[0].start_in_new).to eq(0)
        expect(operations[0].end_in_new).to eq(3)
      end

      it "generates an insert operation in the middle of content" do
        operations = HTMLDiff::OperationGenerator.generate_operations(
          ["a", "d"],
          ["a", "b", "c", "d"]
        )
        
        expect(operations.size).to eq(3)
        
        # First equal operation for "a"
        expect(operations[0].action).to eq(:equal)
        expect(operations[0].start_in_old).to eq(0)
        expect(operations[0].end_in_old).to eq(1)
        
        # Insert operation for "b", "c"
        expect(operations[1].action).to eq(:insert)
        expect(operations[1].start_in_old).to eq(1)
        expect(operations[1].end_in_old).to eq(1)
        expect(operations[1].start_in_new).to eq(1)
        expect(operations[1].end_in_new).to eq(3)
        
        # Second equal operation for "d"
        expect(operations[2].action).to eq(:equal)
      end
    end

    context "with deletion operations" do
      it "generates a delete operation when removing content" do
        operations = HTMLDiff::OperationGenerator.generate_operations(
          ["a", "b", "c"],
          []
        )
        
        expect(operations.size).to eq(1)
        expect(operations[0].action).to eq(:delete)
        expect(operations[0].start_in_old).to eq(0)
        expect(operations[0].end_in_old).to eq(3)
        expect(operations[0].start_in_new).to eq(0)
        expect(operations[0].end_in_new).to eq(0)
      end

      it "generates a delete operation in the middle of content" do
        operations = HTMLDiff::OperationGenerator.generate_operations(
          ["a", "b", "c", "d"],
          ["a", "d"]
        )
        
        expect(operations.size).to eq(3)
        
        # First equal operation for "a"
        expect(operations[0].action).to eq(:equal)
        expect(operations[0].start_in_old).to eq(0)
        expect(operations[0].end_in_old).to eq(1)
        
        # Delete operation for "b", "c"
        expect(operations[1].action).to eq(:delete)
        expect(operations[1].start_in_old).to eq(1)
        expect(operations[1].end_in_old).to eq(3)
        expect(operations[1].start_in_new).to eq(1)
        expect(operations[1].end_in_new).to eq(1)
        
        # Second equal operation for "d"
        expect(operations[2].action).to eq(:equal)
      end
    end

    context "with equal operations" do
      it "generates an equal operation for identical content" do
        operations = HTMLDiff::OperationGenerator.generate_operations(
          ["a", "b", "c"],
          ["a", "b", "c"]
        )
        
        expect(operations.size).to eq(1)
        expect(operations[0].action).to eq(:equal)
        expect(operations[0].start_in_old).to eq(0)
        expect(operations[0].end_in_old).to eq(3)
        expect(operations[0].start_in_new).to eq(0)
        expect(operations[0].end_in_new).to eq(3)
      end
    end

    context "with replace operations" do
      it "generates a replace operation for changed content" do
        operations = HTMLDiff::OperationGenerator.generate_operations(
          ["a", "b", "c"],
          ["x", "y", "z"]
        )
        
        expect(operations.size).to eq(1)
        expect(operations[0].action).to eq(:replace)
        expect(operations[0].start_in_old).to eq(0)
        expect(operations[0].end_in_old).to eq(3)
        expect(operations[0].start_in_new).to eq(0)
        expect(operations[0].end_in_new).to eq(3)
      end

      it "generates a replace operation for partially changed content" do
        operations = HTMLDiff::OperationGenerator.generate_operations(
          ["a", "b", "c"],
          ["a", "x", "c"]
        )
        
        expect(operations.size).to eq(3)
        
        # Equal for "a"
        expect(operations[0].action).to eq(:equal)
        expect(operations[0].start_in_old).to eq(0)
        expect(operations[0].end_in_old).to eq(1)
        
        # Replace "b" with "x"
        expect(operations[1].action).to eq(:replace)
        expect(operations[1].start_in_old).to eq(1)
        expect(operations[1].end_in_old).to eq(2)
        expect(operations[1].start_in_new).to eq(1)
        expect(operations[1].end_in_new).to eq(2)
        
        # Equal for "c"
        expect(operations[2].action).to eq(:equal)
        expect(operations[2].start_in_old).to eq(2)
        expect(operations[2].end_in_old).to eq(3)
      end
    end

    context "with complex scenarios" do
      it "handles mixed operations" do
        operations = HTMLDiff::OperationGenerator.generate_operations(
          ["a", "b", "c", "d", "e"],
          ["a", "x", "c", "y", "e"]
        )
        
        expect(operations.size).to eq(5)
        
        # Equal "a"
        expect(operations[0].action).to eq(:equal)
        
        # Replace "b" with "x"
        expect(operations[1].action).to eq(:replace)
        
        # Equal "c"
        expect(operations[2].action).to eq(:equal)
        
        # Replace "d" with "y"
        expect(operations[3].action).to eq(:replace)
        
        # Equal "e"
        expect(operations[4].action).to eq(:equal)
      end

      it "finds matches that span multiple tokens" do
        operations = HTMLDiff::OperationGenerator.generate_operations(
          ["a", "b", "c", "d", "e", "f"],
          ["x", "y", "c", "d", "z"]
        )
        
        # There should be a match for "c", "d"
        expect(operations.any? { |op| 
          op.action == :equal && 
          op.start_in_old == 2 && 
          op.end_in_old == 4 && 
          op.start_in_new == 2 && 
          op.end_in_new == 4 
        }).to be true
      end

      it "handles completely different content" do
        operations = HTMLDiff::OperationGenerator.generate_operations(
          ["hello", "world"],
          ["goodbye", "everyone"]
        )
        
        expect(operations.size).to eq(1)
        expect(operations[0].action).to eq(:replace)
      end

      it "handles complex interleaved changes" do
        old_tokens = ["a", "b", "c", "d", "e", "f", "g", "h"]
        new_tokens = ["a", "c", "e", "g", "i", "j", "k"]
        
        operations = HTMLDiff::OperationGenerator.generate_operations(old_tokens, new_tokens)
        
        # Validate that operations cover all tokens
        old_covered = operations.sum { |op| op.end_in_old - op.start_in_old }
        new_covered = operations.sum { |op| op.end_in_new - op.start_in_new }
        
        expect(old_covered).to eq(old_tokens.size)
        expect(new_covered).to eq(new_tokens.size)
        
        # Check that the operations are valid
        operations.each do |op|
          expect([:equal, :insert, :delete, :replace]).to include(op.action)
          expect(op.start_in_old).to be >= 0
          expect(op.end_in_old).to be <= old_tokens.size
          expect(op.start_in_new).to be >= 0
          expect(op.end_in_new).to be <= new_tokens.size
        end
      end
    end
  end
end
