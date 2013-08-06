require 'test_helper'

describe Lotus::View do
  describe 'layout' do
    describe 'when Lotus::View.layout is nil' do
      describe "and it isn't specified at view level" do
        it 'has NullLayout' do
          HelloWorldView.layout.must_equal(Lotus::View::Rendering::NullLayout)
        end
      end

      describe "and it is specified at view level" do
        it 'has the specified value' do
          AppView.layout.must_equal(ApplicationLayout)
        end

        describe "and a subclass has a different value" do
          it 'has the specified value' do
            AppViewLayout.layout.must_equal(Lotus::View::Rendering::NullLayout)
          end
        end
      end
    end

    describe 'when Lotus::View.layout has a value' do
      before do
        Lotus::View.layout = :global

        App::View.class_eval { @layout = nil }
        App::View.layout(Lotus::View::Rendering::LayoutFinder.new(App::View).find)
      end

      after do
        Lotus::View.layout = nil
        Lotus::View.layout.freeze
      end

      describe "and it isn't specified at view level" do
        it 'returns the global value' do
          App::View.layout.must_equal(Lotus::View.layout)
        end
      end

      describe "and it is specified at view level" do
        it 'has the specified value' do
          AppView.layout.must_equal(ApplicationLayout)
        end

        describe "and a subclass has a different value" do
          it 'has the specified value' do
            AppViewLayout.layout.must_equal(Lotus::View::Rendering::NullLayout)
          end
        end
      end
    end
  end
end
