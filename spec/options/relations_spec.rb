require "spec_helper"

#TODO: Add tests for injected relationships
RSpec.describe "SimpleAMS::Options#includes" do
  context "with no reations in general" do
    before do
      @options = SimpleAMS::Options.new(
        User.new,
        Helpers.random_options_with({
          serializer: UserSerializer,
        }).tap{|h|
          h.delete(:includes)
          h.delete(:relations)
        }
      )
    end

    it "returns empty array" do
      expect(@options.relations).to eq []
    end
  end

  context "with no injected includes" do
    before do
      @allowed_relations = Helpers.random_relations_with_types
      @allowed_relations.each do |rel, type|
        UserSerializer.send(type, rel, options: Helpers.random_options)
      end
      @options = SimpleAMS::Options.new(
        User.new,
        Helpers.random_options_with({
          serializer: UserSerializer,
        }).tap{|h| h.delete(:includes)}
      )
    end

    it "holds the specified options" do
      expect(@options.relations.map(&:name)).to(
        eq(
          @allowed_relations.keys
        )
      )
    end
  end

  context "with empty injected includes" do
    before do
      @allowed_relations = Helpers.random_relations_with_types
      @allowed_relations.each do |rel, type|
        UserSerializer.send(type, rel, options: Helpers.random_options)
      end
      @options = SimpleAMS::Options.new(
        User.new,
        Helpers.random_options_with({
          serializer: UserSerializer,
          includes: []
        })
      )
    end

    it "holds the specified options" do
      expect(@options.relations).to(
        eq(
          []
        )
      )
    end
  end

  context "with no allowed relations but injected ones" do
    pending('Needs implementation')
  end

  context "with various includes" do
    before do
      @allowed_relations = Helpers.random_relations_with_types
      @allowed_relations.each do |rel, type|
        UserSerializer.send(type, rel, options: Helpers.random_options)
      end
      @injected_relations = @allowed_relations.keys.sample(
        0#rand(@allowed_relations.keys.length)
      )
      @options = SimpleAMS::Options.new(
        User.new,
        Helpers.random_options_with({
          serializer: UserSerializer,
          includes: @injected_relations
        })
      )
    end

    it "holds the specified options" do
      expect(@options.relations.map(&:name)).to(
        eq(
          @allowed_relations.keys & @injected_relations
        )
      )
    end
  end

  context "with repeated includes" do
    before do
      @allowed_relations = Helpers.random_relations_with_types
      2.times {
        @allowed_relations.each do |rel, type|
          UserSerializer.send(type, rel, options: Helpers.random_options)
        end
      }
      @injected_relations = @allowed_relations.keys.sample(
        0#rand(@allowed_relations.keys.length)
      )
      @options = SimpleAMS::Options.new(
        User.new,
        Helpers.random_options_with({
          serializer: UserSerializer,
          includes: @injected_relations
        })
      )
    end

    it "holds the uniq union of injected and allowed includes" do
      expect(@options.includes).to(
        eq(
          (@allowed_relations.keys & @injected_relations).uniq
        )
      )
    end
  end
end
