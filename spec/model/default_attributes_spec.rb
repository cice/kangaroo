require 'spec_helper'
require 'kangaroo/model/base'

module Kangaroo
  module Model
    describe DefaultAttributes do
      before :each do
        @klass = Class.new(Kangaroo::Model::Base)
        @klass.stub!(:fields_hash).and_return({})
        @klass.define_multiple_accessors :a, :b
      end

      it 'sets default values on initialization' do
        @klass.stub!(:default_attributes).and_return(:a => 'one')
        @object = @klass.new
        @object.a.should == 'one'
        @object.should be_a_changed
      end

      it 'sets default values before initial values' do
        @klass.stub!(:default_attributes).and_return(:a => 'one')
        @object = @klass.new :a => 'two'
        @object.a.should == 'two'
      end

      it 'fetches default values via default_get on the object service' do
        @klass = Class.new(Kangaroo::Model::Base)
        @klass.stub!(:fields_hash).and_return({})
        @klass.define_multiple_accessors :a, :b
        @klass.field_names = %w(a b)
        @klass.stub!(:remote).and_return mock('object_service')
        @klass.remote.should_receive(:default_get).with(%w(a b), anything).and_return :a => 'one', :b => 'two'
        @object = @klass.new
        @object.a.should == 'one'
        @object.b.should == 'two'
      end
    end
  end
end