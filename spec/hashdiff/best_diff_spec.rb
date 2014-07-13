require 'spec_helper'

describe HashDiff do
  it "should be able to best diff" do
    a = {'x' => [{'a' => 1, 'c' => 3, 'e' => 5}, {'y' => 3}]}
    b = {'x' => [{'a' => 1, 'b' => 2, 'e' => 5}] }

    diff = HashDiff.best_diff(a, b)
    diff.should == [["-", "x[0].c", 3], ["+", "x[0].b", 2], ["-", "x[1]", {"y"=>3}]]
  end

  it "should use custom delimiter when provided" do
    a = {'x' => [{'a' => 1, 'c' => 3, 'e' => 5}, {'y' => 3}]}
    b = {'x' => [{'a' => 1, 'b' => 2, 'e' => 5}] }

    diff = HashDiff.best_diff(a, b, :delimiter => "\t")
    diff.should == [["-", "x[0]\tc", 3], ["+", "x[0]\tb", 2], ["-", "x[1]", {"y"=>3}]]
  end

  it "should use custom comparison when provided" do
    a = {'x' => [{'a' => 'foo', 'c' => 'goat', 'e' => 'snake'}, {'y' => 'baz'}]}
    b = {'x' => [{'a' => 'bar', 'b' => 'cow', 'e' => 'puppy'}] }

    diff = HashDiff.best_diff(a, b) do |path, obj1, obj2|
      case path
      when /^x\[.\]\..$/
        obj1.length == obj2.length if obj1 and obj2
      end
    end

    diff.should == [["-", "x[0].c", 'goat'], ["+", "x[0].b", 'cow'], ["-", "x[1]", {"y"=>'baz'}]]
  end

  it "should be able to best diff array in hash" do
    a = {"menu" => {
      "id" => "file",
      "value" => "File",
      "popup" => {
        "menuitem" => [
          {"value" => "New", "onclick" => "CreateNewDoc()"},
          {"value" => "Close", "onclick" => "CloseDoc()"}
        ]
      }
    }}

    b = {"menu" => {
      "id" => "file 2",
      "value" => "File",
      "popup" => {
        "menuitem" => [
          {"value" => "New1", "onclick" => "CreateNewDoc()"},
          {"value" => "Open", "onclick" => "OpenDoc()"},
          {"value" => "Close", "onclick" => "CloseDoc()"}
        ]
      }
    }}

    diff = HashDiff.best_diff(a, b)
    diff.should == [
      ['~', 'menu.id', 'file', 'file 2'],
      ['~', 'menu.popup.menuitem[0].value', 'New', 'New1'],
      ['+', 'menu.popup.menuitem[1]', {"value" => "Open", "onclick" => "OpenDoc()"}]
    ]
  end
end
