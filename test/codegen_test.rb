require "helper"

module ProtoBoeuf
  class CodeGenTest < Test
    def test_make_ruby
      unit = ProtoBoeuf.parse_string('message TestMessage { string id = 1; uint64 shop_id = 2; bool boolean = 3; }')
      gen = CodeGen.new unit
      klass = Class.new { self.class_eval gen.to_ruby }
      obj = klass::TestMessage.new
      assert_equal "", obj.id
      assert_equal 0, obj.shop_id
      assert_equal false, obj.boolean
    end

    def test_int32
      unit = ProtoBoeuf.parse_string('message Test1 { optional int32 a = 1; }')
      gen = CodeGen.new unit
      klass = Class.new { self.class_eval gen.to_ruby }
      obj = klass::Test1.new
      assert_equal 0, obj.a
    end

    def test_fixture_file
      unit = ProtoBoeuf.parse_file('./test/fixtures/test.proto')

      gen = CodeGen.new unit

      klass = Class.new { self.class_eval gen.to_ruby }
      obj = klass::Test1.new
      assert_equal 0, obj.a

      assert_equal [], klass::TestRepeatedField.new.e
    end

    def test_fields_keyword_end
      unit = ProtoBoeuf.parse_string('message Test1 { optional int32 end = 1; }')
      gen = CodeGen.new unit
      klass = Class.new { self.class_eval gen.to_ruby }
      obj = klass::Test1.new(end: 1234)
      assert_equal 1234, obj.end
    end

    def test_fields_keyword_class
      unit = ProtoBoeuf.parse_string('message Test1 { optional int32 class = 1; }')
      gen = CodeGen.new unit
      klass = Class.new { self.class_eval gen.to_ruby }
      obj = klass::Test1.new(class: 1234)
      assert_equal 1234, obj.class
    end

    def test_fields_keyword_nil
      unit = ProtoBoeuf.parse_string('message Test1 { optional int32 nil = 1; }')
      gen = CodeGen.new unit
      klass = Class.new { self.class_eval gen.to_ruby }
      obj = klass::Test1.new(nil: 1234)
      assert_equal 1234, obj.nil
    end

    def test_generate_types
      proto = File.read("test/fixtures/typed_test.proto")
      unit = ProtoBoeuf.parse_string(proto)

      gen = CodeGen.new unit, generate_types: true

      File.write("test/fixtures/typed_test.generated.rb", gen.to_ruby)

      # The goal of this test is to ensure that we generate valid sorbet signatures.
      #
      # This tests will break whenever any implementation of field encoding/deconding etc changes.
      # While this is not great, writing tests that ensure that signatures are generated
      # correctly without pulling in all of sorbet is at the very least incredibly complex.
      # So this is the solution for now.
      assert_equal File.read("test/fixtures/typed_test.correct.rb"), gen.to_ruby
    end
  end
end
