require "./spec_helper"

describe JSON::Minify do
  it "should remove whitespace from JSON" do
    JSON.minify("{ }").should eq("{}")
    JSON.minify(%({"foo": "bar"\n}\n)).should eq(%({"foo":"bar"}))
  end

  it "should remove comments from JSON" do
    JSON.minify("{ /* foo */ } /* bar */").should eq("{}")
    JSON.minify(%({"foo": "bar"\n}\n // this is a comment)).should eq(%({"foo":"bar"}))
  end

  it "should throw a SyntaxError on invalid JSON" do
    expect_raises(JSON::Minify::SyntaxError) { JSON.minify("{ /* foo */ } /* bar ") }
    expect_raises(JSON::Minify::SyntaxError) { JSON.minify(%<{ "foo": new Date(1023) }>) }
  end

  it "should cope with the example from https://github.com/getify/JSON.minify" do
    JSON.minify(%({ /* comment */ "foo": 42 \n })).should eq(%({"foo":42}))
  end

  it "should cope with the https://gist.github.com/mattheworiordan/72db0dfc933f743622eb" do
    JSON.minify(%({ "PolicyName": { "Fn::Join" : [ "", [ "AblySnsPublish-", { "Ref" : "AWS::Region" }, "-", { "Ref" : "DataCenterID" } ] ] } })).should \
      eq(%({"PolicyName":{"Fn::Join":["",["AblySnsPublish-",{"Ref":"AWS::Region"},"-",{"Ref":"DataCenterID"}]]}}))
  end

  it "should cope with escaped double quoted strings" do
    JSON.minify(%({ "Statement1": "he said \\"no way\\" to the dog", "Statement2": "she said \\"really?\\"" })).should \
      eq(%({"Statement1":"he said \\"no way\\" to the dog","Statement2":"she said \\"really?\\""}))
  end
end
